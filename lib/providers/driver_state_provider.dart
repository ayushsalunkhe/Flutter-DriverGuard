import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../logic/drowsiness_detector.dart';
import '../logic/cognitive_load.dart';
import '../logic/emergency_manager.dart';
import '../services/audio_service.dart';
import '../database/database_helper.dart';
import '../utils/constants.dart';
import '../utils/camera_utils.dart';

enum DriverState { AWAKE, DROWSY, HIGH_LOAD, NO_FACE }

class DriverStateProvider with ChangeNotifier {
  CameraController? _cameraController;
  // Change to FaceDetector
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true, // REQUIRED for Eyes
      enableClassification: false, // We calculate EAR manually
      enableLandmarks: false,
    ),
  );

  final AudioService _audioService = AudioService();
  final CognitiveLoadEstimator _cogLoad = CognitiveLoadEstimator();
  final DatabaseHelper _db = DatabaseHelper();
  final EmergencyManager _emergencyManager = EmergencyManager();

  // State
  DriverState _currentState = DriverState.AWAKE;
  double _ear = 1.0;
  double _cognitiveScore = 0.0;
  String _cognitiveLabel = "NORMAL";
  bool _isProcessing = false;
  int? _sessionId;
  DateTime? _lastFaceSeen;
  DateTime? _eyeClosedStartTime;

  // Emergency Logic
  DateTime? _dangerStartTime; // Track how long we are in danger
  bool _emergencyTriggered = false;

  // HUD Data
  Face? _currentFace;

  // Getters
  CameraController? get cameraController => _cameraController;
  DriverState get currentState => _currentState;
  Face? get currentFace => _currentFace;
  double get ear => _ear;
  double get cognitiveScore => _cognitiveScore;
  String get cognitiveLabel => _cognitiveLabel;
  AudioService get audioService => _audioService;
  bool get isCameraInitialized =>
      _cameraController != null && _cameraController!.value.isInitialized;

  // Emergency State Getters
  bool get isEmergencyTriggered => _emergencyTriggered;
  int get dangerDuration => _dangerStartTime == null
      ? 0
      : DateTime.now().difference(_dangerStartTime!).inSeconds;

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras
          .firstWhere((c) => c.lensDirection == CameraLensDirection.front);

      _cameraController = CameraController(frontCamera, ResolutionPreset.medium,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.nv21);

      await _cameraController!.initialize();
      _sessionId = await _db.startSession();
      _lastFaceSeen = DateTime.now();

      _cameraController!.startImageStream(_processCameraImage);
      notifyListeners();

      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_lastFaceSeen != null &&
            DateTime.now().difference(_lastFaceSeen!).inMilliseconds >
                AppConstants.NO_FACE_TIMEOUT_MS) {
          _updateState(DriverState.NO_FACE);
        }
      });
    } catch (e) {
      print("Camera Init Error: $e");
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(image,
          _cameraController!.description, InputImageRotation.rotation270deg);

      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        _lastFaceSeen = DateTime.now();
        final face = faces.first;
        _currentFace = face;

        // 1. Calculate EAR (Modified for Contours)
        double currentEAR = DrowsinessDetector.calculateEAR(face);
        print(
            "DEBUG: EAR = ${currentEAR.toStringAsFixed(3)}"); // LOGGING FOR TUNING
        _ear = currentEAR;

        // 2. Blink Detection & Drowsiness
        if (currentEAR < AppConstants.EAR_THRESHOLD) {
          // Eyes Closed
          _cogLoad.registerBlink();

          if (_eyeClosedStartTime == null) {
            _eyeClosedStartTime = DateTime.now();
          } else {
            // Check if closed for > Threshold
            final duration =
                DateTime.now().difference(_eyeClosedStartTime!).inMilliseconds;
            if (duration > AppConstants.DROWSINESS_DURATION_MS) {
              _updateState(DriverState.DROWSY);
            }
          }
        } else {
          // Eyes Open
          _eyeClosedStartTime = null;

          // If we were Drowsy, assume we are now Awake
          if (_currentState == DriverState.DROWSY) {
            _updateState(DriverState.AWAKE);
          }
        }

        // 3. Cognitive Load
        final loadStats = _cogLoad.calculateLoad();
        _cognitiveScore = loadStats["score"];
        _cognitiveLabel = loadStats["label"];

        // 4. Update State (Only override if not Drowsy)
        if (_currentState != DriverState.DROWSY) {
          if (_cognitiveScore > 80) {
            _updateState(DriverState.HIGH_LOAD);
          } else {
            _updateState(DriverState.AWAKE);
          }
        }
      }
    } catch (e) {
      print("Processing Error: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void _updateState(DriverState newState) {
    if (_currentState == newState) {
      _checkEmergencyEscalation(); // Check timer even if state is same
      return;
    }

    _currentState = newState;
    _db.logEvent(_sessionId ?? 0, newState.toString(), _cognitiveScore);

    if (newState == DriverState.DROWSY || newState == DriverState.NO_FACE) {
      _audioService.playAlert();
    } else {
      _audioService.stopAlert();
      _dangerStartTime = null; // Reset if safe
    }

    _checkEmergencyEscalation();
  }

  Future<void> _checkEmergencyEscalation() async {
    if (_emergencyTriggered) return; // Already triggered

    if (_currentState == DriverState.DROWSY ||
        _currentState == DriverState.NO_FACE) {
      if (_dangerStartTime == null) {
        _dangerStartTime = DateTime.now();
      } else {
        final duration = DateTime.now().difference(_dangerStartTime!).inSeconds;
        // NOTIFY UI of countdown via listener?
        // Actually since this is called frequently, listeners will get updated
        // implicitly if we call notifyListeners(), but we should be careful not to spam.
        // Ideally we rely on the periodic timer in UI or frequent updates here.
        if (duration >= 10) {
          _emergencyTriggered = true;
          _audioService
              .stopAlert(); // Maybe stop looping alarm to focus on emergency? Or keep it?
          // Keep it but maybe change tone? For now keep it.

          await _emergencyManager
              .triggerEmergencyProtocol(_currentState.toString());
        }
      }
    } else {
      _dangerStartTime = null;
    }
    notifyListeners(); // Update UI for countdown
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _db.endSession(_sessionId ?? 0);
    super.dispose();
  }
}

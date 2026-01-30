import '../utils/constants.dart';

class CognitiveLoadEstimator {
  final List<DateTime> _blinkTimestamps = [];
  
  void registerBlink() {
    _blinkTimestamps.add(DateTime.now());
    // Keep only last 60 seconds of blinks
    _cleanup();
  }
  
  void _cleanup() {
    final now = DateTime.now();
    _blinkTimestamps.removeWhere((t) => now.difference(t).inSeconds > 60);
  }

  // Returns score 0-100
  // 0-30: Awake/Normal
  // 30-70: Medium Load
  // 70-100: High Load / Fatigue
  Map<String, dynamic> calculateLoad() {
    _cleanup();
    int blinksPerMinute = _blinkTimestamps.length;
    
    double score = 0;
    String label = "NORMAL";
    
    // Rule 1: Tunnel Vision (Staring) -> High Load
    if (blinksPerMinute < AppConstants.HIGH_LOAD_BLINK_RATE) {
      score = 85.0; // High Cognitive Load
      label = "HIGH LOAD";
    } 
    // Rule 2: Rapid Blinking -> Fatigue/Anxiety
    else if (blinksPerMinute > AppConstants.LOW_LOAD_BLINK_RATE) {
      score = 60.0;
      label = "FATIGUE";
    } 
    // Rule 3: Normal
    else {
      score = 20.0;
      label = "NORMAL";
    }
    
    return {
      "score": score,
      "label": label,
      "blinks": blinksPerMinute
    };
  }
}

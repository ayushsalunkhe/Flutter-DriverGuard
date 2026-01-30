class AppConstants {
  // Drowsiness Thresholds
  static const double EAR_THRESHOLD = 0.20;
  static const int BLINK_DURATION_MS = 150; // Min duration for a blink
  static const int MICROSLEEP_MS = 500; // > 500ms closure is microsleep
  static const int DROWSINESS_DURATION_MS =
      1000; // Trigger alert after 1 second of closure

  // Cognitive Load (Rule Based)
  static const int HIGH_LOAD_BLINK_RATE =
      10; // Less than 10 blinks/min (staring)
  static const int LOW_LOAD_BLINK_RATE = 30; // More than 30?

  // Timeouts
  static const int NO_FACE_TIMEOUT_MS = 3000;

  // Alerts
  static const String ALERT_SOUND = "alarm.mp3";
}

import 'package:driver_guard/database/database_helper.dart';
import 'package:driver_guard/services/location_service.dart';
import 'package:driver_guard/services/telegram_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyManager {
  final LocationService _locationService = LocationService();
  final TelegramService _telegramService = TelegramService();
  final DatabaseHelper _db = DatabaseHelper();

  bool _isSending = false;

  Future<bool> triggerEmergencyProtocol(String triggerReason) async {
    if (_isSending) return false;
    _isSending = true;

    try {
      // 1. Get Profile
      final profile = await _db.getProfile();
      if (profile == null) {
        print("EMERGENCY: No profile found. Skipping alert.");
        return false;
      }

      // 2. Get Location
      final position = await _locationService.getCurrentLocation();
      double lat = position?.latitude ?? 0.0;
      double lng = position?.longitude ?? 0.0;
      String mapUrl = _locationService.getGoogleMapsUrl(lat, lng);
      String hospitalUrl = _locationService.getNearbyHospitalsUrl(lat, lng);

      // 3. Formulate Message (Plain Text)
      String cleanTrigger =
          triggerReason.replaceAll("DriverState.", "").replaceAll("_", " ");

      String message = """
🚨 EMERGENCY ALERT: DRIVER UNRESPONSIVE 🚨

Passenger/Driver: ${profile['name']}
Blood Group: ${profile['blood_group']}
Medical Notes: ${profile['medical_notes']}

Trigger: $cleanTrigger persisted for >10 seconds.
Time: ${DateTime.now().toLocal()}

📍 Live Location:
$mapUrl

🏥 Nearest Hospitals:
$hospitalUrl

This is an automated message from DriverGuard System.
""";

      // 4. Send Telegram
      String chatId = profile['telegram_chat_id'] ?? "";
      // Ideally retrieve bot token from constants or secure storage.
      // For this academic project, we might ask user to input it or hardcode a demo one.
      // Let's assume the user saves it in profile or we use a demo one.
      // NOTE: We will skip actual sending if ID is empty.

      bool sent = false;
      if (chatId.isNotEmpty) {
        // Token provided by user for DriverGuardBot
        const String BOT_TOKEN =
            "8478126145:AAExxOcRzy894GIVTwMEsgfuwS6Npkc_-Bg";

        sent = await _telegramService.sendEmergencyAlert(
            botToken: BOT_TOKEN, chatId: chatId, message: message);
      }

      // 5. Fallback: Email Intent (if Telegram fails or not setup)
      if (!sent) {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: profile['emergency_contact'],
          query: 'subject=Emergency Alert&body=$message',
        );
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        }
      }

      // 6. Log Event
      await _db.logEmergency(
          triggerReason, lat, lng, sent ? "SENT" : "FAILED/LOCAL");

      return sent;
    } catch (e) {
      print("Emergency Protocol Failed: $e");
      return false;
    } finally {
      _isSending = false;
    }
  }
}

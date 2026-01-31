import 'package:http/http.dart' as http;

class TelegramService {
  // ACADEMIC NOTE: Ideally these tokens are not hardcoded or are stored securely.
  // For this prototype, user enters them or we defaults.

  Future<bool> sendEmergencyAlert(
      {required String botToken,
      required String chatId,
      required String message}) async {
    if (botToken.isEmpty || chatId.isEmpty) return false;

    print(
        "Telegram: Sending to $chatId using token ${botToken.substring(0, 10)}...");

    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
    try {
      final response = await http.post(
        url,
        body: {
          'chat_id': chatId,
          'text': message,
          // 'parse_mode': 'Markdown', // Disabled to prevent 400 errors with underscores
        },
      );

      print("Telegram Response: ${response.statusCode}");
      print("Telegram Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Telegram Error: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("Telegram Exception: $e");
      return false;
    }
  }
}

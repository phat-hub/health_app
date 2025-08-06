import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = "AIzaSyAVk_sx4ML0daJGKRYJF1UN1-rFhpetOb0";

  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey";

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "Bạn là bác sĩ AI thân thiện. $message"}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["candidates"] != null &&
            data["candidates"].isNotEmpty &&
            data["candidates"][0]["content"] != null &&
            data["candidates"][0]["content"]["parts"] != null &&
            data["candidates"][0]["content"]["parts"].isNotEmpty) {
          return data["candidates"][0]["content"]["parts"][0]["text"];
        }
        return "Không có phản hồi từ AI.";
      } else {
        print("❌ Gemini API Error: ${response.statusCode} - ${response.body}");
        return "Xin lỗi, tôi không thể trả lời lúc này.";
      }
    } catch (e) {
      print("❌ Exception: $e");
      return "Lỗi kết nối tới máy chủ AI.";
    }
  }
}

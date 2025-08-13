import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _serverUrl =
      "https://health-server-t8bs.onrender.com/chat"; // URL server của bạn

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Lấy text từ API Gemini trả về
        if (data["candidates"] != null &&
            data["candidates"].isNotEmpty &&
            data["candidates"][0]["content"] != null &&
            data["candidates"][0]["content"]["parts"] != null &&
            data["candidates"][0]["content"]["parts"].isNotEmpty) {
          return data["candidates"][0]["content"]["parts"][0]["text"];
        }
        return "Không có phản hồi từ AI.";
      } else {
        print("❌ Server Error: ${response.statusCode} - ${response.body}");
        return "Xin lỗi, tôi không thể trả lời lúc này.";
      }
    } catch (e) {
      print("❌ Exception: $e");
      return "Lỗi kết nối tới server.";
    }
  }
}

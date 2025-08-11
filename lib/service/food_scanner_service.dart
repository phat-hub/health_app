import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screen.dart';

class FoodScannerService {
  final ImagePicker _picker = ImagePicker();
  final String apiKey =
      "B03reu/w/8w01+lokcCZJA==fevOVyEeblbD04hR"; // CalorieNinjas API Key

  /// Xin quyền camera
  Future<bool> _requestCameraPermission() async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }

    var photoStatus = await Permission.photos.status;
    if (!photoStatus.isGranted) {
      photoStatus = await Permission.photos.request();
    }

    return cameraStatus.isGranted && photoStatus.isGranted;
  }

  /// Mở camera
  Future<File?> pickImageFromCamera() async {
    if (!await _requestCameraPermission()) {
      throw Exception("Chưa cấp quyền camera");
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }

  /// Nhận diện thực phẩm bằng Google Cloud Vision API
  Future<String?> detectFoodName(File image) async {
    final apiKey = "AIzaSyDM7IsYy0xPUJTQXuzQUDB7pN6rER4Wnb0";
    final url = Uri.parse(
        "https://vision.googleapis.com/v1/images:annotate?key=$apiKey");

    // Đọc file ảnh và encode base64
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Request body
    final body = jsonEncode({
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 5}
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final labels = data["responses"]?[0]?["labelAnnotations"];
      if (labels != null && labels.isNotEmpty) {
        final possibleLabels = labels
            .map((label) => label["description"].toString().toLowerCase())
            .toList();

        // Ưu tiên tên chi tiết
        final detailed = possibleLabels.firstWhere(
          (l) => l != "fruit" && l != "food" && l != "plant",
          orElse: () => possibleLabels.first,
        );

        return detailed;
      }
    } else {
      throw Exception(
          "Lỗi Vision API: ${response.statusCode} - ${response.body}");
    }

    return null;
  }

  /// Lấy calo từ CalorieNinjas API
  Future<FoodItem?> fetchCalories(String foodName) async {
    final url =
        Uri.parse("https://api.calorieninjas.com/v1/nutrition?query=$foodName");
    final response = await http.get(url, headers: {
      "X-Api-Key": apiKey,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["items"] != null && data["items"].isNotEmpty) {
        final item = data["items"][0];
        return FoodItem(
          name: item["name"],
          calories: (item["calories"] ?? 0).toDouble(),
        );
      }
    }
    return null;
  }

  /// Mở thư viện ảnh
  Future<File?> pickImageFromGallery() async {
    var photoStatus = await Permission.photos.status;
    if (!photoStatus.isGranted) {
      photoStatus = await Permission.photos.request();
    }
    if (!photoStatus.isGranted) {
      throw Exception("Chưa cấp quyền truy cập thư viện ảnh");
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }
}

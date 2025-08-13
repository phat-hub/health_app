import 'dart:io';
import 'package:image/image.dart' as img; // 📌 Thêm thư viện này
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screen.dart';

class FoodScannerService {
  final ImagePicker _picker = ImagePicker();
  final String serverBaseUrl = "https://health-server-t8bs.onrender.com";

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

  /// Nhận diện thực phẩm qua server
  /// Nhận diện thực phẩm qua server
  Future<String?> detectFoodName(File image) async {
    final url = Uri.parse("$serverBaseUrl/detect-food");

    // Đọc ảnh gốc
    final originalBytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(originalBytes);

    if (decodedImage == null) {
      throw Exception("Không đọc được ảnh");
    }

    // 📌 Chỉ resize nếu ảnh quá lớn (giữ chi tiết hơn)
    final maxSize = 1280;
    final resizedImage =
        (decodedImage.width > maxSize || decodedImage.height > maxSize)
            ? img.copyResize(decodedImage, width: maxSize)
            : decodedImage;

    // 📌 Giữ chất lượng cao hơn (90)
    final resizedBytes = img.encodeJpg(resizedImage, quality: 90);

    // Encode sang base64
    final base64Image = base64Encode(resizedBytes);

    // Gửi ảnh đã xử lý lên server
    final body = jsonEncode({"imageBase64": base64Image});
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

        final detailed = possibleLabels.firstWhere(
          (l) => l != "fruit" && l != "food" && l != "plant",
          orElse: () => possibleLabels.first,
        );

        return detailed;
      }
    } else {
      throw Exception(
          "Lỗi server detect-food: ${response.statusCode} - ${response.body}");
    }

    return null;
  }

  /// Lấy calo từ server
  Future<FoodItem?> fetchCalories(String foodName) async {
    final url = Uri.parse(
        "$serverBaseUrl/calories?query=${Uri.encodeComponent(foodName)}");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["items"] != null && data["items"].isNotEmpty) {
        final item = data["items"][0];
        return FoodItem(
          name: item["name"],
          calories: (item["calories"] ?? 0).toDouble(),
        );
      }
    } else {
      throw Exception(
          "Lỗi server calories: ${response.statusCode} - ${response.body}");
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

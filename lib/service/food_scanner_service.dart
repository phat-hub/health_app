import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
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

  /// Nhận diện thực phẩm bằng ML Kit
  Future<String?> detectFoodName(File image) async {
    final options = ImageLabelerOptions(
      confidenceThreshold: 0.6,
    );
    final imageLabeler = ImageLabeler(options: options);

    final inputImage = InputImage.fromFile(image);
    final labels = await imageLabeler.processImage(inputImage);

    await imageLabeler.close();

    if (labels.isNotEmpty) {
      return labels.first.label;
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
}

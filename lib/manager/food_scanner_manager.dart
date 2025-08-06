import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screen.dart';

class FoodScannerManager extends ChangeNotifier {
  final FoodScannerService _service = FoodScannerService();

  File? _image;
  FoodItem? _foodItem;
  bool _isLoading = false;
  String? _error;

  File? get image => _image;
  FoodItem? get foodItem => _foodItem;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Quét thực phẩm
  Future<void> scanFood(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final image = await _service.pickImageFromCamera();
      if (image == null) {
        _error = "Không chọn được ảnh hoặc chưa cấp quyền camera";
        _showError(context, _error!);
        _isLoading = false;
        notifyListeners();
        return;
      }

      _image = image;

      final foodName = await _service.detectFoodName(image);
      if (foodName == null) {
        _error = "Không nhận diện được thực phẩm";
        _showError(context, _error!);
        _isLoading = false;
        notifyListeners();
        return;
      }

      final item = await _service.fetchCalories(foodName);
      if (item == null) {
        _error = "Không tìm thấy thông tin calo cho '$foodName'";
        _showError(context, _error!);
      } else {
        _foodItem = item;
      }
    } catch (e) {
      _error = e.toString();
      _showError(context, _error!);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Reset trạng thái
  void reset() {
    _image = null;
    _foodItem = null;
    _error = null;
    notifyListeners();
  }

  /// Hiển thị SnackBar lỗi
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

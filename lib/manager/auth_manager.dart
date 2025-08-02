import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screen.dart';

class AuthManager extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get userName => _user?.displayName; // Lấy tên người dùng
  String? get photoURL => _user?.photoURL;
  String? get userId => _user?.uid;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    setLoading(true);
    try {
      _user =
          await _authService.signInWithGoogle(); // Lưu user sau khi đăng nhập
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    setLoading(false);
  }

  Future<void> signOut() async {
    setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Lỗi khi đăng xuất: $e';
    }
    setLoading(false);
    notifyListeners();
  }
}

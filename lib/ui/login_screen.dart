import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../manager/auth_manager.dart';
import '../health_home_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateIfLoggedIn(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HealthHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Tự đổi sáng/tối
      body: SafeArea(
        child: Center(
          child: auth.isLoading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Chào mừng đến với\nỨng dụng Sức Khỏe Cá Nhân',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary, // Dùng màu theme
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await auth.loginWithGoogle();
                          _navigateIfLoggedIn(context);
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Bắt đầu'),
                      ),
                      if (auth.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text(
                            auth.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

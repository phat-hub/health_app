import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'manager/auth_manager.dart';
import 'manager/theme_manager.dart';
import 'theme/app_theme.dart';
import 'ui/login_screen.dart';
import 'manager/heart_rate_manager.dart';
import 'manager/heart_rate_camera_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthManager()),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => HeartRateManager()),
        ChangeNotifierProvider(create: (_) => HeartRateCameraManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ứng dụng Sức Khỏe',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeManager.themeMode,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}

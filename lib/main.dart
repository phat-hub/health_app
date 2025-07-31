import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'manager/auth_manager.dart';
import 'manager/theme_manager.dart';
import 'theme/app_theme.dart';
import 'ui/login_screen.dart';

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

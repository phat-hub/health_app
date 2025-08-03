import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // bật offline
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // không giới hạn cache
  );
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
        ChangeNotifierProvider(create: (_) => StepManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ứng dụng Sức Khỏe',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeManager.themeMode,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HealthHomePage(),
              '/heartRateHistory': (context) => const HeartRateHistoryScreen(),
              '/heartRateCamera': (context) => const HeartRateCameraScreen(),
              '/step': (context) => const StepScreen(),
            },
          );
        },
      ),
    );
  }
}

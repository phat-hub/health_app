import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'screen.dart';

// Tạo instance plugin global
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  await Firebase.initializeApp();

  // 2. Bật Firestore offline
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 3. Khởi tạo timezone cho thông báo lặp
  tz.initializeTimeZones();

  // 4. Khởi tạo thông báo cục bộ
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // 5. Chạy ứng dụng
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
        ChangeNotifierProvider(create: (_) => SleepManager()),
        ChangeNotifierProvider(create: (_) => WaterManager()),
        ChangeNotifierProvider(create: (_) => BloodPressureManager()),
        ChangeNotifierProvider(create: (_) => BloodGlucoseManager()),
        ChangeNotifierProvider(create: (_) => BmiManager()),
        ChangeNotifierProvider(create: (_) => ChatManager()),
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
              '/sleep': (context) => const SleepScreen(),
              '/water': (context) => const WaterScreen(),
              '/waterStats': (context) => const WaterStatsScreen(),
              '/waterReminder': (context) => const WaterReminderScreen(),
              '/stepStats': (context) => const StepStatsScreen(),
              '/bloodPressure': (context) => const BloodPressureScreen(),
              '/bloodPressureAdd': (context) => const BloodPressureAddScreen(),
              '/bloodPressureInfo': (context) =>
                  const BloodPressureInfoScreen(),
              '/bloodGlucose': (context) => const BloodGlucoseScreen(),
              '/bloodGlucoseAdd': (context) => const BloodGlucoseAddScreen(),
              '/bloodGlucoseInfo': (context) => const BloodGlucoseInfoScreen(),
              '/bmi': (context) => const BmiScreen(),
              '/bmiAdd': (context) => const BmiAddScreen(),
              '/bmiInfo': (context) => const BmiInfoScreen(),
              '/aiDoctor': (context) => const AiDoctorScreen(),
              '/chat': (context) => const ChatScreen(),
            },
          );
        },
      ),
    );
  }
}

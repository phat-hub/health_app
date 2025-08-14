import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        ChangeNotifierProvider(create: (_) => FoodScannerManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ứng dụng Sức Khỏe',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeManager.themeMode,
            initialRoute: '/home',
            routes: {
              '/home': (context) => const HealthHomePage(),
              '/heartRateHistory': (context) => const HeartRateHistoryScreen(),
              '/heartRateCamera': (context) => const HeartRateCameraScreen(),
              '/heartRateInfo': (context) => const HeartRateInfoScreen(),
              '/step': (context) => const StepScreen(),
              '/sleep': (context) => const SleepScreen(),
              '/sleepInfo': (context) => const SleepInfoScreen(),
              '/sleepStats': (context) => const SleepStatsScreen(),
              '/water': (context) => const WaterScreen(),
              '/waterStats': (context) => const WaterStatsScreen(),
              '/waterReminder': (context) => const WaterReminderScreen(),
              '/stepStats': (context) => const StepStatsScreen(),
              '/bloodPressure': (context) => const BloodPressureScreen(),
              '/bloodPressureAdd': (context) => const BloodPressureAddScreen(),
              '/bloodPressureInfo': (context) =>
                  const BloodPressureInfoScreen(),
              '/bloodPressureStats': (context) =>
                  const BloodPressureStatsScreen(),
              '/bloodGlucose': (context) => const BloodGlucoseScreen(),
              '/bloodGlucoseAdd': (context) => const BloodGlucoseAddScreen(),
              '/bloodGlucoseInfo': (context) => const BloodGlucoseInfoScreen(),
              '/bloodGlucoseStats': (context) =>
                  const BloodGlucoseStatsScreen(),
              '/bmi': (context) => const BmiScreen(),
              '/bmiAdd': (context) => const BmiAddScreen(),
              '/bmiInfo': (context) => const BmiInfoScreen(),
              '/bmiStats': (context) => const BmiStatsScreen(),
              '/aiDoctor': (context) => const AiDoctorScreen(),
              '/chat': (context) => const ChatScreen(),
              '/foodScanner': (context) => const FoodScannerScreen(),
            },
          );
        },
      ),
    );
  }
}

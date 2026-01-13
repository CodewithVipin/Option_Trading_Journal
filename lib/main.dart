import 'package:flutter/material.dart';
import 'package:heat_map/screens/splash_screen.dart';
import 'package:heat_map/services/theme_service.dart';
import 'package:heat_map/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tradingData');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.notifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          home: const SplashScreen(),
        );
      },
    );
  }
}

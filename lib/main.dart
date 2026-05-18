import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TinyApp());
}

class TinyApp extends StatelessWidget {
  const TinyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiny',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          foregroundColor: AppColors.text,
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pretendard',
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: AppColors.text,
            fontFamily: 'Pretendard',
          ),
          bodyLarge: TextStyle(
            color: AppColors.text,
            fontFamily: 'Pretendard',
          ),
          titleLarge: TextStyle(
            color: AppColors.text,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF7F9FF);

  static const primary = Color(0xFF6F8CFF);
  static const primaryDark = Color(0xFF1E2457);
  static const primaryLight = Color(0xFFEAF1FF);

  static const yellow = Color(0xFFFFF3C4);
  static const green = Color(0xFF58C45C);

  static const card = Colors.white;
  static const border = Color(0xFFE4E9F7);
  static const text = Color(0xFF1E2457);
  static const subText = Color(0xFF7B819A);

  // chat_screen.dart에서 사용하는 이름들
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1E2457);
  static const textSecondary = Color(0xFF7B819A);
  static const success = Color(0xFF58C45C);

  static const primaryGradient = LinearGradient(
    colors: [
      Color(0xFF6F8CFF),
      Color(0xFF8B7CFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
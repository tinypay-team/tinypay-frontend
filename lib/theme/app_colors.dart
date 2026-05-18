import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const background = Color(0xFFF7F9FF);
  static const surface = Colors.white;

  // Tiny Main Colors
  static const primary = Color(0xFF6F8CFF);
  static const primaryDark = Color(0xFF1E2457);
  static const primaryLight = Color(0xFFEAF1FF);

  // Accent Colors
  static const yellow = Color(0xFFFFF3C4);
  static const yellowDeep = Color(0xFFFFC94A);
  static const green = Color(0xFF58C45C);
  static const success = Color(0xFF58C45C);
  static const danger = Color(0xFFFF5A5A);

  // Text
  static const text = Color(0xFF1E2457);
  static const textPrimary = Color(0xFF1E2457);
  static const subText = Color(0xFF7B819A);
  static const textSecondary = Color(0xFF7B819A);

  // Line / Border
  static const border = Color(0xFFE4E9F7);
  static const softBorder = Color(0xFFDCE6FF);

  // Card
  static const card = Colors.white;
  static const cardBlue = Color(0xFFEAF1FF);
  static const cardYellow = Color(0xFFFFF7D8);

  // Gradient
  static const primaryGradient = LinearGradient(
    colors: [
      Color(0xFF6F8CFF),
      Color(0xFF9AAEFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const softGradient = LinearGradient(
    colors: [
      Color(0xFFEAF1FF),
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
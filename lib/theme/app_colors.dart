import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF8F5BFF);
  static const Color accent = Color(0xFF4D9BFF);

  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE8E8F2);

  static const Color textPrimary = Color(0xFF1D1D35);
  static const Color textSecondary = Color(0xFF7A7A93);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
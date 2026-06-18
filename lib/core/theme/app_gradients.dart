import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const primary = LinearGradient(
    colors: [
      AppColors.primaryGreen,
      AppColors.primaryBlue,
    ],
  );

  static const workout = LinearGradient(
    colors: [
      Color(0xFF2979FF),
      Color(0xFF5C6BC0),
    ],
  );

  static const posture = LinearGradient(
    colors: [
      Color(0xFF9C27B0),
      Color(0xFFE91E63),
    ],
  );

  // 🔹 ADD THESE FOR THE NEW FEATURES 🔹
  static const steps = LinearGradient(
    colors: [
      Color(0xFF00C853), // Neon Green
      Color(0xFF64DD17), // Lighter Green
    ],
  );

  static const calories = LinearGradient(
    colors: [
      Color(0xFFFF3D00), // Fiery Orange
      Color(0xFFFF9100), // Amber
    ],
  );
}
import 'package:flutter/material.dart';

class AppColors {
  // Primary accent colors
  static const Color primaryOrange = Color.fromARGB(255, 163, 130, 80);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color glowOrange = Color(0xFFFFAB40);

  // Background colors
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  // Glass effect colors
  static const Color glassWhite = Colors.white;
  static const double glassOpacity = 0.1;
  static const double glassBorderOpacity = 0.2;

  // Gradient for active torch state
  static const List<Color> activeGradient = [
    Color(0xFF1A0800),
    Color(0xFF2D1200),
    Color(0xFF1A0800),
  ];

  // Gradient for inactive state
  static const List<Color> inactiveGradient = [
    Color(0xFF0A0A0A),
    Color(0xFF151515),
    Color(0xFF0A0A0A),
  ];

  // Compass colors
  static const Color compassNorth = Color(0xFFFF5722);
  static const Color compassSouth = Color(0xFF607D8B);
  static const Color compassRing = Color(0xFF424242);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF616161);
}

import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBackground = Color(0xFFFDF5D9); // Light beige
  static const Color primaryYellow = Color(0xFFFFC107); // Amber/honey color
  static const Color primaryOrange = Color(0xFFF57C00); // Dark amber/honey
  static const Color primaryBrown = Color(0xFF8D6E63); // Brown

  // Honeycomb specific colors
  static const Color honeycombLight = Color(0xFFFFD54F); // Light honey
  static const Color honeycombMedium = Color(0xFFFFC107); // Medium honey amber
  static const Color honeycombDark = Color(0xFFFF9800); // Darker honey orange
  static const Color honeycombBrown =
      Color(0xFFE65100); // Deep honey brown for accents

  // Accent colors
  static const Color accentBlack = Color(0xFF212121); // For text
  static const Color accentGrey = Color(0xFF757575); // Secondary text
  static const Color accentLightGrey =
      Color(0xFFEEEEEE); // Light grey for dividers

  // Status colors
  static const Color success = Color(0xFF4CAF50); // Green for success
  static const Color warning = Color(0xFFFF9800); // Orange for warnings
  static const Color error = Color(0xFFE53935); // Red for errors
  static const Color info = Color(0xFF2196F3); // Blue for info

  // Gradient colors
  static const List<Color> honeyGradient = [
    Color(0xFFFFD54F), // Light honey
    Color(0xFFFFC107), // Medium honey amber
    Color(0xFFFF9800), // Darker honey orange
  ];

  // Background colors for different states
  static const Color cardBackground = Colors.white;
  static const Color disabledBackground = Color(0xFFE0E0E0);

  // Transparent color
  static const Color transparent = Colors.transparent;

  // Campaign status colors
  static const Color statusMatched = Color(0xFF64B5F6); // Light Blue
  static const Color statusContractSigned = Color(0xFF4DB6AC); // Teal
  static const Color statusShipped = Color(0xFF9575CD); // Purple
  static const Color statusInProgress = Color(0xFFFFB74D); // Light Orange
  static const Color statusSubmitted = Color(0xFFAED581); // Light Green
  static const Color statusRevision = Color(0xFFFF8A65); // Light Red
  static const Color statusApproved = Color(0xFF4CAF50); // Green
  static const Color statusPaymentReleased = Color(0xFF7986CB); // Indigo
  static const Color statusCompleted = Color(0xFF66BB6A); // Green
}

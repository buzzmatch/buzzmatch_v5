import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  // Heading Styles
  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: AppColors.accentBlack,
        letterSpacing: 0.5,
      );

  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        color: AppColors.accentBlack,
        letterSpacing: 0.3,
      );

  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: AppColors.accentBlack,
        letterSpacing: 0.3,
      );

  static TextStyle get h4 => GoogleFonts.poppins(
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        color: AppColors.accentBlack,
        letterSpacing: 0.2,
      );

  // Body Styles
  static TextStyle get body1 => GoogleFonts.poppins(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: AppColors.accentBlack,
      );

  static TextStyle get body2 => GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AppColors.accentBlack,
      );

  static TextStyle get body3 => GoogleFonts.poppins(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.accentBlack,
      );

  // Button Styles
  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  // Label Styles
  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: AppColors.accentGrey,
      );

  // Caption Styles
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.accentGrey,
      );

  // Specialized Styles
  static TextStyle get subtitle => GoogleFonts.poppins(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: AppColors.accentGrey,
        letterSpacing: 0.15,
      );

  static TextStyle get link => GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryOrange,
        decoration: TextDecoration.underline,
      );

  static TextStyle get error => GoogleFonts.poppins(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      );

  // Helper method to modify any existing style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

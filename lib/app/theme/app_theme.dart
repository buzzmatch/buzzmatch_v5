import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text.dart';

class AppTheme {
  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      // Base colors
      primaryColor: AppColors.primaryYellow,
      primaryColorDark: AppColors.primaryOrange,
      primaryColorLight: AppColors.primaryYellow.withOpacity(0.7),
      scaffoldBackgroundColor: AppColors.primaryBackground,

      // Appbar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accentBlack,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.accentBlack),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: AppText.h3,
      ),

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryYellow,
        secondary: AppColors.primaryOrange,
        surface: Colors.white,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.accentBlack,
        onError: Colors.white,
        brightness: Brightness.light,
      ),

      // Card theme
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: Colors.white,
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryOrange,
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryOrange,
          textStyle: AppText.button,
          side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppText.label,
        hintStyle: AppText.withColor(
            AppText.body2, AppColors.accentGrey.withOpacity(0.7)),
        errorStyle: AppText.error,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryYellow,
        circularTrackColor: AppColors.accentLightGrey,
      ),

      // Tab bar theme
      tabBarTheme: TabBarTheme(
        labelStyle: AppText.withWeight(AppText.body2, FontWeight.w600),
        unselectedLabelStyle: AppText.body2,
        labelColor: AppColors.primaryOrange,
        unselectedLabelColor: AppColors.accentGrey,
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.primaryOrange,
              width: 3.0,
            ),
          ),
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryYellow;
          }
          return Colors.white;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio button theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryYellow;
          }
          return AppColors.accentGrey;
        }),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.accentLightGrey,
        thickness: 1,
        space: 24,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryYellow,
        unselectedItemColor: AppColors.accentGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: Colors.white,
      ),

      // Typography (default text theme)
      textTheme: TextTheme(
        displayLarge: AppText.h1,
        displayMedium: AppText.h2,
        displaySmall: AppText.h3,
        headlineMedium: AppText.h4,
        bodyLarge: AppText.body1,
        bodyMedium: AppText.body2,
        bodySmall: AppText.body3,
        labelLarge: AppText.button,
        titleMedium: AppText.subtitle,
        labelSmall: AppText.caption,
      ),
    );
  }

  // Dark theme (if needed in the future)
  static ThemeData get darkTheme {
    // For future implementation if dark mode is required
    return lightTheme;
  }
}

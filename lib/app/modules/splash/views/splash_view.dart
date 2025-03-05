import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/splash_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and Honeycomb Animation
            SizedBox(
              width: Get.width * 0.6,
              height: Get.width * 0.6,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Honeycomb Animation (using Lottie)
                  Lottie.asset(
                    'assets/animations/honeycomb_animation.json',
                    width: Get.width * 0.6,
                    height: Get.width * 0.6,
                    fit: BoxFit.contain,
                  ),

                  // Logo (Center of the honeycomb)
                  Image.asset(
                    'assets/images/logo.png',
                    width: Get.width * 0.3,
                    height: Get.width * 0.3,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              'BuzzMatch',
              style: AppText.h1.copyWith(
                color: AppColors.honeycombDark,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Connecting Creators & Brands',
              style: AppText.subtitle.copyWith(
                color: AppColors.accentGrey,
              ),
            ),

            const SizedBox(height: 32),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.honeycombMedium),
              backgroundColor: AppColors.accentLightGrey,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

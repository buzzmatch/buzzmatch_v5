import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:buzzmatch_v5/app/modules/welcome/controllers/welcome_controller.dart';
import 'package:buzzmatch_v5/app/theme/app_colors.dart';
import 'package:buzzmatch_v5/app/theme/app_text.dart';
import 'package:buzzmatch_v5/app/theme/hexagon_button.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Language switch button
          Obx(() => TextButton.icon(
                onPressed: controller.toggleLanguage,
                icon: const Icon(
                  Icons.language,
                  color: AppColors.primaryOrange,
                ),
                label: Text(
                  controller.isArabic.value ? 'English' : 'عربي',
                  style: AppText.withColor(
                      AppText.button, AppColors.primaryOrange),
                ),
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Logo at top
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Image.asset(
                'assets/images/logo.png',
                width: Get.width * 0.3,
                height: Get.width * 0.3,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            // Welcome message
            Text(
              'Welcome to BuzzMatch'.tr,
              style: AppText.h2.copyWith(
                color: AppColors.accentBlack,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle/description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Select your role to get started'.tr,
                style: AppText.subtitle,
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // Role selection with hexagonal buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Content Creator Button
                Obx(() => HexagonButton(
                      text: 'Content Creator'.tr,
                      size: 140,
                      icon: Icons.camera_alt_rounded,
                      isSelected:
                          controller.selectedRole.value == UserRole.creator,
                      onPressed: () => controller.selectRole(UserRole.creator),
                    )),

                const SizedBox(width: 24),

                // Brand Button
                Obx(() => HexagonButton(
                      text: 'Brand'.tr,
                      size: 140,
                      icon: Icons.business_rounded,
                      isSelected:
                          controller.selectedRole.value == UserRole.brand,
                      onPressed: () => controller.selectRole(UserRole.brand),
                    )),
              ],
            ),

            const Spacer(),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.continueWithSelectedRole,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: AppColors.honeycombDark,
                  ),
                  child: Text(
                    'Continue'.tr,
                    style: AppText.button,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

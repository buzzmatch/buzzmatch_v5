import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import 'dart:ui';

enum UserRole {
  creator,
  brand,
  none,
}

class WelcomeController extends GetxController {
  // Observable for selected role
  final Rx<UserRole> selectedRole = UserRole.none.obs;

  // Observable for language (Arabic or English)
  final RxBool isArabic = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkCurrentLanguage();
  }

  void _checkCurrentLanguage() {
    // Check if the current locale is Arabic
    isArabic.value = Get.locale?.languageCode == 'ar';
  }

  void toggleLanguage() {
    isArabic.value = !isArabic.value;

    // Update the app locale
    if (isArabic.value) {
      Get.updateLocale(const Locale('ar', 'SA'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  void continueWithSelectedRole() {
    if (selectedRole.value == UserRole.none) {
      Get.snackbar(
        'Selection Required',
        'Please select your role to continue',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to login screen, passing the selected role
    if (selectedRole.value == UserRole.creator) {
      Get.toNamed(Routes.LOGIN, arguments: {'role': 'creator'});
    } else {
      Get.toNamed(Routes.LOGIN, arguments: {'role': 'brand'});
    }
  }
}

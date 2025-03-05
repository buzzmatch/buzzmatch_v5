import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzzmatch_v5/app/routes/app_pages.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get role from arguments
    final String role = Get.arguments?['role'] ?? 'creator';

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Login'.tr,
          style: AppText.h3,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.accentBlack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
              ),

              const SizedBox(height: 24),

              // Title and Description
              Text(
                role == 'brand' ? 'Login as Brand'.tr : 'Login as Creator'.tr,
                style: AppText.h3,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Enter your credentials to continue'.tr,
                style: AppText.subtitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Email Field
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email'.tr,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.accentGrey,
                  ),
                ),
                controller: controller.emailController,
              ),

              const SizedBox(height: 16),

              // Password Field
              Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Password'.tr,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.accentGrey,
                      ),
                    ),
                  )),

              const SizedBox(height: 8),

              // Forgot Password Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Show forgot password dialog
                    _showForgotPasswordDialog(context);
                  },
                  child: Text('Forgot Password?'.tr),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.signInWithEmailAndPassword(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.honeycombDark,
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Login'.tr,
                            style: AppText.button,
                          ),
                  )),

              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: AppColors.accentLightGrey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR'.tr,
                      style: AppText.body2,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: AppColors.accentLightGrey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Google Sign In Button
              OutlinedButton.icon(
                onPressed: () => controller.signInWithGoogle(role),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 24,
                  height: 24,
                ),
                label: Text(
                  'Continue with Google'.tr,
                  style:
                      AppText.withColor(AppText.button, AppColors.accentBlack),
                ),
              ),

              const SizedBox(height: 16),

              // Apple Sign In Button (iOS only)
              OutlinedButton.icon(
                onPressed: () {
                  // Implement Apple Sign In
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.black,
                ),
                icon: const Icon(
                  Icons.apple,
                  color: Colors.white,
                ),
                label: Text(
                  'Continue with Apple'.tr,
                  style: AppText.withColor(AppText.button, Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 24),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?'.tr,
                    style: AppText.body2,
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(Routes.SIGNUP, arguments: {'role': role});
                    },
                    child: Text(
                      'Sign Up'.tr,
                      style: AppText.withColor(
                        AppText.body2,
                        AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Forgot Password Dialog
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Forgot Password'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive a password reset link'.tr,
              style: AppText.body2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                controller.resetPassword(emailController.text.trim());
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.honeycombDark,
            ),
            child: Text('Send'.tr),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class AppText {
  static var h3;

  static var subtitle;

  static var button;

  static var body2;

  static withColor(button, accentBlack) {}
}

class AppColors {
  static var honeycombDark;

  static var primaryBackground;

  static var accentBlack;

  static var accentGrey;

  static var accentLightGrey;

  static var primaryOrange;
}

class AuthController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> resetPassword(String email) async {
    // Implement your password reset logic here
    try {
      isLoading.value = true;
      // Add your password reset implementation
    } catch (e) {
      print('Error resetting password: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    // Implement your sign-in logic here
  }

  Future<void> signInWithGoogle(String role) async {
    // Implement your Google sign-in logic here
  }
}

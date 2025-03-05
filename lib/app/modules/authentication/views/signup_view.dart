import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzzmatch_v5/app/routes/app_pages.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

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
          'Sign Up'.tr,
          style: AppText.h3,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.accentBlack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and Description
              Text(
                role == 'brand'
                    ? 'Register as Brand'.tr
                    : 'Register as Creator'.tr,
                style: AppText.h2,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Create an account to get started'.tr,
                style: AppText.subtitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Form Fields - Different fields based on role
              if (role == 'brand')
                _buildBrandForm(context)
              else
                _buildCreatorForm(context),

              const SizedBox(height: 24),

              // Sign Up Button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.signUpWithEmailAndPassword(role),
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
                            'Sign Up'.tr,
                            style: AppText.button,
                          ),
                  )),

              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  const Expanded(
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
                  const Expanded(
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
              if (Theme.of(context).platform == TargetPlatform.iOS)
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

              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?'.tr,
                    style: AppText.body2,
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(Routes.LOGIN);
                    },
                    child: Text(
                      'Login'.tr,
                      style: AppText.button,
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

  // Form for Brand registration
  Widget _buildBrandForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Company Name
        TextField(
          controller: controller.companyController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Company Name'.tr,
            prefixIcon: const Icon(
              Icons.business,
              color: AppColors.accentGrey,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Email
        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email'.tr,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.accentGrey,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Phone
        TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Phone'.tr,
            prefixIcon: const Icon(
              Icons.phone,
              color: AppColors.accentGrey,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Password
        Obx(() => TextField(
              controller: controller.passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password'.tr,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.accentGrey,
                ),
              ),
            )),
      ],
    );
  }

  // Form for Creator registration
  Widget _buildCreatorForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Username
        TextField(
          controller: controller.usernameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Username'.tr,
            prefixIcon: const Icon(
              Icons.person,
              color: AppColors.accentGrey,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Email
        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email'.tr,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.accentGrey,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Phone
        TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Phone'.tr,
            prefixIcon: const Icon(
              Icons.phone,
              color: AppColors.accentGrey,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Password
        Obx(() => TextField(
              controller: controller.passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password'.tr,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.accentGrey,
                ),
              ),
            )),
      ],
    );
  }
}

class AuthController extends GetxController {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> signUpWithEmailAndPassword(String role) async {
    // Implement your sign-up logic here
  }

  Future<void> signInWithGoogle(String role) async {
    // Implement your Google sign-in logic here
  }
}

class AppText {
  static TextStyle h2 =
      const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static TextStyle h3 =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static TextStyle subtitle = const TextStyle(fontSize: 16, color: Colors.grey);
  static TextStyle button =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static TextStyle body2 = const TextStyle(fontSize: 14, color: Colors.grey);

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}

class AppColors {
  static const Color primaryBackground = Color(0xFFFFFFFF);
  static const Color accentBlack = Color(0xFF000000);
  static const Color accentGrey = Color(0xFF9E9E9E);
  static const Color accentLightGrey = Color(0xFFE0E0E0);
  static const Color honeycombDark = Color(0xFFFFA000);
}

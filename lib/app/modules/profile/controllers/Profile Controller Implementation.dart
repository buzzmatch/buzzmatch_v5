// lib/app/modules/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../authentication/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  // Auth controller
  final AuthController _authController = Get.find<AuthController>();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User profile data
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    bioController = TextEditingController();

    // Load user profile
    loadUserProfile();
  }

  @override
  void onClose() {
    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.onClose();
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    if (_authController.firebaseUser.value != null) {
      try {
        isLoading.value = true;

        final String userId = _authController.firebaseUser.value!.uid;
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          userProfile.value = UserModel.fromFirestore(userDoc);

          // Set controller values
          if (_authController.userRole.value == 'brand') {
            nameController.text = userProfile.value?.companyName ?? '';
          } else {
            nameController.text = userProfile.value?.fullName ?? '';
          }

          emailController.text = userProfile.value?.email ?? '';
          phoneController.text = userProfile.value?.phone ?? '';
          bioController.text = userProfile.value?.id ?? '';
        }
      } catch (e) {
        print('Error loading user profile: $e');
        Get.snackbar(
          'Error',
          'Failed to load profile data',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Update user profile
  Future<void> updateProfile() async {
    if (_authController.firebaseUser.value != null &&
        userProfile.value != null) {
      try {
        isUpdating.value = true;

        final String userId = _authController.firebaseUser.value!.uid;

        // Create updated user data
        Map<String, dynamic> updatedData = {
          'phone': phoneController.text.trim(),
          'bio': bioController.text.trim(),
        };

        // Add role-specific fields
        if (_authController.userRole.value == 'brand') {
          updatedData['companyName'] = nameController.text.trim();
        } else {
          updatedData['fullName'] = nameController.text.trim();
        }

        // Update in Firestore
        await _firestore.collection('users').doc(userId).update(updatedData);

        // Reload profile
        await loadUserProfile();

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.2),
        );
      } catch (e) {
        print('Error updating profile: $e');
        Get.snackbar(
          'Error',
          'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isUpdating.value = false;
      }
    }
  }
}

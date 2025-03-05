import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Observable user
  Rx<User?> firebaseUser = Rx<User?>(null);
  
  // User role (brand or creator)
  RxString userRole = ''.obs;
  
  // Loading state
  RxBool isLoading = false.obs;
  
  // Form controllers
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController companyController;
  late TextEditingController categoryController;
  late TextEditingController countryController;
  late TextEditingController confirmPasswordController;

  get currentUser => null;
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize text controllers
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    companyController = TextEditingController();
    categoryController = TextEditingController();
    countryController = TextEditingController();
    confirmPasswordController = TextEditingController();
    
    // Set up user state listener
    firebaseUser.bindStream(_auth.authStateChanges());
    
    // Check if user is already logged in and get role
    ever(firebaseUser, _setInitialScreen);
  }
  
  @override
  void onClose() {
    // Dispose of text controllers
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    companyController.dispose();
    categoryController.dispose();
    countryController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  // Set initial screen based on auth state
  void _setInitialScreen(User? user) async {
    if (user != null) {
      // User is logged in, get role from Firestore
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          userRole.value = userData['role'] ?? '';
          
          // Navigate to appropriate dashboard
          if (userRole.value == 'brand') {
            Get.offAllNamed(Routes.BRAND_DASHBOARD);
          } else if (userRole.value == 'creator') {
            Get.offAllNamed(Routes.CREATOR_DASHBOARD);
          } else {
            // Role not set, go to welcome screen
            Get.offAllNamed(Routes.WELCOME);
          }
        } else {
          // User document doesn't exist, go to welcome screen
          Get.offAllNamed(Routes.WELCOME);
        }
      } catch (e) {
        print('Error getting user role: $e');
        Get.offAllNamed(Routes.WELCOME);
      }
    }
  }
  
  // Email/Password Sign In
  Future<void> signInWithEmailAndPassword() async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      isLoading.value = false;
      
      // Navigation will be handled by _setInitialScreen
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        _handleAuthError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Email/Password Sign Up
  Future<void> signUpWithEmailAndPassword(String role) async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      // Create user profile in Firestore
      await _createUserProfile(result.user!, role);
      
      isLoading.value = false;
      
      // Navigation will be handled by _setInitialScreen
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        _handleAuthError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Google Sign In
  Future<void> signInWithGoogle(String role) async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        isLoading.value = false;
        return; // User canceled the sign-in flow
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      
      // Check if this is a new user
      if (result.additionalUserInfo?.isNewUser ?? false) {
        // Create user profile in Firestore
        await _createUserProfile(result.user!, role);
      }
      
      isLoading.value = false;
      
      // Navigation will be handled by _setInitialScreen
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        _handleAuthError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      
      // Clear form fields
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      phoneController.clear();
      companyController.clear();
      categoryController.clear();
      countryController.clear();
      confirmPasswordController.clear();
      
      // Navigate to welcome screen
      Get.offAllNamed(Routes.WELCOME);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Success',
        'Password reset email sent. Please check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        _handleAuthError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Create user profile in Firestore
  Future<void> _createUserProfile(User user, String role) async {
    Map<String, dynamic> userData = {
      'email': user.email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    if (role == 'brand') {
      userData.addAll({
        'companyName': companyController.text.trim(),
        'phone': phoneController.text.trim(),
        'businessCategory': categoryController.text.trim(),
        'country': countryController.text.trim(),
      });
    } else if (role == 'creator') {
      userData.addAll({
        'fullName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'contentType': categoryController.text.trim(),
        'country': countryController.text.trim(),
      });
    }
    
    await _firestore.collection('users').doc(user.uid).set(userData);
  }
  
  // Handle authentication errors
  String _handleAuthError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'operation-not-allowed':
          errorMessage = 'This sign-in method is not allowed';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'This email is already registered with a different sign-in method';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        default:
          errorMessage = error.message ?? 'An unexpected error occurred';
      }
    }
    
    return errorMessage;
  }
}
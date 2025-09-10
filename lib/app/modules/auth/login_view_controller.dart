// lib/features/login/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

class LoginViewController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final errorMessage = ''.obs;

  // API response data stored as Map<String, dynamic>
  final loginData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    developer.log('Login controller initialized', name: 'Login');
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('Login controller ready', name: 'Login');
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    developer.log('Login controller disposed', name: 'Login');
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    developer.log('Password visibility toggled: ${isPasswordVisible.value}', name: 'Login.UI');
  }

  // Toggle remember me checkbox
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    developer.log('Remember me toggled: ${rememberMe.value}', name: 'Login.UI');
  }

  // Validate username
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  // Submit login form
  Future<void> submitLogin(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) {
        developer.log('Form validation failed', name: 'Login.Validation');
        return;
      }

      isLoading.value = true;
      developer.log('Starting login submission', name: 'Login');

      // Get form data
      final username = usernameController.text.trim();
      final password = passwordController.text;

      // Create API payload with only username and password
      final loginPayload = {
        'username': username,
        'password': password,
      };

      developer.log('Login payload: ${loginPayload.toString().replaceAll(password, '[HIDDEN]')}', name: 'Login.API');

      // Mock API call - Replace with actual API endpoint
      await Future.delayed(const Duration(seconds: 2));

      // Mock API response - Replace with actual API response
      final response = {
        'success': true,
        'message': 'Login successful',
        'user': {
          'username': username,
          'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
          'lastLogin': DateTime.now().toIso8601String(),
        },
        'rememberMe': rememberMe.value,
      };

      // Store response directly as Map
      loginData.value = response;
      developer.log('Login submission successful: ${response.toString()}', name: 'Login.API');

      // Success handling
      Get.snackbar(
        'Success',
        'Welcome back!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Clear form if not remembering credentials
      if (!rememberMe.value) {
        usernameController.clear();
        passwordController.clear();
      }

      // Navigate to dashboard using Go Router
      if (context.mounted) {
        context.go('/dashboard', );
      }

    } catch (e) {
      developer.log('Login submission error: ${e.toString()}', name: 'Login.Error');
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to forgot password
  void navigateToForgotPassword(BuildContext context) {
    developer.log('Navigating to forgot password', name: 'Login.Navigation');
    context.go('/forgot-password');
  }

  // Navigate back
  void navigateBack(BuildContext context) {
    if (context.canPop()) {
      developer.log('Navigating back', name: 'Login.Navigation');
      context.pop();
    }
  }

  // Get API payload for login
  Map<String, dynamic> getLoginPayload() {
    return {
      'username': usernameController.text.trim(),
      'password': passwordController.text,
    };
  }
}
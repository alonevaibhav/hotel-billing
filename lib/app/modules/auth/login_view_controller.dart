
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../core/utils/snakbar_utils.dart';
import '../../route/app_routes.dart';

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

  // Dummy credentials for different roles
  final Map<String, Map<String, dynamic>> dummyUsers = {
    'waiter': {
      'password': 'waiter',
      'role': 'waiter',
      'name': 'John Waiter',
      'id': 'W001'
    },
    'chef': {
      'password': 'chef',
      'role': 'chef',
      'name': 'Master Chef',
      'id': 'C001'
    },
  };

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

  // Authenticate user with dummy credentials
  Map<String, dynamic>? _authenticateUser(String username, String password) {
    final user = dummyUsers[username];
    if (user != null && user['password'] == password) {
      return {
        'success': true,
        'user': {
          'username': username,
          'name': user['name'],
          'role': user['role'],
          'id': user['id'],
          'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
          'lastLogin': DateTime.now().toIso8601String(),
        },
        'message': 'Login successful'
      };
    }
    return null;
  }

  // Route user based on their role
  void _routeUserByRole(String role) {
    switch (role.toLowerCase()) {
      case 'waiter':
        developer.log('Routing to Waiter Dashboard', name: 'Login.Navigation');
        NavigationService.goToWaiterDashboard();
        break;
      case 'chef':
        developer.log('Routing to Chef Dashboard', name: 'Login.Navigation');
        NavigationService.goToChefDashboard();
        break;
      default:
        developer.log('Unknown role: $role, routing to main dashboard', name: 'Login.Navigation');
        NavigationService.goToLogin();
        break;
    }
  }

  // Submit login form
  Future<void> submitLogin( context) async {
    try {
      if (!formKey.currentState!.validate()) {
        developer.log('Form validation failed', name: 'Login.Validation');
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';
      developer.log('Starting login submission', name: 'Login');

      // Get form data
      final username = usernameController.text.trim();
      final password = passwordController.text;

      developer.log('Attempting login for username: $username', name: 'Login.Auth');

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Authenticate user
      final authResult = _authenticateUser(username, password);

      if (authResult != null) {
        // Store response directly as Map
        loginData.value = authResult;

        final userRole = authResult['user']['role'];
        final userName = authResult['user']['name'];

        developer.log('Authentication successful for $userName (Role: $userRole)', name: 'Login.Auth');

        // Success handling
        SnackBarUtil.showSuccess(
          context,
          'Hello $userName',
          title: 'Welcome Back!',
          duration: const Duration(seconds: 2),
        );

        // Clear form if not remembering credentials
        if (!rememberMe.value) {
          usernameController.clear();
          passwordController.clear();
        }

        // Route user based on their role
        _routeUserByRole(userRole);

      } else {
        // Authentication failed
        developer.log('Authentication failed for username: $username', name: 'Login.Auth');
        errorMessage.value = 'Invalid username or password';

        SnackBarUtil.showError(
          context,
          'Invalid username or password. Please check your credentials.',
          title: 'Login Failed',
          duration: const Duration(seconds: 3),
        );
      }

    } catch (e) {
      developer.log('Login submission error: ${e.toString()}', name: 'Login.Error');
      errorMessage.value = e.toString();

      SnackBarUtil.showError(
        context,
        'Login failed. Please try again.',
        title: 'Error',
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

  // Get current user data
  Map<String, dynamic>? getCurrentUser() {
    return loginData.value?['user'];
  }

  // Get current user role
  String? getCurrentUserRole() {
    return loginData.value?['user']['role'];
  }

  // Check if user is authenticated
  bool get isAuthenticated => loginData.value != null;

  // Logout user
  void logout() {
    loginData.value = null;
    usernameController.clear();
    passwordController.clear();
    rememberMe.value = false;
    errorMessage.value = '';
    developer.log('User logged out', name: 'Login.Auth');
  }

  // Get API payload for login
  Map<String, dynamic> getLoginPayload() {
    return {
      'username': usernameController.text.trim(),
      'password': passwordController.text,
    };
  }

  // Helper method to get available demo credentials (for development/testing)
  String getDemoCredentialsInfo() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Demo Credentials:');
    buffer.writeln('');
    buffer.writeln('WAITER ACCOUNTS:');
    buffer.writeln('Username: waiter123 | Password: waiter@123');
    buffer.writeln('Username: waiter456 | Password: waiter@456');
    buffer.writeln('');
    buffer.writeln('CHEF ACCOUNTS:');
    buffer.writeln('Username: chef123 | Password: chef@123');
    buffer.writeln('Username: chef456 | Password: chef@456');
    return buffer.toString();
  }
}
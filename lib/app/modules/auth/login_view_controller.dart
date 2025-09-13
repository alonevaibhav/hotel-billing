// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:developer' as developer;
// import '../../core/utils/snakbar_utils.dart';
// import '../../data/models/ResponseModel/login_response_model.dart';
// import '../../data/repositories/auth_repository.dart';
// import '../../route/app_routes.dart';
//
// class LoginViewController extends GetxController {
//   // Form key for validation
//   final formKey = GlobalKey<FormState>();
//
//   // Text editing controllers
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   // Observable variables
//   final isLoading = false.obs;
//   final isPasswordVisible = false.obs;
//   final rememberMe = false.obs;
//   final errorMessage = ''.obs;
//
//   // Store login response data
//   final loginResponse = Rxn<LoginResponseModel>();
//   final currentEmployee = Rxn<Employee>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('Login controller initialized', name: 'LoginController');
//   }
//
//   @override
//   void onReady() {
//     super.onReady();
//     developer.log('Login controller ready', name: 'LoginController');
//   }
//
//   @override
//   void onClose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     developer.log('Login controller disposed', name: 'LoginController');
//     super.onClose();
//   }
//
//   // Toggle password visibility
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//     developer.log('Password visibility toggled: ${isPasswordVisible.value}',
//         name: 'LoginController.UI');
//   }
//
//   // Toggle remember me checkbox
//   void toggleRememberMe(bool? value) {
//     rememberMe.value = value ?? false;
//     developer.log('Remember me toggled: ${rememberMe.value}',
//         name: 'LoginController.UI');
//   }
//
//   // Validate username
//   String? validateUsername(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Username is required';
//     }
//     if (value.trim().length < 3) {
//       return 'Username must be at least 3 characters';
//     }
//     return null;
//   }
//
//   // Validate password
//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }
//
//   // Route user based on their role
//   void _routeUserByRole(String role, String employeeName) {
//     switch (role.toLowerCase()) {
//       case 'waiter':
//         developer.log('Routing to Waiter Dashboard',
//             name: 'LoginController.Navigation');
//         NavigationService.goToWaiterDashboard();
//         break;
//       case 'chef':
//         developer.log('Routing to Chef Dashboard',
//             name: 'LoginController.Navigation');
//         NavigationService.goToChefDashboard();
//         break;
//       default:
//         developer.log('Unknown role: $role, routing to default dashboard',
//             name: 'LoginController.Navigation');
//         NavigationService.goToLogin();
//         break;
//     }
//   }
//
//   // Submit login form
//   Future<void> submitLogin(context) async {
//     try {
//       if (!formKey.currentState!.validate()) {
//         developer.log('Form validation failed',
//             name: 'LoginController.Validation');
//         return;
//       }
//
//       isLoading.value = true;
//       errorMessage.value = '';
//       developer.log('Starting login submission', name: 'LoginController');
//
//       // Get form data
//       final username = usernameController.text.trim();
//       final password = passwordController.text;
//
//       developer.log('Attempting login for username: $username',
//           name: 'LoginController.Auth');
//
//       // Call login API through repository
//       final apiResponse = await AuthRepository.login(
//         username: username,
//         password: password,
//       );
//
//       if (apiResponse.success && apiResponse.data != null) {
//         // Store response data
//         loginResponse.value = apiResponse.data!;
//         currentEmployee.value = apiResponse.data!.data.employee;
//
//         final employee = apiResponse.data!.data.employee;
//         final userRole = employee.designation;
//         final userName = employee.employeeName;
//         final organizationName = employee.organizationName;
//
//         developer.log(
//             'Authentication successful for $userName (Role: $userRole) at $organizationName',
//             name: 'LoginController.Auth');
//
//         // Success handling
//         SnackBarUtil.showSuccess(
//           context,
//           'Welcome back, $userName!\nLogged in to $organizationName',
//           title: 'Login Successful!',
//           duration: const Duration(seconds: 3),
//         );
//
//         // Clear form if not remembering credentials
//         if (!rememberMe.value) {
//           usernameController.clear();
//           passwordController.clear();
//         }
//
//         // Small delay to show success message
//         await Future.delayed(const Duration(milliseconds: 1500));
//
//         // Route user based on their role
//         _routeUserByRole(userRole, userName);
//       } else {
//         // Authentication failed
//         final errorMsg = apiResponse.errorMessage ?? 'Login failed';
//         developer.log('Authentication failed: $errorMsg',
//             name: 'LoginController.Auth');
//
//         errorMessage.value = errorMsg;
//
//         SnackBarUtil.showError(
//           context,
//           errorMsg,
//           title: 'Login Failed',
//           duration: const Duration(seconds: 4),
//         );
//       }
//     } catch (e) {
//       developer.log('Login submission error: ${e.toString()}',
//           name: 'LoginController.Error');
//
//       errorMessage.value = e.toString();
//
//       SnackBarUtil.showError(
//         context,
//         'An unexpected error occurred. Please try again.',
//         title: 'Error',
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Navigate to forgot password
//   void navigateToForgotPassword(BuildContext context) {
//     developer.log('Navigating to forgot password', name: 'LoginController.Navigation');
//     context.go('/forgot-password');
//   }
//
//   Future<void> logout() async {
//     try {
//       developer.log('Logging out user', name: 'LoginController.Auth');
//
//       // Clear repository data
//       await AuthRepository.logout();
//
//       // Clear controller data
//       loginResponse.value = null;
//       currentEmployee.value = null;
//       usernameController.clear();
//       passwordController.clear();
//       rememberMe.value = false;
//       errorMessage.value = '';
//
//       developer.log('User logged out successfully',
//           name: 'LoginController.Auth');
//
//       // Navigate to login
//       NavigationService.goToLogin();
//     } catch (e) {
//       developer.log('Logout error: ${e.toString()}',
//           name: 'LoginController.Error');
//     }
//   }
//
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../core/services/session_manager_service.dart';
import '../../core/utils/snakbar_utils.dart';
import '../../data/models/ResponseModel/login_response_model.dart';
import '../../data/repositories/auth_repository.dart';
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

  // Store login response data
  final loginResponse = Rxn<LoginResponseModel>();
  final currentEmployee = Rxn<Employee>();

  @override
  void onInit() {
    super.onInit();
    developer.log('Login controller initialized', name: 'LoginController');
    _startTokenMonitoring();
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('Login controller ready', name: 'LoginController');
    _checkExistingAuthentication();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    TokenManager.stopTokenExpirationTimer();
    developer.log('Login controller disposed', name: 'LoginController');
    super.onClose();
  }

  /// Check if user is already authenticated on app start
  void _checkExistingAuthentication() async {
    final authData = await TokenManager.checkAuthenticationWithRole();

    if (authData['isAuthenticated']) {
      developer.log('User already authenticated, navigating based on role: ${authData['userRole']}', name: 'LoginController');
      _navigateByRole(authData['userRole'], authData['userName']);
    } else {
      developer.log('No valid authentication found, staying on login screen', name: 'LoginController');
    }
  }

  /// Start token expiration monitoring
  void _startTokenMonitoring() {
    TokenManager.startTokenExpirationTimer(
      interval: Duration(minutes: 5),
      onTokenExpired: () {
        _handleTokenExpiration();
      },
    );
  }

  /// Handle token expiration during app usage
  void _handleTokenExpiration() async {
    developer.log('Token expired, logging out user', name: 'LoginController');

    if (Get.context != null) {
      SnackBarUtil.showError(
        Get.context!,
        'Your session has expired. Please login again.',
        title: 'Session Expired',
        duration: const Duration(seconds: 4),
      );
    }

    await logout(sessionExpired: true);
  }

  /// Navigate user based on their role - CLEAN VERSION
  void _navigateByRole(String? role, String? userName) {
    if (role == null) {
      developer.log('No role found, staying on login', name: 'LoginController.Navigation');
      NavigationService.goToLogin();
      return;
    }

    switch (role.toLowerCase()) {
      case 'waiter':
        developer.log('Navigating to Waiter Dashboard for: $userName', name: 'LoginController.Navigation');
        NavigationService.goToWaiterDashboard();
        break;
      case 'chef':
        developer.log('Navigating to Chef Dashboard for: $userName', name: 'LoginController.Navigation');
        NavigationService.goToChefDashboard();
        break;
      default:
        developer.log('Unknown role: $role for $userName, staying on login', name: 'LoginController.Navigation');
        NavigationService.goToLogin();
        break;
    }
  }

  // UI Methods
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    developer.log('Password visibility toggled: ${isPasswordVisible.value}', name: 'LoginController.UI');
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    developer.log('Remember me toggled: ${rememberMe.value}', name: 'LoginController.UI');
  }

  // Validation Methods
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Submit login form - CLEAN VERSION
  Future<void> submitLogin(context) async {
    try {
      if (!formKey.currentState!.validate()) {
        developer.log('Form validation failed', name: 'LoginController.Validation');
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final username = usernameController.text.trim();
      final password = passwordController.text;

      developer.log('Starting login for username: $username', name: 'LoginController');

      final apiResponse = await AuthRepository.login(
        username: username,
        password: password,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Store response data
        loginResponse.value = apiResponse.data!;
        currentEmployee.value = apiResponse.data!.data.employee;

        final employee = apiResponse.data!.data.employee;
        final userRole = employee.designation;
        final userName = employee.employeeName;
        final organizationName = employee.organizationName;

        developer.log('Authentication successful for $userName (Role: $userRole) at $organizationName', name: 'LoginController.Auth');

        // Success handling
        SnackBarUtil.showSuccess(
          context,
          'Welcome back, $userName!\nLogged in to $organizationName',
          title: 'Login Successful!',
          duration: const Duration(seconds: 3),
        );

        // Clear form if not remembering credentials
        if (!rememberMe.value) {
          usernameController.clear();
          passwordController.clear();
        }


        // Navigate based on role using clean method
        _navigateByRole(userRole, userName);
      } else {
        // Authentication failed
        final errorMsg = apiResponse.errorMessage ?? 'Login failed';
        developer.log('Authentication failed: $errorMsg', name: 'LoginController.Auth');

        errorMessage.value = errorMsg;
        SnackBarUtil.showError(
          context,
          errorMsg,
          title: 'Login Failed',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      developer.log('Login submission error: ${e.toString()}', name: 'LoginController.Error');

      errorMessage.value = e.toString();
      SnackBarUtil.showError(
        context,
        'An unexpected error occurred. Please try again.',
        title: 'Error',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigation Methods
  void navigateToForgotPassword(BuildContext context) {
    developer.log('Navigating to forgot password', name: 'LoginController.Navigation');
    context.go('/forgot-password');
  }

  // Logout method with session expired option
  Future<void> logout({bool sessionExpired = false}) async {
    try {
      developer.log('Logging out user (sessionExpired: $sessionExpired)', name: 'LoginController.Auth');

      // Stop token monitoring
      TokenManager.stopTokenExpirationTimer();

      // Clear repository data (this will also clear TokenManager data)
      await AuthRepository.logout();

      // Clear controller data
      loginResponse.value = null;
      currentEmployee.value = null;
      usernameController.clear();
      passwordController.clear();
      rememberMe.value = false;
      errorMessage.value = '';

      developer.log('User logged out successfully', name: 'LoginController.Auth');

      // Navigate to login
      NavigationService.goToLogin();
    } catch (e) {
      developer.log('Logout error: ${e.toString()}', name: 'LoginController.Error');
    }
  }

  // Authentication helper methods
  Future<bool> isAuthenticated() async {
    return await AuthRepository.isAuthenticated();
  }

  Future<String?> getCurrentUserId() async {
    return await AuthRepository.getCurrentUserId();
  }

  Future<String?> getCurrentUserRole() async {
    return await AuthRepository.getCurrentUserRole();
  }

  Future<String?> getCurrentUserName() async {
    return await AuthRepository.getCurrentUserName();
  }
}
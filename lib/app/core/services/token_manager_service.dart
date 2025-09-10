// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Route Manager/app_routes.dart';
// import 'login_view_controller.dart';
//
// class TokenManager {
//   static const String _tokenKey = 'user_token';
//   static const String _tokenExpirationKey = 'token_expiration';
//   static const Duration _defaultExpirationDuration = Duration(days: 30);
//
//   // Add a flag to prevent multiple navigation calls
//   static bool _isNavigating = false;
//
//   // Save token and its expiration time
//   static Future<void> saveToken(String token, {String? expirationTime}) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//
//     // If expiration time is provided, use it; otherwise, set a default expiration time
//     if (expirationTime != null) {
//       await prefs.setString(_tokenExpirationKey, expirationTime);
//     } else {
//       final defaultExpirationTime = DateTime.now().add(_defaultExpirationDuration).toIso8601String();
//       await prefs.setString(_tokenExpirationKey, defaultExpirationTime);
//     }
//   }
//
//   // Get token from SharedPreferences
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }
//
//   // Check if user has a token (logged in)
//   static Future<bool> hasToken() async {
//     final token = await getToken();
//     return token != null && token.isNotEmpty;
//   }
//
//   // Check if token is expired
//   static Future<bool> isTokenExpired() async {
//     // First check if user has a token
//     if (!await hasToken()) {
//       print('No token found, user needs to login.');
//       return true;
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     final expirationTimeString = prefs.getString(_tokenExpirationKey);
//
//     if (expirationTimeString == null) {
//       print('No expiration time found, setting default expiration.');
//       // Set default expiration if not found
//       final defaultExpirationTime = DateTime.now().add(_defaultExpirationDuration).toIso8601String();
//       await prefs.setString(_tokenExpirationKey, defaultExpirationTime);
//       return false; // Token is valid with new expiration
//     }
//
//     try {
//       final expirationTime = DateTime.parse(expirationTimeString);
//       final currentTime = DateTime.now();
//       print('Current Time: $currentTime');
//       print('Expiration Time: $expirationTime');
//
//       return currentTime.isAfter(expirationTime);
//     } catch (e) {
//       print('Error parsing expiration time: $e');
//       return true; // Consider expired if can't parse
//     }
//   }
//
//   // Check token expiration on app startup
//   static Future<void> checkTokenExpiration() async {
//     // Prevent multiple calls
//     if (_isNavigating) {
//       print('Navigation already in progress, skipping...');
//       return;
//     }
//
//     try {
//       _isNavigating = true;
//
//       if (await isTokenExpired()) {
//         print('Token is expired or not found, navigating to login screen...');
//         await _navigateToLogin();
//       } else {
//         print('Token is valid, navigating based on user role...');
//         // Token is not expired, navigate to the appropriate screen based on user role
//         final role = await getUserRole();
//         if (role != null && role.isNotEmpty) {
//           _navigateByRole(role);
//         } else {
//           print('User role not found, navigating to login screen...');
//           await _navigateToLogin();
//         }
//       }
//     } finally {
//       // Allow navigation again after a delay
//       Future.delayed(Duration(seconds: 1), () {
//         _isNavigating = false;
//       });
//     }
//   }
//
//   // Safe navigation to login
//   static Future<void> _navigateToLogin() async {
//     final loginController = Get.isRegistered<LoginViewController>()
//         ? Get.find<LoginViewController>()
//         : Get.put(LoginViewController());
//
//     await loginController.logout(sessionExpired: true);
//   }
//
//   // Get user role from SharedPreferences
//   static Future<String?> getUserRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user_role');
//   }
//
// // Updated navigation method for single dashboard
//   static void _navigateByRole(String role) {
//     // Since you have single routing, always navigate to main dashboard
//     String targetRoute = AppRoutes.mainDashboard;
//
//     if (Get.currentRoute != targetRoute) {
//       print('Navigating to: $targetRoute');
//       Get.offAllNamed(targetRoute);
//     } else {
//       print('Already on target route: $targetRoute');
//     }
//   }
//
//   // Periodically check token expiration
//   static Timer? _tokenExpirationTimer;
//
//   static void startTokenExpirationTimer() {
//     stopTokenExpirationTimer(); // Cancel if already running
//
//     _tokenExpirationTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
//       if (!_isNavigating && await isTokenExpired()) {
//         print('Token expired during periodic check, logging out...');
//         final loginController = Get.isRegistered<LoginViewController>()
//             ? Get.find<LoginViewController>()
//             : Get.put(LoginViewController());
//
//         await loginController.logout(sessionExpired: true);
//       }
//     });
//   }
//
//   static void stopTokenExpirationTimer() {
//     _tokenExpirationTimer?.cancel();
//     _tokenExpirationTimer = null;
//   }
//
//   // Clear token and expiration time on logout
//   static Future<void> clearToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//     await prefs.remove(_tokenExpirationKey);
//     await prefs.remove('user_role'); // Also clear user role
//
//     // Reset navigation flag
//     _isNavigating = false;
//   }
//
//   // Method to refresh token expiration
//   static Future<void> refreshTokenExpiration() async {
//     final prefs = await SharedPreferences.getInstance();
//     final newExpirationTime = DateTime.now().add(_defaultExpirationDuration).toIso8601String();
//     await prefs.setString(_tokenExpirationKey, newExpirationTime);
//     print('Token expiration refreshed to: $newExpirationTime');
//   }
// }
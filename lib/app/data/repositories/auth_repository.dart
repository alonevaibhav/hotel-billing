// // repositories/auth_repository.dart
// import 'dart:developer' as developer;
// import '../../core/constants/api_constant.dart';
// import '../../core/services/api_service.dart';
// import '../models/RequestModel/login_request_model.dart';
// import '../models/ResponseModel/login_response_model.dart';
//
// class AuthRepository {
//
//   /// Login user with username and password
//   static Future<ApiResponse<LoginResponseModel>> login({
//     required String username,
//     required String password,
//   }) async {
//     try {
//       developer.log('Starting login API call for username: $username',
//           name: 'AuthRepository');
//
//       final loginRequest = LoginRequestModel(
//         username: username,
//         password: password,
//       );
//
//       final response = await ApiService.post<LoginResponseModel>(
//         endpoint: hostelBillingLogin,
//         body: loginRequest.toJson(),
//         fromJson: (json) => LoginResponseModel.fromJson(json),
//         includeToken: false, // No token needed for login
//       );
//
//       developer.log('Login API response - Success: ${response.success}',
//           name: 'AuthRepository');
//
//       if (response.success && response.data != null) {
//         // Store token and user ID after successful login
//         final token = response.data!.data.token;
//         final uid = response.data!.data.employee.id.toString();
//
//         await ApiService.setToken(token);
//         await ApiService.setUid(uid);
//
//         developer.log('Stored token: $token and UID: $uid', name: 'AuthRepository');
//
//         developer.log('Token and UID stored successfully',
//             name: 'AuthRepository');
//       }
//
//       return response;
//     } catch (e) {
//       developer.log('Login API call failed: ${e.toString()}',
//           name: 'AuthRepository.Error');
//
//       return ApiResponse<LoginResponseModel>(
//         success: false,
//         errorMessage: e.toString(),
//         statusCode: -1,
//       );
//     }
//   }
//
//   /// Logout user and clear stored data
//   static Future<void> logout() async {
//     try {
//       developer.log('Logging out user', name: 'AuthRepository');
//
//       // Clear stored authentication data
//       await ApiService.clearAuthData();
//
//       developer.log('User logged out successfully', name: 'AuthRepository');
//     } catch (e) {
//       developer.log('Logout error: ${e.toString()}',
//           name: 'AuthRepository.Error');
//     }
//   }
//
//
//
//
// }

// repositories/auth_repository.dart
import 'dart:developer' as developer;
import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../../core/services/session_manager_service.dart';
import '../models/RequestModel/login_request_model.dart';
import '../models/ResponseModel/login_response_model.dart';

class AuthRepository {

  /// Login user with username and password
  static Future<ApiResponse<LoginResponseModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      developer.log('Starting login API call for username: $username',
          name: 'AuthRepository');

      final loginRequest = LoginRequestModel(
        username: username,
        password: password,
      );

      final response = await ApiService.post<LoginResponseModel>(
        endpoint: hostelBillingLogin,
        body: loginRequest.toJson(),
        fromJson: (json) => LoginResponseModel.fromJson(json),
        includeToken: false,
      );

      developer.log('Login API response - Success: ${response.success}',
          name: 'AuthRepository');

      if (response.success && response.data != null) {
        final employee = response.data!.data.employee;
        final token = response.data!.data.token;
        final uid = employee.id.toString();
        final userRole = employee.designation;
        final userName = employee.employeeName;

        // Store in ApiService (existing)
        await ApiService.setToken(token);
        await ApiService.setUid(uid);

        // Store in enhanced TokenManager with all user data
        await TokenManager.saveToken(
          token: token,
          userId: uid,
          userRole: userRole,
          userName: userName,
          // Optional: Add custom expiration if your API provides it
          // expirationTime: response.data!.data.tokenExpiration,
        );

        developer.log('User data stored - ID: $uid, Role: $userRole, Name: $userName',
            name: 'AuthRepository');
      }

      return response;
    } catch (e) {
      developer.log('Login API call failed: ${e.toString()}',
          name: 'AuthRepository.Error');

      return ApiResponse<LoginResponseModel>(
        success: false,
        errorMessage: e.toString(),
        statusCode: -1,
      );
    }
  }

  /// Logout user and clear stored data
  static Future<void> logout() async {
    try {
      developer.log('Logging out user', name: 'AuthRepository');

      // Clear stored authentication data from ApiService
      await ApiService.clearAuthData();

      // Clear from enhanced TokenManager (includes role and name)
      await TokenManager.clearAuthData();

      developer.log('User logged out successfully', name: 'AuthRepository');
    } catch (e) {
      developer.log('Logout error: ${e.toString()}',
          name: 'AuthRepository.Error');
    }
  }

  /// Check if user has valid authentication
  static Future<bool> isAuthenticated() async {
    return await TokenManager.hasValidToken();
  }

  /// Get current user ID
  static Future<String?> getCurrentUserId() async {
    return await TokenManager.getUserId();
  }

  /// Get current user role
  static Future<String?> getCurrentUserRole() async {
    return await TokenManager.getUserRole();
  }

  /// Get current user name
  static Future<String?> getCurrentUserName() async {
    return await TokenManager.getUserName();
  }

  /// Get complete current user data
  static Future<Map<String, String?>> getCurrentUserData() async {
    return await TokenManager.getUserData();
  }
}
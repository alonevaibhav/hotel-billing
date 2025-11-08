import 'dart:developer' as developer;
import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../../core/services/session_manager_service.dart';
import '../../core/services/storage_service.dart';
import '../models/RequestModel/login_request_model.dart';
import '../models/ResponseModel/login_response_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

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

      // Make HTTP POST request
      final response = await http.post(
        Uri.parse('$baseUrl$hostelBillingLogin'), // Replace with your actual base URL
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(loginRequest.toJson()),
      );

      developer.log('Login API response - Status: ${response.statusCode}',
          name: 'AuthRepository');

      // Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponseModel.fromJson(jsonResponse);

        final employee = loginResponse.data.employee;
        final token = loginResponse.data.token;
        final uid = employee.id.toString();
        final userRole = employee.designation;
        final userName = employee.employeeName;
        final organizationName = employee.organizationName;
        final organizationAddress = employee.address;

        // ✅ Store in storage - survives hot reload
        StorageService.to.storeOrganizationData(
          organizationName: organizationName ?? 'Hotel Name',
          organizationAddress: organizationAddress ?? 'Hotel Address',
          userName: userName ?? 'raju',
        );

        // Store in enhanced TokenManager with all user data
        await TokenManager.saveToken(
          token: token,
          userId: uid,
          userRole: userRole,
          userName: userName,
        );

        developer.log(
            'User data stored - ID: $uid, Role: $userRole, Name: $userName',
            name: 'AuthRepository');

        return ApiResponse<LoginResponseModel>(
          success: true,
          data: loginResponse,
          statusCode: response.statusCode,
        );
      } else {
        // Handle error response
        final errorMessage = response.body.isNotEmpty
            ? jsonDecode(response.body)['message'] ?? 'Login failed'
            : 'Login failed';

        return ApiResponse<LoginResponseModel>(
          success: false,
          errorMessage: errorMessage,
          statusCode: response.statusCode,
        );
      }
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

      // Stop token expiration timer if running
      TokenManager.stopTokenExpirationTimer();


      // Clear organization data from StorageService
      StorageService.to.clearOrganizationData();



      developer.log('User logged out successfully', name: 'AuthRepository');
    } catch (e) {
      developer.log('Logout error: ${e.toString()}',
          name: 'AuthRepository.Error');
    }
  }
}

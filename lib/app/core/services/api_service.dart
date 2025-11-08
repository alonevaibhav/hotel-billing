import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });
}

class ApiService {

  static SharedPreferences? _prefs;

  // ==================== Init SharedPreferences ====================
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// ==================== Token Management ====================
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> setUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('uid');
  }
}

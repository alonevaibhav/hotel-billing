import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constant.dart';

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
  static const String baseUrl = ApiConstants.baseUrl;

  static const Duration _timeoutDuration = Duration(seconds: 30);

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

  // ==================== Header Builder ====================
  static Future<Map<String, String>> _getHeaders(
      {bool includeToken = true}) async {
    final token = includeToken ? await getToken() : null;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== Base API Methods ====================

  static Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) fromJson,
    bool includeToken = true,
  }) async {
    final uri =
    Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    final headers = await _getHeaders(includeToken: includeToken);

    return _sendRequest<T>(
      method: 'GET',
      uri: uri,
      fromJson: fromJson,
      requestFunc: () => http.get(uri, headers: headers),
    );
  }

  static Future<ApiResponse<T>> post<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(dynamic) fromJson,
    bool includeToken = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(includeToken: includeToken);

    return _sendRequest<T>(
      method: 'POST',
      uri: uri,
      body: body,
      fromJson: fromJson,
      requestFunc: () =>
          http.post(uri, headers: headers, body: json.encode(body)),
    );
  }

  static Future<ApiResponse<T>> put<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(dynamic) fromJson,
    bool includeToken = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(includeToken: includeToken);

    return _sendRequest<T>(
      method: 'PUT',
      uri: uri,
      body: body,
      fromJson: fromJson,
      requestFunc: () =>
          http.put(uri, headers: headers, body: json.encode(body)),
    );
  }

  // ==================== NEW: PATCH Method ====================
  static Future<ApiResponse<T>> patch<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(dynamic) fromJson,
    bool includeToken = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(includeToken: includeToken);

    return _sendRequest<T>(
      method: 'PATCH',
      uri: uri,
      body: body,
      fromJson: fromJson,
      requestFunc: () =>
          http.patch(uri, headers: headers, body: json.encode(body)),
    );
  }

  static Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    Map<String, dynamic>? body,
    required T Function(dynamic) fromJson,
    bool includeToken = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(includeToken: includeToken);

    return _sendRequest<T>(
      method: 'DELETE',
      uri: uri,
      body: body,
      fromJson: fromJson,
      requestFunc: () => http.delete(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ),
    );
  }

  static Future<ApiResponse<T>> multipartPost<T>({
    required String endpoint,
    required Map<String, String> fields,
    required List<MultipartFiles> files,
    required T Function(dynamic) fromJson,
    bool includeToken = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    _logRequest('MULTIPART POST', uri, body: fields);
    _logFiles(files);

    try {
      final request = http.MultipartRequest('POST', uri);
      final headers = await _getHeaders(includeToken: includeToken);
      headers.remove('Content-Type'); // Remove Content-Type for multipart
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(
          file.field,
          file.filePath,
          contentType: file.contentType,
        ));
      }

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return _handleError('MULTIPART POST', uri, 'No internet connection');
    } on TimeoutException {
      return _handleError('MULTIPART POST', uri, 'Request timeout');
    } catch (e) {
      return _handleError('MULTIPART POST', uri, e.toString());
    }
  }

  // ==================== Multipart PUT Request ====================
  static Future<ApiResponse<T>> multipartPut<T>({
    required String endpoint,
    required Map<String, String> fields,
    required List<MultipartFiles> files,
    required T Function(dynamic) fromJson,
    bool includeToken = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    _logRequest('MULTIPART PUT', uri, body: fields);
    _logFiles(files);

    try {
      final request = http.MultipartRequest('PUT', uri);
      final headers = await _getHeaders(includeToken: includeToken);
      headers.remove('Content-Type'); // Remove Content-Type for multipart
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(
          file.field,
          file.filePath,
          contentType: file.contentType,
        ));
      }

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return _handleError('MULTIPART PUT', uri, 'No internet connection');
    } on TimeoutException {
      return _handleError('MULTIPART PUT', uri, 'Request timeout');
    } catch (e) {
      return _handleError('MULTIPART PUT', uri, e.toString());
    }
  }

  // ==================== NEW: Multipart PATCH Request ====================
  static Future<ApiResponse<T>> multipartPatch<T>({
    required String endpoint,
    required Map<String, String> fields,
    required List<MultipartFiles> files,
    required T Function(dynamic) fromJson,
    bool includeToken = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    _logRequest('MULTIPART PATCH', uri, body: fields);
    _logFiles(files);

    try {
      final request = http.MultipartRequest('PATCH', uri);
      final headers = await _getHeaders(includeToken: includeToken);
      headers.remove('Content-Type'); // Remove Content-Type for multipart
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(
          file.field,
          file.filePath,
          contentType: file.contentType,
        ));
      }

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return _handleError('MULTIPART PATCH', uri, 'No internet connection');
    } on TimeoutException {
      return _handleError('MULTIPART PATCH', uri, 'Request timeout');
    } catch (e) {
      return _handleError('MULTIPART PATCH', uri, e.toString());
    }
  }

  // ==================== Response Handling ====================

  static Future<ApiResponse<T>> _sendRequest<T>({
    required String method,
    required Uri uri,
    required Future<http.Response> Function() requestFunc,
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? body,
  }) async {
    _logRequest(method, uri, body: body);
    try {
      final response = await requestFunc().timeout(_timeoutDuration);
      _logResponse(response);
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return _handleError(method, uri, 'No internet connection');
    } on TimeoutException {
      return _handleError(method, uri, 'Request timeout');
    } catch (e) {
      return _handleError(method, uri, e.toString());
    }
  }

  static ApiResponse<T> _handleResponse<T>(
      http.Response response,
      T Function(dynamic) fromJson,
      ) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    try {
      final jsonResponse = json.decode(responseBody);
      if (statusCode >= 200 && statusCode < 300) {
        _logSuccess(statusCode, jsonResponse);
        return ApiResponse<T>(
          success: true,
          data: fromJson(jsonResponse),
          statusCode: statusCode,
        );
      } else {
        final errorMessage = _extractErrorMessage(jsonResponse);
        _logError('RESPONSE', response.request?.url, errorMessage,
            statusCode: statusCode);
        return ApiResponse<T>(
          success: false,
          errorMessage: errorMessage,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      _logError('RESPONSE PARSING', response.request?.url, e.toString());
      return ApiResponse<T>(
        success: false,
        errorMessage: 'Response parse error: ${e.toString()}',
        statusCode: statusCode,
      );
    }
  }

  static ApiResponse<T> _handleError<T>(
      String method,
      Uri uri,
      String message,
      ) {
    _logError(method, uri, message);
    return ApiResponse<T>(
      success: false,
      errorMessage: message,
      statusCode: -1,
    );
  }

  static String _extractErrorMessage(dynamic jsonResponse) {
    if (jsonResponse is Map<String, dynamic>) {
      final possibleFields = [
        'error',
        'message',
        'errorMessage',
        'error_message',
        'detail',
        'details'
      ];

      for (final field in possibleFields) {
        if (jsonResponse.containsKey(field)) {
          final value = jsonResponse[field];
          if (value is String) {
            return value;
          } else if (value is List) {
            return value.join(', ');
          } else if (value is Map) {
            return json.encode(value);
          }
          return value.toString();
        }
      }
      return json.encode(jsonResponse);
    }
    return 'Unknown error occurred';
  }

  // ==================== Logging Methods ====================

  static void _logRequest(String method, Uri uri,
      {Map<String, dynamic>? body}) {
    if (kDebugMode) {
      print('┌───────────────────────────────────────────────────');
      print('│ 🚀 API REQUEST: $method ${uri.toString()}');
      if (body != null) {
        print('│ 📦 REQUEST BODY: ${json.encode(body)}');
      }
      print('└───────────────────────────────────────────────────');
    }
  }

  static void _logFiles(List<MultipartFiles> files) {
    if (kDebugMode) {
      print('┌───────────────────────────────────────────────────');
      print('│ 📎 UPLOADING FILES:');
      for (var file in files) {
        print(
            '│   - ${file.field}: ${file.filePath} (${file.contentType.toString()})');
      }
      print('└───────────────────────────────────────────────────');
    }
  }

  static void _logResponse(http.Response response) {
    if (kDebugMode) {
      final statusCode = response.statusCode;
      final statusEmoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';

      print('┌───────────────────────────────────────────────────');
      print(
          '│ $statusEmoji API RESPONSE: ${response.request?.method} ${response.request?.url}');
      print('│ 🔢 STATUS CODE: $statusCode');
      try {
        final jsonResponse = json.decode(response.body);
        final prettyJson =
        const JsonEncoder.withIndent('  ').convert(jsonResponse);
        print('│ 📄 RESPONSE BODY:');
        for (var line in prettyJson.split('\n')) {
          print('│   $line');
        }
      } catch (e) {
        print('│ 📄 RESPONSE BODY: ${response.body}');
      }
      print('└───────────────────────────────────────────────────');
    }
  }

  static void _logSuccess(int statusCode, dynamic response) {
    if (kDebugMode) {
      print('┌───────────────────────────────────────────────────');
      print('│ ✅ API CALL SUCCESSFUL: Status $statusCode');
      print('└───────────────────────────────────────────────────');
    }
  }

  static void _logError(String operation, Uri? url, String message,
      {int? statusCode}) {
    if (kDebugMode) {
      print('┌───────────────────────────────────────────────────');
      print('│ ❌ API ERROR: $operation ${url?.toString() ?? ''}');
      if (statusCode != null) {
        print('│ 🔢 STATUS CODE: $statusCode');
      }
      print('│ 🚨 ERROR MESSAGE: $message');
      print('└───────────────────────────────────────────────────');
    }
  }

  // ==================== Debug Method ====================

  static Future<void> debugTokenInfo() async {
    if (kDebugMode) {
      final token = await getToken();
      final uid = await getUid();
      print('┌───────────────────────────────────────────────────');
      print('│ 🔍 DEBUG TOKEN INFO:');
      print('│ 🎫 Token: ${token ?? 'NULL'}');
      print('│ 👤 UID: ${uid ?? 'NULL'}');
      print('│ 📏 Token Length: ${token?.length ?? 0}');
      if (token != null && token.isNotEmpty) {
        print(
            '│ 🔤 Token Preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      }
      print('└───────────────────────────────────────────────────');
    }
  }

  // ==================== File Type Validation ====================

  /// Validates if a file type is supported by the API
  static bool isFileTypeSupported(String filePath) {
    final ext = extension(filePath).toLowerCase().replaceFirst('.', '');
    final supportedTypes = [
      // Images
      'jpg', 'jpeg', 'png', 'gif',
      // Documents
      'pdf', 'doc', 'docx', 'xls', 'xlsx',
      // Videos
      'mp4', 'avi', 'mov', 'wmv', 'mkv', 'flv', 'webm', '3gp', 'm4v'
    ];
    return supportedTypes.contains(ext);
  }

  /// Gets human-readable file type name
  static String getFileTypeName(String filePath) {
    final ext = extension(filePath).toLowerCase().replaceFirst('.', '');
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image';
      case 'pdf':
      case 'doc':
      case 'docx':
        return 'Document';
      case 'xls':
      case 'xlsx':
        return 'Spreadsheet';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'mkv':
      case 'flv':
      case 'webm':
      case '3gp':
      case 'm4v':
        return 'Video';
      default:
        return 'Unknown';
    }
  }
}

class MultipartFiles {
  final String field;
  final String filePath;
  final MediaType contentType;

  MultipartFiles({
    required this.field,
    required this.filePath,
    MediaType? contentType,
  }) : contentType = contentType ?? _detectContentType(filePath);

  static MediaType _detectContentType(String path) {
    final ext = extension(path).toLowerCase().replaceFirst('.', '');
    switch (ext) {
    // Images
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');

    // Documents
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType('application',
            'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType('application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet');

    // Videos
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'wmv':
        return MediaType('video', 'x-ms-wmv');
      case 'mkv':
        return MediaType('video', 'x-matroska');
      case 'flv':
        return MediaType('video', 'x-flv');
      case 'webm':
        return MediaType('video', 'webm');
      case '3gp':
        return MediaType('video', '3gpp');
      case 'm4v':
        return MediaType('video', 'x-m4v');

      default:
        return MediaType('application', 'octet-stream');
    }
  }
}

/*


// ==================== GET - Usage Example ====================
final response = await ApiService.get<xoxo>(
endpoint: ApiConstants.getUserById(userId),
fromJson: (json) => xoxo.fromJson(json),
includeToken: true,
);

// ==================== POST - Usage Example ====================

final response = await ApiService.post<LoginResponseModel>(
  endpoint: ApiConstants.hostelBillingLogin,
  body: loginRequest.toJson(),
  fromJson: (json) => LoginResponseModel.fromJson(json),
  includeToken: false,
);

// ==================== PUT - Usage Example ====================

final response = await ApiService.put<UserResponseModel>(
  endpoint: ApiConstants.updateUser(userId),
  body: updateRequest.toJson(),
  fromJson: (json) => UserResponseModel.fromJson(json),
  includeToken: true,
);


// ==================== DELETE - Usage Example ====================

final response = await ApiService.delete<DeleteResponseModel>(
  endpoint: ApiConstants.deleteAccount,
  body: deleteRequest.toJson(),
  fromJson: (json) => DeleteResponseModel.fromJson(json),
  includeToken: true,
);



// ==================== MULTIPART POST - Usage Example ====================
final fields = {
  'user_id': userId,
  'document_type': 'identity',
  'category': 'verification',
};

final files = [
  MultipartFiles(
    field: 'documents[]',
    filePath: documentPath1,
  ),
  MultipartFiles(
    field: 'documents[]',
    filePath: documentPath2,
  ),
];

final response = await ApiService.multipartPost<DocumentUploadResponseModel>(
  endpoint: ApiConstants.uploadDocuments,
  fields: fields,
  files: files,
  fromJson: (json) => DocumentUploadResponseModel.fromJson(json),
  includeToken: true,
);

// ==================== MULTIPART PUT - Usage Example ====================
final fields = {
  'name': 'Updated Name',
  'email': 'updated@example.com',
  'phone': '1234567890',
};

final files = [
  MultipartFiles(
    field: 'profile_image',
    filePath: newImagePath,
  ),
];

final response = await ApiService.multipartPut<UserResponseModel>(
  endpoint: ApiConstants.updateProfile(userId),
  fields: fields,
  files: files,
  fromJson: (json) => UserResponseModel.fromJson(json),
  includeToken: true,
);




 */

// lib/features/login/models/login_models.dart

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  @override
  String toString() {
    return 'LoginRequest{username: $username, password: [HIDDEN]}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.username == username &&
        other.password == password;
  }

  @override
  int get hashCode => username.hashCode ^ password.hashCode;
}

class LoginResponse {
  final bool success;
  final String message;
  final UserData? user;
  final String? token;
  final String? error;

  LoginResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      token: json['token'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
      'error': error,
    };
  }

  @override
  String toString() {
    return 'LoginResponse{success: $success, message: $message, user: $user, token: ${token != null ? '[HIDDEN]' : null}, error: $error}';
  }
}

class UserData {
  final String username;
  final String? token;
  final String? lastLogin;

  UserData({
    required this.username,
    this.token,
    this.lastLogin,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      username: json['username'] ?? '',
      token: json['token'],
      lastLogin: json['lastLogin'] ?? json['last_login'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'token': token,
      'lastLogin': lastLogin,
    };
  }

  @override
  String toString() {
    return 'UserData{username: $username, token: ${token != null ? '[HIDDEN]' : null}, lastLogin: $lastLogin}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserData &&
        other.username == username &&
        other.token == token &&
        other.lastLogin == lastLogin;
  }

  @override
  int get hashCode => username.hashCode ^ token.hashCode ^ lastLogin.hashCode;
}
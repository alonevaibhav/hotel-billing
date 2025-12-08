// lib/app/core/services/socket_connection_manager.dart
import 'dart:developer' as developer;
import 'package:get/get.dart';
import '../../core/constants/api_constant.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/storage_service.dart';

/// Manages socket connections to prevent duplicates and handle connection lifecycle
class SocketConnectionManager extends GetxService {
  static SocketConnectionManager get instance => Get.find<SocketConnectionManager>();

  final SocketService _socketService = SocketService.instance;
  final isConnected = false.obs;

  // ✅ Track connection attempts to prevent duplicates
  bool _connectionInProgress = false;

  /// Initialize the socket connection manager
  static Future<SocketConnectionManager> init() async {
    final manager = SocketConnectionManager();
    Get.put(manager);
    return manager;
  }

  /// Connect to socket with duplicate prevention
  Future<bool> connect({
    required String serverUrl,
    required int hotelOwnerId,
    required String role,
    required int userId,
    required String employeeName,
    String? authToken,
  }) async {
    // ✅ Prevent duplicate connections
    if (_socketService.isConnected) {
      developer.log(
        '✅ Socket already connected, skipping duplicate connection',
        name: 'SocketConnectionManager',
      );
      isConnected.value = true;
      return true;
    }

    // ✅ Prevent concurrent connection attempts
    if (_connectionInProgress) {
      developer.log(
        '⚠️ Connection already in progress, waiting...',
        name: 'SocketConnectionManager',
      );

      // Wait for existing connection attempt to complete
      int attempts = 0;
      while (_connectionInProgress && attempts < 10) {
        await Future.delayed(Duration(milliseconds: 500));
        attempts++;
      }

      isConnected.value = _socketService.isConnected;
      return _socketService.isConnected;
    }

    try {
      _connectionInProgress = true;

      developer.log(
        '🔌 Initiating socket connection...',
        name: 'SocketConnectionManager',
      );

      await _socketService.connect(
        serverUrl: serverUrl,
        hotelOwnerId: hotelOwnerId,
        role: role,
        userId: userId,
        employeeName: employeeName,
        authToken: authToken,
      );

      // ✅ Setup connection state listeners (not duplicate event listeners)
      _setupConnectionStateListeners();

      // Wait for connection to establish
      await Future.delayed(Duration(milliseconds: 1500));

      isConnected.value = _socketService.isConnected;

      if (isConnected.value) {
        developer.log(
          '✅ Socket connection successful',
          name: 'SocketConnectionManager',
        );
      } else {
        developer.log(
          '⚠️ Socket initiated but not yet connected. Check backend server.',
          name: 'SocketConnectionManager',
        );
      }

      return isConnected.value;
    } catch (e) {
      developer.log(
        '❌ Socket connection failed: $e',
        name: 'SocketConnectionManager',
      );
      isConnected.value = false;
      return false;
    } finally {
      _connectionInProgress = false;
    }
  }

  /// Connect using stored authentication data
  Future<bool> connectFromAuthData(Map<String, dynamic> authData) async {
    if (!authData['isAuthenticated']) {
      developer.log(
        '⚠️ User not authenticated, cannot connect socket',
        name: 'SocketConnectionManager',
      );
      return false;
    }

    final employeeData = StorageService.to.getEmployeeData();

    if (employeeData == null) {
      developer.log(
        '⚠️ No employee data found, cannot connect socket',
        name: 'SocketConnectionManager',
      );
      return false;
    }

    return await connect(
      serverUrl: ApiConstants.socketBaseUrl,
      hotelOwnerId: employeeData['hotelOwnerId'] ?? 0,
      role: authData['userRole'] ?? 'waiter',
      userId: employeeData['id'] ?? 0,
      employeeName: authData['userName'] ?? 'User',
      authToken: authData['token'],
    );
  }

  /// Setup connection state listeners (only for state management, not socket events)
  void _setupConnectionStateListeners() {
    // Listen to high-level connection events for state updates
    _socketService.on('authenticated', (data) {
      isConnected.value = true;
      developer.log(
        '✅ Connection authenticated',
        name: 'SocketConnectionManager',
      );
    });

    _socketService.on('authentication_error', (data) {
      isConnected.value = false;
      developer.log(
        '❌ Authentication failed: $data',
        name: 'SocketConnectionManager',
      );
    });
  }

  /// Disconnect socket
  void disconnect() {
    if (!_socketService.isConnected) {
      developer.log(
        '⚠️ Socket already disconnected',
        name: 'SocketConnectionManager',
      );
      return;
    }

    developer.log(
      '🔌 Disconnecting socket...',
      name: 'SocketConnectionManager',
    );

    _socketService.disconnect();
    isConnected.value = false;
    _connectionInProgress = false;

    developer.log(
      '✅ Socket disconnected successfully',
      name: 'SocketConnectionManager',
    );
  }

  /// Reconnect socket (disconnect and connect again)
  Future<bool> reconnect({
    required String serverUrl,
    required int hotelOwnerId,
    required String role,
    required int userId,
    required String employeeName,
    String? authToken,
  }) async {
    developer.log(
      '🔄 Reconnecting socket...',
      name: 'SocketConnectionManager',
    );

    disconnect();
    await Future.delayed(Duration(milliseconds: 1000)); // Wait before reconnecting

    return await connect(
      serverUrl: serverUrl,
      hotelOwnerId: hotelOwnerId,
      role: role,
      userId: userId,
      employeeName: employeeName,
      authToken: authToken,
    );
  }

  /// Check if socket is connected
  bool get connectionStatus => _socketService.isConnected;

  /// Get the underlying socket service
  SocketService get socketService => _socketService;

  /// Get detailed connection information
  Map<String, dynamic> getConnectionInfo() {
    final info = _socketService.getConnectionInfo();
    return {
      ...info,
      'managerConnected': isConnected.value,
      'connectionInProgress': _connectionInProgress,
    };
  }

  /// Reset connection state (useful for debugging/testing)
  void resetConnectionState() {
    _connectionInProgress = false;
    isConnected.value = _socketService.isConnected;
    developer.log(
      '🔄 Connection state reset. Current status: ${getConnectionInfo()}',
      name: 'SocketConnectionManager',
    );
  }
}

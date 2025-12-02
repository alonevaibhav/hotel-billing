// lib/app/core/services/socket_service.dart
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  bool _isConnected = false;

  // Callbacks for different events
  final Map<String, List<Function>> _eventListeners = {};

  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  SocketService._internal();

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  /// Initialize and connect to socket server
  Future<void> connect({
    required String serverUrl,
    required int hotelOwnerId,
    required String role,
    required int userId,
    required String employeeName,
    String? authToken,
  }) async {
    if (_socket != null && _isConnected) {
      developer.log('Socket already connected', name: 'SOCKET_SERVICE');
      return;
    }

    // If socket exists but not connected, dispose it first
    if (_socket != null) {
      developer.log('Disposing existing socket instance', name: 'SOCKET_SERVICE');
      _socket!.dispose();
      _socket = null;
    }

    try {
      developer.log(
        'Connecting to socket: $serverUrl',
        name: 'SOCKET_SERVICE',
      );

      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      // ✅ Setup listeners BEFORE connection happens
      _setupEventHandlers(
        hotelOwnerId: hotelOwnerId,
        role: role,
        userId: userId,
        employeeName: employeeName,
      );

      // Connection will happen automatically due to enableAutoConnect()
      developer.log(
        '⏳ Socket initialized, waiting for connection...',
        name: 'SOCKET_SERVICE',
      );

    } catch (e) {
      developer.log('❌ Socket connection error: $e', name: 'SOCKET_SERVICE');
      _isConnected = false;
      rethrow;
    }
  }

  /// Setup core event handlers
  void _setupEventHandlers({
    required int hotelOwnerId,
    required String role,
    required int userId,
    required String employeeName,
  }) {
    // ✅ Connection established
    _socket!.onConnect((_) {
      _isConnected = true;
      developer.log('✅ Socket connected successfully', name: 'SOCKET_SERVICE');

      // Join hotel room AFTER connection is confirmed
      _socket!.emit('join', {
        'hotelOwnerId': hotelOwnerId,
        'role': role,
        'id': userId,
        'employeeName': employeeName,
      });

      developer.log(
        '📤 Emitted join event - User: $employeeName, Role: $role, HotelID: $hotelOwnerId',
        name: 'SOCKET_SERVICE',
      );
    });

    // ✅ Disconnection handler
    _socket!.onDisconnect((_) {
      _isConnected = false;
      developer.log('🔌 Socket disconnected', name: 'SOCKET_SERVICE');
    });

    // ✅ Connection error handler
    _socket!.onConnectError((error) {
      _isConnected = false;
      developer.log('❌ Connection error: $error', name: 'SOCKET_SERVICE');
    });

    // ✅ Generic error handler
    _socket!.onError((error) {
      developer.log('❌ Socket error: $error', name: 'SOCKET_SERVICE');
    });

    // ✅ Reconnection attempt
    _socket!.on('reconnect_attempt', (attempt) {
      developer.log('🔄 Reconnection attempt: $attempt', name: 'SOCKET_SERVICE');
    });

    // ✅ Reconnection success
    _socket!.on('reconnect', (attempt) {
      _isConnected = true;
      developer.log('✅ Reconnected after $attempt attempts', name: 'SOCKET_SERVICE');
    });

    // ✅ Reconnection failed
    _socket!.on('reconnect_failed', (_) {
      _isConnected = false;
      developer.log('❌ Reconnection failed', name: 'SOCKET_SERVICE');
    });

    // ✅ Authentication events
    _socket!.on('authenticated', (data) {
      developer.log('✅ Authenticated: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('authenticated', data);
    });

    _socket!.on('authentication_error', (data) {
      developer.log('❌ Auth error: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('authentication_error', data);
    });

    // ✅ Join room confirmation
    _socket!.on('join_success', (data) {
      developer.log('✅ Successfully joined room: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('join_success', data);
    });

    // Order-related events
    _socket!.on('new_order', (data) {
      developer.log('🔔 New order received: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('new_order', data);
    });

    _socket!.on('order_status_update', (data) {
      developer.log('📊 Order status update: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('order_status_update', data);
    });

    _socket!.on('payment_update', (data) {
      developer.log('💰 Payment update: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('payment_update', data);
    });

    _socket!.on('table_booking', (data) {
      developer.log('🪑 Table booking: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('table_booking', data);
    });

    // Acknowledgment events
    _socket!.on('placeOrder_ack', (data) {
      developer.log('✅ Order placed: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('placeOrder_ack', data);
    });

    _socket!.on('placeOrder_error', (data) {
      developer.log('❌ Order error: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('placeOrder_error', data);
    });

    _socket!.on('updateOrderStatus_ack', (data) {
      developer.log('✅ Status updated: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('updateOrderStatus_ack', data);
    });
  }

  /// Register event listener
  void on(String event, Function callback) {
    if (!_eventListeners.containsKey(event)) {
      _eventListeners[event] = [];
    }
    _eventListeners[event]!.add(callback);

    developer.log(
      'Registered listener for event: $event',
      name: 'SOCKET_SERVICE',
    );
  }

  /// Unregister event listener
  void off(String event, [Function? callback]) {
    if (callback == null) {
      _eventListeners.remove(event);
      developer.log(
        'Removed all listeners for event: $event',
        name: 'SOCKET_SERVICE',
      );
    } else {
      _eventListeners[event]?.remove(callback);
      developer.log(
        'Removed specific listener for event: $event',
        name: 'SOCKET_SERVICE',
      );
    }
  }

  /// Notify all listeners for an event
  void _notifyListeners(String event, dynamic data) {
    if (_eventListeners.containsKey(event)) {
      for (var callback in _eventListeners[event]!) {
        try {
          callback(data);
        } catch (e) {
          developer.log(
            'Error in listener callback for $event: $e',
            name: 'SOCKET_SERVICE',
          );
        }
      }
    }
  }

  /// Emit event to server
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
      developer.log(
        '📤 Emitted event: $event with data: $data',
        name: 'SOCKET_SERVICE',
      );
    } else {
      developer.log(
        '⚠️ Cannot emit "$event" - socket not connected (isConnected: $_isConnected)',
        name: 'SOCKET_SERVICE',
      );
    }
  }

  /// Update order status via socket
  void updateOrderStatus({
    required int orderId,
    required String status,
    required int hotelOwnerId,
    String? updatedBy,
  }) {
    emit('updateOrderStatus', {
      'orderId': orderId,
      'status': status,
      'hotelOwnerId': hotelOwnerId,
      'updatedBy': updatedBy,
    });
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket != null) {
      developer.log('Disconnecting socket', name: 'SOCKET_SERVICE');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _eventListeners.clear();

      developer.log('✅ Socket disconnected and disposed', name: 'SOCKET_SERVICE');
    } else {
      developer.log('⚠️ Socket already null', name: 'SOCKET_SERVICE');
    }
  }

  /// Reconnect socket
  void reconnect() {
    if (_socket != null && !_isConnected) {
      developer.log('Reconnecting socket', name: 'SOCKET_SERVICE');
      _socket!.connect();
    } else if (_socket == null) {
      developer.log(
        '⚠️ Cannot reconnect - socket is null. Use connect() instead.',
        name: 'SOCKET_SERVICE',
      );
    } else {
      developer.log(
        '⚠️ Socket already connected',
        name: 'SOCKET_SERVICE',
      );
    }
  }

  /// Check connection status with detailed info
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'socketExists': _socket != null,
      'activeListeners': _eventListeners.length,
    };
  }
}

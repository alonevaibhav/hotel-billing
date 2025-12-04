import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../../../data/models/ResponseModel/ready_order_model.dart';
import '../../../data/repositories/ready_order_repository.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../core/services/notification_service.dart';
import '../../service/socket_connection_manager.dart';
import '../../widgets/notifications_widget.dart';

class ReadyOrderController extends GetxController {
  // Repository
  final ReadyOrderRepository _repository = ReadyOrderRepository();

  // Reactive state variables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final ordersData = <OrderDetail>[].obs;
  final errorMessage = ''.obs;
  final expandedOrders = <int>{}.obs;
  final isSocketConnected = false.obs;

  // Raw API response
  ReadyOrderResponse? _readyOrderResponse;

  // Socket & debounce
  final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
  Timer? _refreshDebounceTimer;
  final _refreshDebounceDelay = const Duration(milliseconds: 500);
  bool _isRefreshing = false;
  final Set<String> _processedEvents = {};

  // Notification service
  final NotificationService _notificationService = NotificationService.instance;

  @override
  void onInit() {
    super.onInit();
    developer.log('ReadyOrderController initialized', name: 'ReadyOrders');
    _setupSocketListeners();
    isSocketConnected.value = _socketManager.connectionStatus;
    fetchReadyOrders();
  }

  @override
  void onClose() {
    _refreshDebounceTimer?.cancel();
    _removeSocketListeners();
    developer.log('ReadyOrderController disposed', name: 'ReadyOrders');
    super.onClose();
  }

  /// ==================== SOCKET SETUP ====================

  void _setupSocketListeners() {
    developer.log('🔌 Setting up socket listeners', name: 'ReadyOrders.Socket');
    _removeSocketListeners();

    final eventHandlers = {
      'order_ready_to_serve': _handleOrderReadyToServe,
      'order_status_update': _handleOrderStatusUpdate,
      'order_served': _handleOrderServed,
      'order_completed': _handleOrderCompleted,
      'new_order': _handleGenericUpdate,
      'placeOrder_ack': _handleGenericUpdate,
    };

    eventHandlers.forEach((event, handler) {
      _socketManager.socketService.on(event, handler);
      developer.log('Registered listener for: $event', name: 'ReadyOrders.Socket');
    });

    ever(_socketManager.isConnected, _onSocketConnectionChanged);

    developer.log('✅ ${eventHandlers.length} socket listeners registered', name: 'ReadyOrders.Socket');
  }

  void _removeSocketListeners() {
    final events = [
      'order_ready_to_serve',
      'order_status_update',
      'order_served',
      'order_completed',
      'new_order',
      'placeOrder_ack',
    ];
    events.forEach(_socketManager.socketService.off);
    developer.log('✅ Socket listeners removed', name: 'ReadyOrders.Socket');
  }

  void _onSocketConnectionChanged(bool connected) {
    isSocketConnected.value = connected;
    developer.log('Socket connection: $connected', name: 'ReadyOrders.Socket');

    if (Get.context != null) {
      SnackBarUtil.show(
        Get.context!,
        connected ? 'Real-time updates enabled' : 'Real-time updates disconnected',
        title: connected ? '✅ Connected' : '⚠️ Disconnected',
        type: connected ? SnackBarType.success : SnackBarType.warning,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// ==================== SOCKET EVENT HANDLERS ====================

  void _handleOrderReadyToServe(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('🍽️ ORDER READY TO SERVE EVENT', name: 'ReadyOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
    final eventId = 'ready-$orderId-$timestamp';

    if (_isDuplicateEvent(eventId)) return;

    final tableNumber = _extractTableNumber(orderData);
    final message = data['message'] ?? 'Order is ready to serve for Table $tableNumber';

    developer.log('📋 Order #$orderId ready - Table $tableNumber', name: 'ReadyOrders.Socket');
    _debouncedRefreshOrders();

    // Show notification for ready to serve
    showReadyToServeNotification(orderId, tableNumber);

    if (Get.context != null && orderId > 0) {
      SnackBarUtil.showSuccess(
        Get.context!,
        message,
        title: '🍽️ Ready to Serve - Table $tableNumber',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _handleOrderStatusUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('📊 ORDER STATUS UPDATE EVENT', name: 'ReadyOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final status = orderData['status'] ?? orderData['order_status'];
    final tableNumber = _extractTableNumber(orderData);

    developer.log('Status received: $status for order #$orderId', name: 'ReadyOrders.Socket');

    if (status == 'ready_to_serve' || status == 'ready' || status == 'served' || status == 'completed') {
      _debouncedRefreshOrders();

      // Show notification based on status
      if (status == 'ready_to_serve' || status == 'ready') {
        showReadyToServeNotification(orderId, tableNumber);
      } else if (status == 'served') {
        showOrderServedNotification(orderId, tableNumber);
      } else if (status == 'completed') {
        showOrderCompletedNotification(orderId, tableNumber);
      }

      if ((status == 'served' || status == 'completed') && orderId > 0) {
        _removeOrderFromList(orderId);
      }
    }
  }

  void _handleOrderServed(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('✅ ORDER SERVED EVENT', name: 'ReadyOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final tableNumber = _extractTableNumber(orderData);

    _debouncedRefreshOrders();

    if (orderId > 0) {
      _removeOrderFromList(orderId);
    }

    // Show notification for served order
    showOrderServedNotification(orderId, tableNumber);

    if (Get.context != null) {
      SnackBarUtil.showSuccess(
        Get.context!,
        'Order served successfully',
        title: '✅ Table $tableNumber',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _handleOrderCompleted(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('🎉 ORDER COMPLETED EVENT', name: 'ReadyOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final tableNumber = _extractTableNumber(orderData);

    _debouncedRefreshOrders();

    if (orderId > 0) {
      _removeOrderFromList(orderId);
    }

    // Show notification for completed order
    showOrderCompletedNotification(orderId, tableNumber);
  }

  void _handleGenericUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('📊 Generic update event', name: 'ReadyOrders.Socket');
    _debouncedRefreshOrders();

    // Show generic update notification
    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final tableNumber = _extractTableNumber(orderData);


  }


  /// ==================== HELPER METHODS ====================

  Map<String, dynamic>? _parseSocketData(dynamic rawData) {
    try {
      return rawData is Map ? Map<String, dynamic>.from(rawData) : {};
    } catch (e) {
      developer.log('❌ Parse error: $e', name: 'ReadyOrders.Socket.Error');
      return null;
    }
  }

  bool _isDuplicateEvent(String eventId) {
    if (_processedEvents.contains(eventId)) {
      developer.log('⏭️ SKIPPING duplicate: $eventId', name: 'ReadyOrders.Socket');
      return true;
    }
    _processedEvents.add(eventId);
    if (_processedEvents.length > 50) _processedEvents.clear();
    return false;
  }

  int _extractOrderId(Map<String, dynamic>? data) {
    return data?['id'] ?? data?['order_id'] ?? data?['orderId'] ?? 0;
  }

  String _extractTableNumber(Map<String, dynamic>? data) {
    return data?['table_number']?.toString() ??
        data?['tableNumber']?.toString() ??
        'Unknown';
  }

  void _removeOrderFromList(int orderId) {
    try {
      ordersData.removeWhere((orderDetail) => orderDetail.order.id == orderId);
      developer.log('✅ Order #$orderId removed from list', name: 'ReadyOrders.Socket');
    } catch (e, stackTrace) {
      developer.log('❌ Remove error: $e\n$stackTrace', name: 'ReadyOrders.Socket.Error');
    }
  }

  void _debouncedRefreshOrders() {
    developer.log('🔄 Debouncing refresh...', name: 'ReadyOrders.Socket');
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
      if (!_isRefreshing) {
        developer.log('⏰ Executing debounced refresh', name: 'ReadyOrders.Socket');
        fetchReadyOrders();
      } else {
        developer.log('⏭️ Skipping refresh - already in progress', name: 'ReadyOrders.Socket');
      }
    });
  }

  /// ==================== API METHODS ====================

  Future<void> fetchReadyOrders({bool isRefresh = false}) async {
    if (_isRefreshing) {
      developer.log('⏭️ Already refreshing', name: 'ReadyOrders');
      return;
    }

    try {
      _isRefreshing = true;
      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final apiResponse = await _repository.getReadyToServeOrders();

      if (apiResponse.success && apiResponse.data != null) {
        _readyOrderResponse = apiResponse.data;

        if (_readyOrderResponse?.success == true) {
          ordersData.value = _readyOrderResponse!.data.orders;
          developer.log('✅ ${ordersData.length} ready orders loaded', name: 'ReadyOrders');
        } else {
          errorMessage.value = _readyOrderResponse?.message ?? 'Failed to fetch orders';
        }
      } else {
        errorMessage.value = apiResponse.errorMessage ?? 'Failed to fetch orders';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      developer.log('❌ Fetch error: $e', name: 'ReadyOrders.Error');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      _isRefreshing = false;
    }
  }

  /// ==================== PUBLIC METHODS ====================

  Future<void> refreshOrders() async {
    developer.log('♻️ Manual refresh', name: 'ReadyOrders');
    await fetchReadyOrders(isRefresh: true);
  }

  void toggleOrderExpansion(int tableId) {
    if (expandedOrders.contains(tableId)) {
      expandedOrders.remove(tableId);
    } else {
      expandedOrders.add(tableId);
    }
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  int getTotalItemsCount(List<OrderItem> items) {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  OrderDetail? getOrderByTableId(int tableId) {
    try {
      return ordersData.firstWhere((order) => order.order.hotelTableId == tableId);
    } catch (e) {
      return null;
    }
  }

  OrderDetail? getOrderByOrderId(int orderId) {
    try {
      return ordersData.firstWhere((order) => order.order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Getters
  bool get socketConnected => isSocketConnected.value;
  int get totalReadyOrders => ordersData.length;
  Map<String, dynamic> getSocketInfo() => _socketManager.getConnectionInfo();
}
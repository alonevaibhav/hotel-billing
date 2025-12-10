//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:developer' as developer;
// import '../../../core/utils/snakbar_utils.dart';
// import '../../../data/repositories/pending_orders_repository.dart';
// import '../../../data/models/ResponseModel/pending_orders_model.dart';
// import '../../service/socket_connection_manager.dart';
// import '../../../core/services/notification_service.dart';
// import '../../widgets/notifications_widget.dart';
//
// class AcceptOrderController extends GetxController {
//   final PendingOrdersRepository _repository;
//   final notificationService = NotificationService.instance;
//
//   AcceptOrderController({PendingOrdersRepository? repository})
//       : _repository = repository ?? PendingOrdersRepository();
//
//   // Reactive state variables
//   final isLoading = false.obs;
//   final ordersData = <GroupedOrder>[].obs;
//   final errorMessage = ''.obs;
//   final rejectionReason = ''.obs;
//   final rejectionCategory = 'out_of_stock'.obs;
//   final isRejectDialogVisible = false.obs;
//   final selectedOrderId = Rxn<int>();
//   final selectedItemId = Rxn<int>(); // NEW: Track selected item for rejection
//   final expandedOrders = <int>{}.obs;
//   final processingItems = <int>{}.obs; // NEW: Track items being processed
//
//   final TextEditingController reasonController = TextEditingController();
//
//   final isSocketConnected = false.obs;
//   final Set<int> _notifiedOrders = {};
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchPendingOrders();
//     _setupSocketListeners();
//   }
//
//   @override
//   void onClose() {
//     _removeSocketListeners();
//     reasonController.dispose();
//     super.onClose();
//   }
//
//   void _setupSocketListeners() {
//     try {
//       final socketService = SocketConnectionManager.instance.socketService;
//       isSocketConnected.value = socketService.isConnected;
//
//       developer.log(
//         '🔌 Setting up socket listeners for AcceptOrderController',
//         name: 'AcceptOrderController',
//       );
//
//       socketService.on('new_order', _handleNewOrder);
//       socketService.on('order_status_update', _handleOrderStatusUpdate);
//       socketService.on('item_status_update', _handleItemStatusUpdate);
//       socketService.on('order_items_added', _handleOrderItemsAdded);
//       socketService.on('authenticated', (data) {
//         isSocketConnected.value = true;
//         developer.log('✅ Socket authenticated', name: 'AcceptOrderController');
//       });
//
//       developer.log(
//         '✅ Socket listeners registered successfully',
//         name: 'AcceptOrderController',
//       );
//     } catch (e) {
//       developer.log(
//         '❌ Error setting up socket listeners: $e',
//         name: 'AcceptOrderController',
//       );
//     }
//   }
//
//   void _removeSocketListeners() {
//     try {
//       final socketService = SocketConnectionManager.instance.socketService;
//
//       developer.log(
//         '🔌 Removing socket listeners for AcceptOrderController',
//         name: 'AcceptOrderController',
//       );
//
//       socketService.off('new_order', _handleNewOrder);
//       socketService.off('order_status_update', _handleOrderStatusUpdate);
//       socketService.off('item_status_update', _handleItemStatusUpdate);
//       socketService.off('order_items_added', _handleOrderItemsAdded);
//
//       developer.log(
//         '✅ Socket listeners removed successfully',
//         name: 'AcceptOrderController',
//       );
//     } catch (e) {
//       developer.log(
//         '❌ Error removing socket listeners: $e',
//         name: 'AcceptOrderController',
//       );
//     }
//   }
//
//   void _handleNewOrder(dynamic data) {
//     developer.log(
//       '🔔 NEW ORDER RECEIVED: $data',
//       name: 'AcceptOrderController',
//     );
//
//     try {
//       final orderData = data['data'] ?? data;
//       final orderInfo = orderData['order'] ?? orderData;
//
//       final orderId = (orderInfo['id'] ??
//           orderInfo['order_id'] ??
//           orderData['orderId'] ??
//           orderData['id']) as int? ?? 0;
//
//       if (orderId == 0) {
//         developer.log(
//           '⚠️ Invalid order ID in new order event',
//           name: 'AcceptOrderController',
//         );
//         return;
//       }
//
//       developer.log(
//         '📥 Processing new order #$orderId, will show notification after grouping',
//         name: 'AcceptOrderController',
//       );
//
//       fetchPendingOrdersWithNotification(orderId);
//
//     } catch (e) {
//       developer.log(
//         '❌ Error handling new order: $e',
//         name: 'AcceptOrderController',
//       );
//     }
//   }
//
//   void _handleOrderStatusUpdate(dynamic data) {
//     developer.log(
//       '📊 ORDER STATUS UPDATE: $data',
//       name: 'AcceptOrderController',
//     );
//
//     try {
//       final orderId = data['orderId'] as int?;
//       final newStatus = data['status'] as String?;
//
//       if (orderId == null || newStatus == null) {
//         developer.log(
//           '⚠️ Invalid order status update data',
//           name: 'AcceptOrderController',
//         );
//         return;
//       }
//
//       if (newStatus != 'pending') {
//         final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
//         if (orderIndex != -1) {
//           ordersData.removeAt(orderIndex);
//           _notifiedOrders.remove(orderId);
//           developer.log(
//             '✅ Removed order #$orderId from pending list (status: $newStatus)',
//             name: 'AcceptOrderController',
//           );
//         }
//       } else {
//         fetchPendingOrders();
//       }
//     } catch (e) {
//       developer.log(
//         '❌ Error handling order status update: $e',
//         name: 'AcceptOrderController',
//       );
//     }
//   }
//
//   void _handleItemStatusUpdate(dynamic data) {
//     developer.log(
//       '🍽️ ITEM STATUS UPDATE: $data',
//       name: 'AcceptOrderController',
//     );
//
//     try {
//       final orderId = data['orderId'] as int?;
//       final itemId = data['itemId'] as int?;
//       final newStatus = data['status'] as String?;
//
//       if (orderId == null || itemId == null || newStatus == null) {
//         developer.log(
//           '⚠️ Invalid item status update data',
//           name: 'AcceptOrderController',
//         );
//         return;
//       }
//
//       // Remove from processing items
//       processingItems.remove(itemId);
//
//       if (newStatus != 'pending') {
//         final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
//
//         if (orderIndex != -1) {
//           final order = ordersData[orderIndex];
//           order.items.removeWhere((item) => item.id == itemId);
//
//           if (order.items.isEmpty) {
//             ordersData.removeAt(orderIndex);
//             _notifiedOrders.remove(orderId);
//             developer.log(
//               '✅ Removed order #$orderId (no more pending items)',
//               name: 'AcceptOrderController',
//             );
//           } else {
//             ordersData[orderIndex] = order;
//             ordersData.refresh();
//             developer.log(
//               '✅ Updated order #$orderId (removed item #$itemId)',
//               name: 'AcceptOrderController',
//             );
//           }
//         }
//       }
//     } catch (e) {
//       developer.log(
//         '❌ Error handling item status update: $e',
//         name: 'AcceptOrderController',
//       );
//     }
//   }
//
//   void _handleOrderItemsAdded(dynamic data) {
//     developer.log(
//       '➕ ORDER ITEMS ADDED: $data',
//       name: 'AcceptOrderController',
//     );
//
//     try {
//       final orderId = data['orderId'] as int? ?? 0;
//
//       if (orderId == 0) return;
//
//       developer.log(
//         '📥 Processing items added to order #$orderId',
//         name: 'AcceptOrderController',
//       );
//
//       fetchPendingOrdersWithNotification(orderId, isItemsAdded: true);
//     } catch (e) {
//       developer.log(
//         '❌ Error handling order items added: $e',
//         name: 'AcceptOrderController',
//       );
//     }
//   }
//
//   Future<void> fetchPendingOrdersWithNotification(
//       int triggeredOrderId, {
//         bool isItemsAdded = false,
//       }) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final groupedOrders = await _repository.getPendingOrders();
//       ordersData.value = groupedOrders;
//
//       developer.log(
//         '✅ Fetched and grouped ${groupedOrders.length} pending orders',
//         name: 'AcceptOrderController',
//       );
//
//       final triggeredOrder = groupedOrders.firstWhereOrNull(
//               (order) => order.orderId == triggeredOrderId
//       );
//
//       if (triggeredOrder != null) {
//         if (!_notifiedOrders.contains(triggeredOrderId)) {
//           _notifiedOrders.add(triggeredOrderId);
//
//           if (_notifiedOrders.length > 50) {
//             final toRemove = _notifiedOrders.take(_notifiedOrders.length - 50).toList();
//             _notifiedOrders.removeAll(toRemove);
//           }
//
//           await showGroupedOrderNotification(
//             groupedOrder: triggeredOrder,
//             isItemsAdded: isItemsAdded,
//           );
//
//           developer.log(
//             '✅ Notification shown for grouped order #${triggeredOrder.orderId} '
//                 'with ${triggeredOrder.totalItemsCount} items',
//             name: 'AcceptOrderController',
//           );
//         } else {
//           developer.log(
//             '⏸️ Skipping notification for order #$triggeredOrderId (already notified)',
//             name: 'AcceptOrderController',
//           );
//         }
//       } else {
//         developer.log(
//           '⚠️ Could not find grouped order for ID #$triggeredOrderId',
//           name: 'AcceptOrderController',
//         );
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error fetching pending orders with notification: $e',
//         name: 'AcceptOrderController',
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> fetchPendingOrders() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final groupedOrders = await _repository.getPendingOrders();
//       ordersData.value = groupedOrders;
//
//       developer.log(
//         '✅ Fetched ${groupedOrders.length} pending orders',
//         name: 'AcceptOrderController',
//       );
//     } catch (e) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error fetching pending orders: $e',
//         name: 'AcceptOrderController',
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> refreshOrders() async {
//     await fetchPendingOrders();
//   }
//
//   void toggleOrderExpansion(int orderId) {
//     if (expandedOrders.contains(orderId)) {
//       expandedOrders.remove(orderId);
//     } else {
//       expandedOrders.add(orderId);
//     }
//   }
//
//   /// NEW: Accept individual item
//   Future<void> acceptItem(int orderId, int itemId) async {
//     try {
//       processingItems.add(itemId);
//       errorMessage.value = '';
//
//       await _repository.updateOrderItemStatus(
//         orderId: orderId,
//         itemId: itemId,
//         status: 'preparing',
//       );
//
//       developer.log(
//         '✅ Item #$itemId accepted and moved to preparing',
//         name: 'AcceptOrderController',
//       );
//
//       // Remove item from the order locally
//       _removeItemFromOrder(orderId, itemId);
//
//     } catch (e) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error accepting item #$itemId: $e',
//         name: 'AcceptOrderController',
//       );
//
//       Get.snackbar(
//         'Error',
//         'Failed to accept item',
//         backgroundColor: Colors.red[100],
//         colorText: Colors.red[900],
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 2),
//       );
//     } finally {
//       processingItems.remove(itemId);
//     }
//   }
//
//   /// NEW: Show rejection dialog for individual item
//   void showRejectDialogForItem(int orderId, int itemId) {
//     selectedOrderId.value = orderId;
//     selectedItemId.value = itemId;
//     isRejectDialogVisible.value = true;
//     reasonController.clear();
//     rejectionReason.value = '';
//     rejectionCategory.value = 'out_of_stock';
//   }
//
//   /// Hide rejection dialog
//   void hideRejectDialog() {
//     isRejectDialogVisible.value = false;
//     selectedOrderId.value = null;
//     selectedItemId.value = null;
//     reasonController.clear();
//     rejectionReason.value = '';
//     rejectionCategory.value = 'out_of_stock';
//   }
//
//   void updateRejectionReason(String reason) {
//     rejectionReason.value = reason;
//   }
//
//   void updateRejectionCategory(String category) {
//     rejectionCategory.value = category;
//   }
//
//   /// NEW: Reject individual item
//   /// NEW: Reject individual item
//   Future<void> rejectItem(BuildContext context) async {
//     if (reasonController.text.trim().isEmpty) {
//       SnackBarUtil.showWarning(
//         context,
//         'Please provide a reason for rejecting the item',
//         title: 'Reason Required',
//         duration: const Duration(seconds: 2),
//       );
//       return;
//     }
//
//     if (selectedOrderId.value == null || selectedItemId.value == null) return;
//
//     // ✅ Store values before they get cleared
//     final orderId = selectedOrderId.value!;
//     final itemId = selectedItemId.value!;
//     final reason = reasonController.text.trim();
//     final category = rejectionCategory.value;
//
//     try {
//       processingItems.add(itemId);
//       errorMessage.value = '';
//
//       await _repository.rejectOrderItem(
//         orderId: orderId,
//         itemId: itemId,
//         rejectionReason: reason,
//         rejectionCategory: category,
//       );
//
//       hideRejectDialog(); // Now safe to call
//
//       SnackBarUtil.showSuccess(
//         context,
//         'Item has been rejected',
//         title: 'Item Rejected',
//         duration: const Duration(seconds: 2),
//       );
//
//       // Remove item from the order locally
//       _removeItemFromOrder(orderId, itemId);
//
//       developer.log(
//         '✅ Item #$itemId rejected - Reason: $reason, Category: $category',
//         name: 'AcceptOrderController',
//       );
//     } catch (e) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error rejecting item: $e',
//         name: 'AcceptOrderController',
//       );
//
//       SnackBarUtil.showError(
//         context,
//         'Failed to reject item: ${e.toString()}',
//         title: 'Rejection Failed',
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       // ✅ Use the stored itemId instead of selectedItemId.value
//       processingItems.remove(itemId);
//     }
//   }
//   /// Helper method to remove item from local order data
//   void _removeItemFromOrder(int orderId, int itemId) {
//     final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
//
//     if (orderIndex != -1) {
//       final order = ordersData[orderIndex];
//       order.items.removeWhere((item) => item.id == itemId);
//
//       if (order.items.isEmpty) {
//         // Remove entire order if no items left
//         ordersData.removeAt(orderIndex);
//         _notifiedOrders.remove(orderId);
//         developer.log(
//           '✅ Removed order #$orderId (no more pending items)',
//           name: 'AcceptOrderController',
//         );
//       } else {
//         // Update the order with remaining items
//         ordersData[orderIndex] = order;
//         ordersData.refresh();
//         developer.log(
//           '✅ Updated order #$orderId (removed item #$itemId)',
//           name: 'AcceptOrderController',
//         );
//       }
//     }
//   }
//
//   String formatCurrency(double amount) {
//     return '₹${amount.toStringAsFixed(2)}';
//   }
//
//   String? validateRejectionReason(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please provide a reason for rejection';
//     }
//     if (value.trim().length < 10) {
//       return 'Reason must be at least 10 characters long';
//     }
//     if (value.trim().length > 500) {
//       return 'Reason cannot exceed 500 characters';
//     }
//     return null;
//   }
//
//   void reconnectSocket() {
//     try {
//       developer.log(
//         '🔄 Attempting manual socket reconnection',
//         name: 'AcceptOrderController',
//       );
//
//       SocketConnectionManager.instance.socketService.reconnect();
//
//       Future.delayed(const Duration(seconds: 2), () {
//         _setupSocketListeners();
//       });
//     } catch (e) {
//       developer.log(
//         '❌ Error reconnecting socket: $e',
//         name: 'AcceptOrderController',
//       );
//     }
//   }
//
//   String getSocketStatus() {
//     final info = SocketConnectionManager.instance.getConnectionInfo();
//     return '''
// Socket Connected: ${info['isConnected']}
// Socket Exists: ${info['socketExists']}
// Manager Connected: ${info['managerConnected']}
// Active Listeners: ${info['activeListeners']}
// Connection In Progress: ${info['connectionInProgress']}
//     ''';
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/repositories/pending_orders_repository.dart';
import '../../../data/models/ResponseModel/pending_orders_model.dart';
import '../../service/socket_connection_manager.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/notifications_widget.dart';

class AcceptOrderController extends GetxController {
  final PendingOrdersRepository _repository;
  final notificationService = NotificationService.instance;

  AcceptOrderController({PendingOrdersRepository? repository})
      : _repository = repository ?? PendingOrdersRepository();

  // Reactive state variables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final ordersData = <GroupedOrder>[].obs;
  final errorMessage = ''.obs;
  final rejectionReason = ''.obs;
  final rejectionCategory = 'out_of_stock'.obs;
  final isRejectDialogVisible = false.obs;
  final selectedOrderId = Rxn<int>();
  final selectedItemId = Rxn<int>();
  final expandedOrders = <int>{}.obs;
  final processingItems = <int>{}.obs;
  final isSocketConnected = false.obs;

  final TextEditingController reasonController = TextEditingController();

  // Socket & debounce
  final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
  Timer? _refreshDebounceTimer;
  final _refreshDebounceDelay = const Duration(milliseconds: 500);
  bool _isRefreshing = false;
  final Set<String> _processedEvents = {};
  final Set<int> _notifiedOrders = {};

  @override
  void onInit() {
    super.onInit();
    developer.log('AcceptOrderController initialized', name: 'AcceptOrders');

    // ✅ CRITICAL: Add catch-all listener to see ALL events
    _setupDebugListener();

    _setupSocketListeners();
    isSocketConnected.value = _socketManager.connectionStatus;
    fetchPendingOrders();
  }

  @override
  void onClose() {
    _refreshDebounceTimer?.cancel();
    _removeSocketListeners();
    reasonController.dispose();
    developer.log('AcceptOrderController disposed', name: 'AcceptOrders');
    super.onClose();
  }

  /// ==================== DEBUG LISTENER ====================

  /// ✅ CRITICAL: Catch-all listener to see EVERY socket event
  void _setupDebugListener() {
    developer.log('🔍 Setting up debug listener for ALL events', name: 'AcceptOrders.Debug');

    _socketManager.socketService.socket?.onAny((event, data) {
      developer.log(
          '🔔 [DEBUG] Socket event received:\n'
              'Event: $event\n'
              'Data: $data',
          name: 'AcceptOrders.Debug'
      );

      // Log the data structure
      if (data != null) {
        developer.log(
            '📋 [DEBUG] Data type: ${data.runtimeType}\n'
                'Data content: ${data.toString()}',
            name: 'AcceptOrders.Debug'
        );
      }

      // ✅ TEST: Manually call handlers to verify they work
      if (event == 'new_order' || event == 'placeOrder_ack') {
        developer.log('🧪 [TEST] Manually calling handler for $event',
            name: 'AcceptOrders.Debug');
        _handleNewOrder(data);
      }
    });
  }

  /// ==================== SOCKET SETUP ====================

  void _setupSocketListeners() {
    developer.log('🔌 Setting up socket listeners', name: 'AcceptOrders.Socket');
    _removeSocketListeners();

    // ✅ FIXED: Direct registration with comprehensive event coverage
    final events = {
      'new_order': _handleNewOrder,
      'placeOrder_ack': _handleNewOrder,
      'order_placed': _handleNewOrder,
      'order_created': _handleNewOrder,
      'order_status_update': _handleOrderStatusUpdate,
      'order_status_change': _handleOrderStatusUpdate,
      'item_status_update': _handleItemStatusUpdate,
      'item_status_change': _handleItemStatusUpdate,
      'order_items_added': _handleOrderItemsAdded,
      'items_added': _handleOrderItemsAdded,
      'order_update': _handleGenericUpdate,
    };

    events.forEach((eventName, handler) {
      _socketManager.socketService.on(eventName, (dynamic data) {
        developer.log('🎯 Event "$eventName" triggered, calling handler...',
            name: 'AcceptOrders.Socket');
        try {
          handler(data);
          developer.log('✅ Handler completed for: $eventName',
              name: 'AcceptOrders.Socket');
        } catch (e, stackTrace) {
          developer.log('❌ Handler error for $eventName: $e\n$stackTrace',
              name: 'AcceptOrders.Socket.Error');
        }
      });
      developer.log('✓ Registered: $eventName', name: 'AcceptOrders.Socket');
    });

    // Monitor socket connection state
    ever(_socketManager.isConnected, _onSocketConnectionChanged);

    developer.log('✅ ${events.length} socket listeners registered',
        name: 'AcceptOrders.Socket');
  }

  void _removeSocketListeners() {
    final events = [
      'new_order',
      'placeOrder_ack',
      'order_placed',
      'order_created',
      'order_status_update',
      'order_status_change',
      'item_status_update',
      'item_status_change',
      'order_items_added',
      'items_added',
      'order_update',
    ];
    events.forEach(_socketManager.socketService.off);
    developer.log('✅ Socket listeners removed', name: 'AcceptOrders.Socket');
  }

  void _onSocketConnectionChanged(bool connected) {
    isSocketConnected.value = connected;
    developer.log('Socket connection: $connected', name: 'AcceptOrders.Socket');

    if (connected) {
      // Refresh data when socket reconnects
      _debouncedRefreshOrders();
    }
  }

  /// ==================== SOCKET EVENT HANDLERS ====================

  void _handleNewOrder(dynamic rawData) {
    developer.log('🔔 NEW ORDER HANDLER CALLED', name: 'AcceptOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) {
      developer.log('❌ Failed to parse socket data', name: 'AcceptOrders.Socket');
      return;
    }

    developer.log('✅ Data parsed successfully', name: 'AcceptOrders.Socket');

    try {
      final orderData = data['data'] ?? data;
      final orderInfo = orderData['order'] ?? orderData;

      final orderId = _extractOrderId(orderInfo) ??
          _extractOrderId(orderData) ??
          _extractOrderId(data) ?? 0;

      final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
      final eventId = 'new-order-$orderId-$timestamp';

      developer.log(
          '📊 Extracted data: orderId=$orderId',
          name: 'AcceptOrders.Socket'
      );

      if (orderId == 0) {
        developer.log('⚠️ Invalid order ID in new order event', name: 'AcceptOrders.Socket');
        return;
      }

      if (_isDuplicateEvent(eventId)) {
        developer.log('⏭️ Duplicate event detected: $eventId', name: 'AcceptOrders.Socket');
        return;
      }

      developer.log(
        '📥 Processing new order #$orderId, will show notification after grouping',
        name: 'AcceptOrders.Socket',
      );

      // Debounced refresh with notification
      _debouncedRefreshOrdersWithNotification(orderId);

    } catch (e, stackTrace) {
      developer.log(
        '❌ Error handling new order: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
    }
  }

  void _handleOrderStatusUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('📊 ORDER STATUS UPDATE EVENT', name: 'AcceptOrders.Socket');

    try {
      final orderData = data['data'] ?? data;
      final orderId = _extractOrderId(orderData) ?? 0;
      final newStatus = orderData['status'] ?? orderData['order_status'];

      final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
      final eventId = 'status-update-$orderId-$newStatus-$timestamp';

      if (_isDuplicateEvent(eventId)) {
        developer.log('⏭️ Duplicate status update: $eventId', name: 'AcceptOrders.Socket');
        return;
      }

      developer.log('Status: $newStatus for order #$orderId', name: 'AcceptOrders.Socket');

      if (orderId == 0 || newStatus == null) {
        developer.log('⚠️ Invalid order status update data', name: 'AcceptOrders.Socket');
        return;
      }

      if (newStatus != 'pending') {
        // Order moved out of pending state
        final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
        if (orderIndex != -1) {
          ordersData.removeAt(orderIndex);
          _notifiedOrders.remove(orderId);
          ordersData.refresh();
          developer.log(
            '✅ Removed order #$orderId from pending list (status: $newStatus)',
            name: 'AcceptOrders.Socket',
          );
        }
      } else {
        // Refresh to get updated data
        _debouncedRefreshOrders();
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error handling order status update: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
    }
  }

  void _handleItemStatusUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('🍽️ ITEM STATUS UPDATE EVENT', name: 'AcceptOrders.Socket');

    try {
      final itemData = data['data'] ?? data;
      final orderId = _extractOrderId(itemData) ?? 0;
      final itemId = itemData['itemId'] ?? itemData['item_id'] ?? itemData['id'] ?? 0;
      final newStatus = itemData['status'] ?? itemData['item_status'];

      final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
      final eventId = 'item-status-$orderId-$itemId-$newStatus-$timestamp';

      if (_isDuplicateEvent(eventId)) {
        developer.log('⏭️ Duplicate item update: $eventId', name: 'AcceptOrders.Socket');
        return;
      }

      developer.log('Item #$itemId status: $newStatus for order #$orderId',
          name: 'AcceptOrders.Socket');

      if (orderId == 0 || itemId == 0 || newStatus == null) {
        developer.log('⚠️ Invalid item status update data', name: 'AcceptOrders.Socket');
        return;
      }

      // Remove from processing items
      processingItems.remove(itemId);

      if (newStatus != 'pending') {
        _removeItemFromOrder(orderId, itemId);
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error handling item status update: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
    }
  }

  void _handleOrderItemsAdded(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('➕ ORDER ITEMS ADDED EVENT', name: 'AcceptOrders.Socket');

    try {
      final orderData = data['data'] ?? data;
      final orderId = _extractOrderId(orderData) ?? 0;

      final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
      final eventId = 'items-added-$orderId-$timestamp';

      if (_isDuplicateEvent(eventId)) {
        developer.log('⏭️ Duplicate items added: $eventId', name: 'AcceptOrders.Socket');
        return;
      }

      if (orderId == 0) {
        developer.log('⚠️ Invalid order ID in items added event', name: 'AcceptOrders.Socket');
        return;
      }

      developer.log(
        '📥 Processing items added to order #$orderId',
        name: 'AcceptOrders.Socket',
      );

      _debouncedRefreshOrdersWithNotification(orderId, isItemsAdded: true);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error handling order items added: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
    }
  }

  void _handleGenericUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('📊 Generic update event', name: 'AcceptOrders.Socket');
    _debouncedRefreshOrders();
  }

  /// ==================== HELPER METHODS ====================

  Map<String, dynamic>? _parseSocketData(dynamic rawData) {
    try {
      return rawData is Map ? Map<String, dynamic>.from(rawData) : {};
    } catch (e) {
      developer.log('❌ Parse error: $e', name: 'AcceptOrders.Socket.Error');
      return null;
    }
  }

  bool _isDuplicateEvent(String eventId) {
    if (_processedEvents.contains(eventId)) {
      developer.log('⏭️ SKIPPING duplicate: $eventId', name: 'AcceptOrders.Socket');
      return true;
    }
    _processedEvents.add(eventId);

    // Clean up old events (keep last 100)
    if (_processedEvents.length > 100) {
      final toRemove = _processedEvents.take(_processedEvents.length - 100).toList();
      _processedEvents.removeAll(toRemove);
    }
    return false;
  }

  int? _extractOrderId(Map<String, dynamic>? data) {
    if (data == null) return null;

    return data['id'] ??
        data['order_id'] ??
        data['orderId'] ??
        data['orderid'];
  }

  void _removeItemFromOrder(int orderId, int itemId) {
    try {
      final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);

      if (orderIndex != -1) {
        final order = ordersData[orderIndex];
        order.items.removeWhere((item) => item.id == itemId);

        if (order.items.isEmpty) {
          // Remove entire order if no items left
          ordersData.removeAt(orderIndex);
          _notifiedOrders.remove(orderId);
          developer.log(
            '✅ Removed order #$orderId (no more pending items)',
            name: 'AcceptOrders',
          );
        } else {
          // Update the order with remaining items
          ordersData[orderIndex] = order;
          ordersData.refresh();
          developer.log(
            '✅ Updated order #$orderId (removed item #$itemId)',
            name: 'AcceptOrders',
          );
        }
      }
    } catch (e, stackTrace) {
      developer.log('❌ Remove item error: $e\n$stackTrace',
          name: 'AcceptOrders.Error');
    }
  }

  void _debouncedRefreshOrders() {
    developer.log('🔄 Debouncing refresh... (timer will fire in ${_refreshDebounceDelay.inMilliseconds}ms)',
        name: 'AcceptOrders.Socket');
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
      developer.log('⏰ Debounce timer fired!', name: 'AcceptOrders.Socket');
      if (!_isRefreshing) {
        developer.log('⏰ Executing debounced refresh - calling fetchPendingOrders()',
            name: 'AcceptOrders.Socket');
        fetchPendingOrders();
      } else {
        developer.log('⏭️ Skipping refresh - already in progress',
            name: 'AcceptOrders.Socket');
      }
    });
  }

  void _debouncedRefreshOrdersWithNotification(int orderId, {bool isItemsAdded = false}) {
    developer.log('🔄 Debouncing refresh with notification...',
        name: 'AcceptOrders.Socket');
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
      if (!_isRefreshing) {
        fetchPendingOrdersWithNotification(orderId, isItemsAdded: isItemsAdded);
      }
    });
  }

  /// ==================== API METHODS ====================

  Future<void> fetchPendingOrdersWithNotification(
      int triggeredOrderId, {
        bool isItemsAdded = false,
      }) async {
    if (_isRefreshing) {
      developer.log('⏭️ Already refreshing - skipping', name: 'AcceptOrders');
      return;
    }

    try {
      _isRefreshing = true;
      isLoading.value = true;
      errorMessage.value = '';

      developer.log('📡 Calling repository.getPendingOrders()', name: 'AcceptOrders');
      final groupedOrders = await _repository.getPendingOrders();

      developer.log(
        '✅ Fetched and grouped ${groupedOrders.length} pending orders',
        name: 'AcceptOrders',
      );

      ordersData.value = groupedOrders;
      ordersData.refresh();

      final triggeredOrder = groupedOrders.firstWhereOrNull(
              (order) => order.orderId == triggeredOrderId
      );

      if (triggeredOrder != null) {
        if (!_notifiedOrders.contains(triggeredOrderId)) {
          _notifiedOrders.add(triggeredOrderId);

          // Clean up old notifications (keep last 50)
          if (_notifiedOrders.length > 50) {
            final toRemove = _notifiedOrders.take(_notifiedOrders.length - 50).toList();
            _notifiedOrders.removeAll(toRemove);
          }

          await showGroupedOrderNotification(
            groupedOrder: triggeredOrder,
            isItemsAdded: isItemsAdded,
          );

          developer.log(
            '✅ Notification shown for grouped order #${triggeredOrder.orderId} '
                'with ${triggeredOrder.totalItemsCount} items',
            name: 'AcceptOrders',
          );
        } else {
          developer.log(
            '⏸️ Skipping notification for order #$triggeredOrderId (already notified)',
            name: 'AcceptOrders',
          );
        }
      } else {
        developer.log(
          '⚠️ Could not find grouped order for ID #$triggeredOrderId',
          name: 'AcceptOrders',
        );
      }
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error fetching pending orders with notification: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );
    } finally {
      isLoading.value = false;
      _isRefreshing = false;
      developer.log('✅ Fetch completed - reset flags', name: 'AcceptOrders');
    }
  }

  Future<void> fetchPendingOrders({bool isRefresh = false}) async {
    if (_isRefreshing) {
      developer.log('⏭️ Already refreshing - skipping', name: 'AcceptOrders');
      return;
    }

    try {
      _isRefreshing = true;
      developer.log('🚀 Starting fetch - isRefresh=$isRefresh', name: 'AcceptOrders');

      if (isRefresh) {
        isRefreshing.value = true;
        developer.log('📊 Set isRefreshing observable to true', name: 'AcceptOrders');
      } else {
        isLoading.value = true;
        developer.log('📊 Set isLoading observable to true', name: 'AcceptOrders');
      }
      errorMessage.value = '';

      developer.log('📡 Calling repository.getPendingOrders()', name: 'AcceptOrders');
      final groupedOrders = await _repository.getPendingOrders();

      developer.log(
        '✅ Fetched ${groupedOrders.length} pending orders',
        name: 'AcceptOrders',
      );

      ordersData.value = groupedOrders;

      // Force UI update
      ordersData.refresh();
      developer.log('🔄 Forced observable refresh', name: 'AcceptOrders');
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error fetching pending orders: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      _isRefreshing = false;
      developer.log('✅ Fetch completed - reset flags', name: 'AcceptOrders');
    }
  }

  Future<void> refreshOrders() async {
    developer.log('♻️ Manual refresh', name: 'AcceptOrders');
    await fetchPendingOrders(isRefresh: true);
  }

  /// ==================== UI METHODS ====================

  void toggleOrderExpansion(int orderId) {
    if (expandedOrders.contains(orderId)) {
      expandedOrders.remove(orderId);
    } else {
      expandedOrders.add(orderId);
    }
  }

  /// Accept individual item
  Future<void> acceptItem(int orderId, int itemId) async {
    try {
      processingItems.add(itemId);
      errorMessage.value = '';

      await _repository.updateOrderItemStatus(
        orderId: orderId,
        itemId: itemId,
        status: 'preparing',
      );

      developer.log(
        '✅ Item #$itemId accepted and moved to preparing',
        name: 'AcceptOrders',
      );

      // Remove item from the order locally
      _removeItemFromOrder(orderId, itemId);

    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error accepting item #$itemId: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );

      Get.snackbar(
        'Error',
        'Failed to accept item',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      processingItems.remove(itemId);
    }
  }

  /// Show rejection dialog for individual item
  void showRejectDialogForItem(int orderId, int itemId) {
    selectedOrderId.value = orderId;
    selectedItemId.value = itemId;
    isRejectDialogVisible.value = true;
    reasonController.clear();
    rejectionReason.value = '';
    rejectionCategory.value = 'out_of_stock';
  }

  /// Hide rejection dialog
  void hideRejectDialog() {
    isRejectDialogVisible.value = false;
    selectedOrderId.value = null;
    selectedItemId.value = null;
    reasonController.clear();
    rejectionReason.value = '';
    rejectionCategory.value = 'out_of_stock';
  }

  void updateRejectionReason(String reason) {
    rejectionReason.value = reason;
  }

  void updateRejectionCategory(String category) {
    rejectionCategory.value = category;
  }

  /// Reject individual item
  Future<void> rejectItem(BuildContext context) async {
    if (reasonController.text.trim().isEmpty) {
      SnackBarUtil.showWarning(
        context,
        'Please provide a reason for rejecting the item',
        title: 'Reason Required',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedOrderId.value == null || selectedItemId.value == null) return;

    // ✅ Store values before they get cleared
    final orderId = selectedOrderId.value!;
    final itemId = selectedItemId.value!;
    final reason = reasonController.text.trim();
    final category = rejectionCategory.value;

    try {
      processingItems.add(itemId);
      errorMessage.value = '';

      await _repository.rejectOrderItem(
        orderId: orderId,
        itemId: itemId,
        rejectionReason: reason,
        rejectionCategory: category,
      );

      hideRejectDialog();

      SnackBarUtil.showSuccess(
        context,
        'Item has been rejected',
        title: 'Item Rejected',
        duration: const Duration(seconds: 2),
      );

      // Remove item from the order locally
      _removeItemFromOrder(orderId, itemId);

      developer.log(
        '✅ Item #$itemId rejected - Reason: $reason, Category: $category',
        name: 'AcceptOrders',
      );
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error rejecting item: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );

      SnackBarUtil.showError(
        context,
        'Failed to reject item: ${e.toString()}',
        title: 'Rejection Failed',
        duration: const Duration(seconds: 3),
      );
    } finally {
      processingItems.remove(itemId);
    }
  }

  /// ==================== VALIDATION & FORMATTING ====================

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String? validateRejectionReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide a reason for rejection';
    }
    if (value.trim().length < 10) {
      return 'Reason must be at least 10 characters long';
    }
    if (value.trim().length > 500) {
      return 'Reason cannot exceed 500 characters';
    }
    return null;
  }

  /// ==================== DEBUG METHODS ====================

  void reconnectSocket() {
    try {
      developer.log(
        '🔄 Attempting manual socket reconnection',
        name: 'AcceptOrders',
      );

      SocketConnectionManager.instance.socketService.reconnect();

      Future.delayed(const Duration(seconds: 2), () {
        _setupSocketListeners();
      });
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error reconnecting socket: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );
    }
  }

  String getSocketStatus() {
    final info = SocketConnectionManager.instance.getConnectionInfo();
    return '''
Socket Connected: ${info['isConnected']}
Socket Exists: ${info['socketExists']}
Manager Connected: ${info['managerConnected']}
Active Listeners: ${info['activeListeners']}
Connection In Progress: ${info['connectionInProgress']}
Registered Events: ${info['registeredEvents']}
    ''';
  }

  /// ==================== GETTERS ====================

  bool get socketConnected => isSocketConnected.value;
  int get totalPendingOrders => ordersData.length;
  int get totalPendingItems => ordersData.fold(0, (sum, order) => sum + order.totalItemsCount);
  Map<String, dynamic> getSocketInfo() => _socketManager.getConnectionInfo();
}
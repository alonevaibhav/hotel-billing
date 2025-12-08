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
//   final rejectionCategory = 'out_of_stock'.obs; // ✅ NEW: Default rejection category
//   final isRejectDialogVisible = false.obs;
//   final selectedOrderId = Rxn<int>();
//   final expandedOrders = <int>{}.obs;
//
//   final TextEditingController reasonController = TextEditingController();
//
//   // ✅ Socket connection status
//   final isSocketConnected = false.obs;
//
//   // ✅ Track notified orders to prevent duplicate notifications
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
//   /// ✅ Setup socket event listeners
//   void _setupSocketListeners() {
//     try {
//       final socketService = SocketConnectionManager.instance.socketService;
//
//       // Check socket connection status
//       isSocketConnected.value = socketService.isConnected;
//
//       developer.log(
//         '🔌 Setting up socket listeners for AcceptOrderController',
//         name: 'AcceptOrderController',
//       );
//
//       // ✅ Listen for new orders
//       socketService.on('new_order', _handleNewOrder);
//
//       // ✅ Listen for order status updates
//       socketService.on('order_status_update', _handleOrderStatusUpdate);
//
//       // ✅ Listen for item status updates (if your backend sends this)
//       socketService.on('item_status_update', _handleItemStatusUpdate);
//
//       // ✅ Listen for order items added (when items are added to existing orders)
//       socketService.on('order_items_added', _handleOrderItemsAdded);
//
//       // ✅ Listen for authentication status
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
//   /// ✅ Remove socket event listeners
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
//   /// ✅ FIXED: Handle new order event - just trigger refresh, notification will be shown after grouping
//   void _handleNewOrder(dynamic data) {
//     developer.log(
//       '🔔 NEW ORDER RECEIVED: $data',
//       name: 'AcceptOrderController',
//     );
//
//     try {
//       // Extract order details
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
//       // ✅ Fetch and group orders - notification will be triggered after grouping
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
//   /// ✅ Handle order status update event
//   void _handleOrderStatusUpdate(dynamic data) {
//     developer.log(
//       '📊 ORDER STATUS UPDATE: $data',
//       name: 'AcceptOrderController',
//     );
//
//     try {
//       final orderId = data['orderId'] as int?;
//       final newStatus = data['status'] as String?;
//       final tableNumber = data['tableNumber']?.toString() ??
//           data['tableId']?.toString() ??
//           'Unknown';
//
//       if (orderId == null || newStatus == null) {
//         developer.log(
//           '⚠️ Invalid order status update data',
//           name: 'AcceptOrderController',
//         );
//         return;
//       }
//
//
//       // If order is no longer "pending", remove it from the list and notification tracking
//       if (newStatus != 'pending') {
//         final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
//         if (orderIndex != -1) {
//           ordersData.removeAt(orderIndex);
//           _notifiedOrders.remove(orderId); // Clear notification tracking
//           developer.log(
//             '✅ Removed order #$orderId from pending list (status: $newStatus)',
//             name: 'AcceptOrderController',
//           );
//         }
//       } else {
//         // If status is still pending, refresh to get latest data
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
//   /// ✅ Handle item status update event
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
//       // If item is no longer "pending", check if we need to update the order
//       if (newStatus != 'pending') {
//         final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
//
//         if (orderIndex != -1) {
//           final order = ordersData[orderIndex];
//
//           // Remove the item from the order
//           order.items.removeWhere((item) => item.id == itemId);
//
//           // If no more pending items in this order, remove the entire order
//           if (order.items.isEmpty) {
//             ordersData.removeAt(orderIndex);
//             _notifiedOrders.remove(orderId); // Clear notification tracking
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
//   /// ✅ Handle order items added event
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
//       // Refresh orders - will trigger notification if this is a new grouped order
//       fetchPendingOrdersWithNotification(orderId, isItemsAdded: true);
//     } catch (e) {
//       developer.log(
//         '❌ Error handling order items added: $e',
//         name: 'AcceptOrderController',
//       );
//     }
//   }
//
//   /// ✅ NEW: Fetch pending orders and show notification after grouping
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
//       // ✅ Find the grouped order that contains the triggered order ID
//       final triggeredOrder = groupedOrders.firstWhereOrNull((order) => order.orderId == triggeredOrderId
//       );
//
//       if (triggeredOrder != null) {
//         // ✅ Check if we've already notified for this order
//         if (!_notifiedOrders.contains(triggeredOrderId)) {
//           _notifiedOrders.add(triggeredOrderId);
//
//           // Clean up old tracked orders (keep only last 50)
//           if (_notifiedOrders.length > 50) {
//             final toRemove = _notifiedOrders.take(_notifiedOrders.length - 50).toList();
//             _notifiedOrders.removeAll(toRemove);
//           }
//
//           // ✅ Show notification with the grouped order details
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
//
//
//
//   /// Fetch pending orders from API
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
//   /// Refresh orders
//   Future<void> refreshOrders() async {
//     await fetchPendingOrders();
//   }
//
//   /// Toggle order expansion
//   void toggleOrderExpansion(int orderId) {
//     if (expandedOrders.contains(orderId)) {
//       expandedOrders.remove(orderId);
//     } else {
//       expandedOrders.add(orderId);
//     }
//   }
//
//   /// Accept order - Updates all items in the order to "preparing" status
//   Future<void> acceptOrder(BuildContext context, int orderId) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final orderIndex =
//       ordersData.indexWhere((order) => order.orderId == orderId);
//       if (orderIndex == -1) return;
//
//       final order = ordersData[orderIndex];
//
//       // Update status for all items in the order
//       await _repository.updateAllOrderItemsStatus(
//         orderId: order.orderId,
//         itemIds: order.items.map((item) => item.id).toList(),
//         status: 'preparing',
//       );
//
//       SnackBarUtil.showSuccess(
//         context,
//         'Order #${order.orderId} has been accepted successfully',
//         title: 'Order Accepted',
//         duration: const Duration(seconds: 2),
//       );
//
//       // Remove the accepted order from the list and notification tracking
//       Future.delayed(const Duration(milliseconds: 500), () {
//         ordersData.removeAt(orderIndex);
//         _notifiedOrders.remove(orderId);
//       });
//
//       developer.log(
//         '✅ Order #$orderId accepted and moved to preparing',
//         name: 'AcceptOrderController',
//       );
//     } catch (e) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error accepting order #$orderId: $e',
//         name: 'AcceptOrderController',
//       );
//
//       SnackBarUtil.showError(
//         context,
//         'Failed to accept order: ${e.toString()}',
//         title: 'Accept Failed',
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Show rejection dialog
//   void showRejectDialog(int orderId) {
//     selectedOrderId.value = orderId;
//     isRejectDialogVisible.value = true;
//     reasonController.clear();
//     rejectionReason.value = '';
//     rejectionCategory.value = 'out_of_stock'; // ✅ Reset to default
//   }
//
//   /// Hide rejection dialog
//   void hideRejectDialog() {
//     isRejectDialogVisible.value = false;
//     selectedOrderId.value = null;
//     reasonController.clear();
//     rejectionReason.value = '';
//     rejectionCategory.value = 'out_of_stock'; // ✅ Reset to default
//   }
//
//   /// Update rejection reason
//   void updateRejectionReason(String reason) {
//     rejectionReason.value = reason;
//   }
//
//   /// ✅ NEW: Update rejection category
//   void updateRejectionCategory(String category) {
//     rejectionCategory.value = category;
//   }
//
//   /// ✅ UPDATED: Reject order - Uses new rejection API with reason and category
//   Future<void> rejectOrder(BuildContext context) async {
//     if (reasonController.text.trim().isEmpty) {
//       SnackBarUtil.showWarning(
//         context,
//         'Please provide a reason for rejecting the order',
//         title: 'Reason Required',
//         duration: const Duration(seconds: 2),
//       );
//       return;
//     }
//
//     if (selectedOrderId.value == null) return;
//
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final orderIndex = ordersData
//           .indexWhere((order) => order.orderId == selectedOrderId.value);
//       if (orderIndex == -1) return;
//
//       final order = ordersData[orderIndex];
//
//       // ✅ Use new rejection method with reason and category
//       await _repository.rejectAllOrderItems(
//         orderId: order.orderId,
//         itemIds: order.items.map((item) => item.id).toList(),
//         rejectionReason: reasonController.text.trim(),
//         rejectionCategory: rejectionCategory.value,
//       );
//
//       hideRejectDialog();
//
//       SnackBarUtil.showSuccess(
//         context,
//         'Order #${order.orderId} has been rejected',
//         title: 'Order Rejected',
//         duration: const Duration(seconds: 2),
//       );
//
//       // Remove the rejected order from the list and notification tracking
//       Future.delayed(const Duration(milliseconds: 500), () {
//         ordersData.removeAt(orderIndex);
//         _notifiedOrders.remove(order.orderId);
//       });
//
//       developer.log(
//         '✅ Order #${order.orderId} rejected by chef - Reason: ${reasonController.text.trim()}, Category: ${rejectionCategory.value}',
//         name: 'AcceptOrderController',
//       );
//     } catch (e) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error rejecting order: $e',
//         name: 'AcceptOrderController',
//       );
//
//       SnackBarUtil.showError(
//         context,
//         'Failed to reject order: ${e.toString()}',
//         title: 'Rejection Failed',
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Format currency
//   String formatCurrency(double amount) {
//     return '₹${amount.toStringAsFixed(2)}';
//   }
//
//   /// Validate rejection reason
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
//   /// ✅ Manual socket reconnection (for debugging)
//   void reconnectSocket() {
//     try {
//       developer.log(
//         '🔄 Attempting manual socket reconnection',
//         name: 'AcceptOrderController',
//       );
//
//       SocketConnectionManager.instance.socketService.reconnect();
//
//       // Re-setup listeners after reconnection
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
//   /// ✅ Get socket connection status
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
  final ordersData = <GroupedOrder>[].obs;
  final errorMessage = ''.obs;
  final rejectionReason = ''.obs;
  final rejectionCategory = 'out_of_stock'.obs;
  final isRejectDialogVisible = false.obs;
  final selectedOrderId = Rxn<int>();
  final selectedItemId = Rxn<int>(); // NEW: Track selected item for rejection
  final expandedOrders = <int>{}.obs;
  final processingItems = <int>{}.obs; // NEW: Track items being processed

  final TextEditingController reasonController = TextEditingController();

  final isSocketConnected = false.obs;
  final Set<int> _notifiedOrders = {};

  @override
  void onInit() {
    super.onInit();
    fetchPendingOrders();
    _setupSocketListeners();
  }

  @override
  void onClose() {
    _removeSocketListeners();
    reasonController.dispose();
    super.onClose();
  }

  void _setupSocketListeners() {
    try {
      final socketService = SocketConnectionManager.instance.socketService;
      isSocketConnected.value = socketService.isConnected;

      developer.log(
        '🔌 Setting up socket listeners for AcceptOrderController',
        name: 'AcceptOrderController',
      );

      socketService.on('new_order', _handleNewOrder);
      socketService.on('order_status_update', _handleOrderStatusUpdate);
      socketService.on('item_status_update', _handleItemStatusUpdate);
      socketService.on('order_items_added', _handleOrderItemsAdded);
      socketService.on('authenticated', (data) {
        isSocketConnected.value = true;
        developer.log('✅ Socket authenticated', name: 'AcceptOrderController');
      });

      developer.log(
        '✅ Socket listeners registered successfully',
        name: 'AcceptOrderController',
      );
    } catch (e) {
      developer.log(
        '❌ Error setting up socket listeners: $e',
        name: 'AcceptOrderController',
      );
    }
  }

  void _removeSocketListeners() {
    try {
      final socketService = SocketConnectionManager.instance.socketService;

      developer.log(
        '🔌 Removing socket listeners for AcceptOrderController',
        name: 'AcceptOrderController',
      );

      socketService.off('new_order', _handleNewOrder);
      socketService.off('order_status_update', _handleOrderStatusUpdate);
      socketService.off('item_status_update', _handleItemStatusUpdate);
      socketService.off('order_items_added', _handleOrderItemsAdded);

      developer.log(
        '✅ Socket listeners removed successfully',
        name: 'AcceptOrderController',
      );
    } catch (e) {
      developer.log(
        '❌ Error removing socket listeners: $e',
        name: 'AcceptOrderController',
      );
    }
  }

  void _handleNewOrder(dynamic data) {
    developer.log(
      '🔔 NEW ORDER RECEIVED: $data',
      name: 'AcceptOrderController',
    );

    try {
      final orderData = data['data'] ?? data;
      final orderInfo = orderData['order'] ?? orderData;

      final orderId = (orderInfo['id'] ??
          orderInfo['order_id'] ??
          orderData['orderId'] ??
          orderData['id']) as int? ?? 0;

      if (orderId == 0) {
        developer.log(
          '⚠️ Invalid order ID in new order event',
          name: 'AcceptOrderController',
        );
        return;
      }

      developer.log(
        '📥 Processing new order #$orderId, will show notification after grouping',
        name: 'AcceptOrderController',
      );

      fetchPendingOrdersWithNotification(orderId);

    } catch (e) {
      developer.log(
        '❌ Error handling new order: $e',
        name: 'AcceptOrderController',
      );
    }
  }

  void _handleOrderStatusUpdate(dynamic data) {
    developer.log(
      '📊 ORDER STATUS UPDATE: $data',
      name: 'AcceptOrderController',
    );

    try {
      final orderId = data['orderId'] as int?;
      final newStatus = data['status'] as String?;

      if (orderId == null || newStatus == null) {
        developer.log(
          '⚠️ Invalid order status update data',
          name: 'AcceptOrderController',
        );
        return;
      }

      if (newStatus != 'pending') {
        final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
        if (orderIndex != -1) {
          ordersData.removeAt(orderIndex);
          _notifiedOrders.remove(orderId);
          developer.log(
            '✅ Removed order #$orderId from pending list (status: $newStatus)',
            name: 'AcceptOrderController',
          );
        }
      } else {
        fetchPendingOrders();
      }
    } catch (e) {
      developer.log(
        '❌ Error handling order status update: $e',
        name: 'AcceptOrderController',
      );
    }
  }

  void _handleItemStatusUpdate(dynamic data) {
    developer.log(
      '🍽️ ITEM STATUS UPDATE: $data',
      name: 'AcceptOrderController',
    );

    try {
      final orderId = data['orderId'] as int?;
      final itemId = data['itemId'] as int?;
      final newStatus = data['status'] as String?;

      if (orderId == null || itemId == null || newStatus == null) {
        developer.log(
          '⚠️ Invalid item status update data',
          name: 'AcceptOrderController',
        );
        return;
      }

      // Remove from processing items
      processingItems.remove(itemId);

      if (newStatus != 'pending') {
        final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);

        if (orderIndex != -1) {
          final order = ordersData[orderIndex];
          order.items.removeWhere((item) => item.id == itemId);

          if (order.items.isEmpty) {
            ordersData.removeAt(orderIndex);
            _notifiedOrders.remove(orderId);
            developer.log(
              '✅ Removed order #$orderId (no more pending items)',
              name: 'AcceptOrderController',
            );
          } else {
            ordersData[orderIndex] = order;
            ordersData.refresh();
            developer.log(
              '✅ Updated order #$orderId (removed item #$itemId)',
              name: 'AcceptOrderController',
            );
          }
        }
      }
    } catch (e) {
      developer.log(
        '❌ Error handling item status update: $e',
        name: 'AcceptOrderController',
      );
    }
  }

  void _handleOrderItemsAdded(dynamic data) {
    developer.log(
      '➕ ORDER ITEMS ADDED: $data',
      name: 'AcceptOrderController',
    );

    try {
      final orderId = data['orderId'] as int? ?? 0;

      if (orderId == 0) return;

      developer.log(
        '📥 Processing items added to order #$orderId',
        name: 'AcceptOrderController',
      );

      fetchPendingOrdersWithNotification(orderId, isItemsAdded: true);
    } catch (e) {
      developer.log(
        '❌ Error handling order items added: $e',
        name: 'AcceptOrderController',
      );
    }
  }

  Future<void> fetchPendingOrdersWithNotification(
      int triggeredOrderId, {
        bool isItemsAdded = false,
      }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final groupedOrders = await _repository.getPendingOrders();
      ordersData.value = groupedOrders;

      developer.log(
        '✅ Fetched and grouped ${groupedOrders.length} pending orders',
        name: 'AcceptOrderController',
      );

      final triggeredOrder = groupedOrders.firstWhereOrNull(
              (order) => order.orderId == triggeredOrderId
      );

      if (triggeredOrder != null) {
        if (!_notifiedOrders.contains(triggeredOrderId)) {
          _notifiedOrders.add(triggeredOrderId);

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
            name: 'AcceptOrderController',
          );
        } else {
          developer.log(
            '⏸️ Skipping notification for order #$triggeredOrderId (already notified)',
            name: 'AcceptOrderController',
          );
        }
      } else {
        developer.log(
          '⚠️ Could not find grouped order for ID #$triggeredOrderId',
          name: 'AcceptOrderController',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error fetching pending orders with notification: $e',
        name: 'AcceptOrderController',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final groupedOrders = await _repository.getPendingOrders();
      ordersData.value = groupedOrders;

      developer.log(
        '✅ Fetched ${groupedOrders.length} pending orders',
        name: 'AcceptOrderController',
      );
    } catch (e) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error fetching pending orders: $e',
        name: 'AcceptOrderController',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await fetchPendingOrders();
  }

  void toggleOrderExpansion(int orderId) {
    if (expandedOrders.contains(orderId)) {
      expandedOrders.remove(orderId);
    } else {
      expandedOrders.add(orderId);
    }
  }

  /// NEW: Accept individual item
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
        name: 'AcceptOrderController',
      );

      // Remove item from the order locally
      _removeItemFromOrder(orderId, itemId);

    } catch (e) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error accepting item #$itemId: $e',
        name: 'AcceptOrderController',
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

  /// NEW: Show rejection dialog for individual item
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

  /// NEW: Reject individual item
  /// NEW: Reject individual item
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

      hideRejectDialog(); // Now safe to call

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
        name: 'AcceptOrderController',
      );
    } catch (e) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error rejecting item: $e',
        name: 'AcceptOrderController',
      );

      SnackBarUtil.showError(
        context,
        'Failed to reject item: ${e.toString()}',
        title: 'Rejection Failed',
        duration: const Duration(seconds: 3),
      );
    } finally {
      // ✅ Use the stored itemId instead of selectedItemId.value
      processingItems.remove(itemId);
    }
  }
  /// Helper method to remove item from local order data
  void _removeItemFromOrder(int orderId, int itemId) {
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
          name: 'AcceptOrderController',
        );
      } else {
        // Update the order with remaining items
        ordersData[orderIndex] = order;
        ordersData.refresh();
        developer.log(
          '✅ Updated order #$orderId (removed item #$itemId)',
          name: 'AcceptOrderController',
        );
      }
    }
  }

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

  void reconnectSocket() {
    try {
      developer.log(
        '🔄 Attempting manual socket reconnection',
        name: 'AcceptOrderController',
      );

      SocketConnectionManager.instance.socketService.reconnect();

      Future.delayed(const Duration(seconds: 2), () {
        _setupSocketListeners();
      });
    } catch (e) {
      developer.log(
        '❌ Error reconnecting socket: $e',
        name: 'AcceptOrderController',
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
    ''';
  }
}
//
// import 'package:flutter/material.dart' hide Table;
// import 'package:get/get.dart';
// import 'package:hotelbilling/app/modules/controllers/WaiterPanelController/take_order_controller.dart';
// import 'dart:developer' as developer;
// import '../../../core/services/notification_service.dart';
// import '../../service/table_order_service.dart';
// import '../../../core/utils/snakbar_utils.dart';
// import '../../../data/models/RequestModel/create_order_request.dart';
// import '../../../data/models/ResponseModel/table_model.dart';
// import '../../service/order_repository.dart';
// import '../../../route/app_routes.dart';
// import '../../model/table_order_state_mode.dart';
// import '../../view/WaiterPanel/TakeOrder/widgets/success_order_notification.dart';
//
// class OrderManagementController extends GetxController {
//   // Dependencies
//   final OrderRepository _orderRepository = OrderRepository();
//
//   // State
//   final tableOrders = <int, TableOrderState>{}.obs;
//   final activeTableId = Rxn<int>();
//   final formKey = GlobalKey<FormState>();
//   final isLoading = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('OrderManagementController initialized');
//   }
//
//   @override
//   void onClose() {
//     tableOrders.values.forEach((state) => state.dispose());
//     tableOrders.clear();
//     super.onClose();
//   }
//
//   // ==================== STATE MANAGEMENT ====================
//
//   /// Get or create table state
//   TableOrderState getTableState(int tableId) {
//     final state = tableOrders.putIfAbsent(tableId, () => TableOrderState(tableId: tableId),);
//     developer.log(
//       "Table loaded ($tableId). Items: ${state.orderItems.length}",
//       name: "TABLE_STATE",
//     );
//     return state;
//   }
//
//   /// Set active table and fetch order if needed
//   void setActiveTable(int tableId, dynamic tableInfoData) {
//     final TableInfo? tableInfo = _parseTableInfo(tableInfoData);
//
//     activeTableId.value = tableId;
//     final state = getTableState(tableId);
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//
//     developer.log(
//       'SET ACTIVE TABLE → tableId:$tableId, orderId:$orderId, hasLoadedOrder:${state.hasLoadedOrder.value}',
//       name: 'ACTIVE_TABLE',
//     );
//
//     // Fetch order if exists and not loaded
//     if (orderId > 0 && !state.hasLoadedOrder.value) {
//       developer.log('TRIGGER FETCH → orderId:$orderId', name: 'ACTIVE_TABLE');
//       fetchOrder(orderId, tableId);
//     } else if (orderId <= 0 &&
//         state.placedOrderId.value != null &&
//         state.placedOrderId.value! > 0 &&
//         !state.hasLoadedOrder.value) {
//       // Fallback: Use stored placedOrderId
//       developer.log(
//         'TRIGGER FETCH (FALLBACK) → placedOrderId:${state.placedOrderId.value}',
//         name: 'ACTIVE_TABLE',
//       );
//       fetchOrder(state.placedOrderId.value!, tableId);
//     }
//   }
//
//   /// Reset table state if table becomes available
//   void resetTableStateIfNeeded(int tableId, TableInfo? tableInfo) {
//     final state = getTableState(tableId);
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//     final status = tableInfo?.table.status ?? 'unknown';
//
//     if (orderId <= 0 &&
//         status.toLowerCase() == 'available' &&
//         state.hasLoadedOrder.value) {
//       developer.log("Resetting state for available table $tableId",
//           name: "RESET_STATE");
//       state.clear();
//       state.hasLoadedOrder.value = false;
//     }
//   }
//
//   /// Clear table orders
//   void clearTableOrders(int tableId) {
//     if (tableOrders.containsKey(tableId)) {
//       tableOrders[tableId]?.dispose();
//       tableOrders.remove(tableId);
//     }
//   }
//
//   // ==================== ITEM MANAGEMENT ====================
//
//   /// Add item to table order
//   void addItemToTable(int tableId, Map<String, dynamic> item) {
//     final state = getTableState(tableId);
//     TableOrderService.mergeOrAddItem(state.orderItems, item);
//     _updateTotal(state);
//   }
//
//   /// Increment item quantity
//   void incrementItemQuantity(int tableId, int index) {
//     final state = getTableState(tableId);
//     if (!_isValidIndex(index, state.orderItems.length, 'ORDER_INC')) return;
//
//     final item = state.orderItems[index];
//     final newQty = (item['quantity'] as int) + 1;
//
//     developer.log(
//       'INC → table:$tableId index:$index qty:${item['quantity']}→$newQty',
//       name: 'ORDER_INC',
//     );
//
//     state.orderItems[index] =
//         TableOrderService.updateItemQuantity(item, newQty);
//     _updateTotal(state);
//     _logTableSnapshot(tableId, state);
//   }
//
//   /// Decrement item quantity
//   void decrementItemQuantity(int tableId, int index, BuildContext context) {
//     final state = getTableState(tableId);
//     if (!_isValidIndex(index, state.orderItems.length, 'ORDER_DEC')) return;
//
//     final item = state.orderItems[index];
//     final currentQty = item['quantity'] as int;
//     final frozenQty = state.getFrozenQuantity(item['id'].toString());
//
//     developer.log(
//       'DEC REQ → table:$tableId index:$index curr:$currentQty frozen:$frozenQty',
//       name: 'ORDER_DEC',
//     );
//
//     if (frozenQty == 0) {
//       if (currentQty > 1) {
//         state.orderItems[index] =
//             TableOrderService.updateItemQuantity(item, currentQty - 1);
//         _updateTotal(state);
//       } else {
//         _removeItem(state, index, context);
//       }
//     } else {
//       if (TableOrderService.canDecrementItem(currentQty, frozenQty)) {
//         state.orderItems[index] =
//             TableOrderService.updateItemQuantity(item, currentQty - 1);
//         _updateTotal(state);
//       } else {
//         _showCannotReduceWarning(context, frozenQty);
//       }
//     }
//
//     _logTableSnapshot(tableId, state);
//   }
//
//   /// Remove item from table
//   void removeItemFromTable(int tableId, int index, BuildContext context) {
//     final state = getTableState(tableId);
//     if (!_isValidIndex(index, state.orderItems.length, 'REMOVE_ITEM')) return;
//
//     final item = state.orderItems[index];
//     final frozenQty = state.getFrozenQuantity(item['id'].toString());
//
//     if (!TableOrderService.canRemoveItem(frozenQty)) {
//       _showCannotRemoveWarning(context, frozenQty);
//       return;
//     }
//
//     _removeItem(state, index, context);
//     developer.log('REMOVED → table:$tableId id:${item['id']}',
//         name: 'REMOVE_ITEM');
//     _logTableSnapshot(tableId, state);
//   }
//
//
// // ==================== ORDER OPERATIONS ====================
//
//   /// Fetch order from server
//   Future<void> fetchOrder(int orderId, int tableId) async {
//     final state = getTableState(tableId);
//
//     if (state.isLoadingOrder.value || orderId == 0 || state.hasLoadedOrder.value) {
//       return;
//     }
//
//     try {
//       state.isLoadingOrder.value = true;
//
//       final orderData = await _orderRepository.getOrderById(orderId);
//
//       state.placedOrderId.value = orderData.data.order.id;
//       state.orderItems.clear();
//       state.frozenItems.clear();
//
//       // Process and group items
//       final processedItems = TableOrderService.processOrderItems(
//         orderData.data.items,
//         state.frozenItems,
//       );
//
//       state.orderItems.addAll(processedItems);
//       _updateTotal(state);
//
//       developer.log(
//         'Order fetched: ${state.orderItems.length} items',
//         name: 'FETCH_ORDER',
//       );
//     } catch (e) {
//       developer.log('Error fetching order: $e', name: 'FETCH_ORDER');
//     } finally {
//       state.isLoadingOrder.value = false;
//       state.hasLoadedOrder.value = true;
//     }
//   }
//
//   /// Proceed to checkout
//   Future<void> proceedToCheckout(
//       int tableId,
//       BuildContext context,
//       dynamic tableInfoData,
//       List<Map<String, dynamic>> orderItems,
//       ) async {
//     final TableInfo? tableInfo = _parseTableInfo(tableInfoData);
//
//     await _processOrder(
//       tableId: tableId,
//       context: context,
//       tableInfo: tableInfo,
//       orderItems: orderItems,
//       successMessage: 'KOT sent to manager',
//       errorMessage: 'Failed to place order',
//     );
//   }
//
//   /// Process order (create new or add to existing)
//   Future<void> _processOrder({
//     required int tableId,
//     required BuildContext context,
//     required TableInfo? tableInfo,
//     required List<Map<String, dynamic>> orderItems,
//     required String successMessage,
//     required String errorMessage,
//   }) async {
//     try {
//       isLoading.value = true;
//       final state = getTableState(tableId);
//
//       final newItems = TableOrderService.getNewItems(
//         state.frozenItems,
//         orderItems,
//       );
//
//       if (newItems.isEmpty) {
//         _showNoNewItemsWarning(context);
//         isLoading.value = false;
//         return;
//       }
//
//       if (state.isReorderScenario) {
//         await _addItemsToExistingOrder(
//           placedOrderId: state.placedOrderId.value!,
//           tableId: tableId,
//           context: context,
//           tableInfo: tableInfo,
//           newItems: newItems,
//         );
//       } else {
//         await _createNewOrder(
//           tableId: tableId,
//           context: context,
//           tableInfo: tableInfo,
//           state: state,
//           newItems: newItems,
//           successMessage: successMessage,
//         );
//       }
//     } catch (e) {
//       developer.log('Order processing error: $e', name: 'ORDER_API');
//       SnackBarUtil.showError(context, errorMessage, title: 'Error');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Create new order
//   Future<void> _createNewOrder({
//     required int tableId,
//     required BuildContext context,
//     required TableInfo? tableInfo,
//     required TableOrderState state,
//     required List<Map<String, dynamic>> newItems,
//     required String successMessage,
//   }) async {
//     final request = CreateOrderRequest(
//       orderData: OrderData(
//         hotelTableId: tableInfo?.table.id ?? tableId,
//         customerName: state.fullNameController.text.trim(),
//         customerPhone: state.phoneController.text.trim(),
//         tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
//         status: 'pending',
//       ),
//       items: newItems
//           .map((item) => OrderItemRequest(
//         menuItemId: item['id'] as int,
//         quantity: item['quantity'] as int,
//         specialInstructions: item['special_instructions'] as String?,
//       ))
//           .toList(),
//     );
//
//     final response = await _orderRepository.createOrder(request);
//     final createdOrderId = response.data.order.id;
//
//     state.placedOrderId.value = createdOrderId;
//     state.addFrozenItems(newItems);
//
//     developer.log('Order created: ID $createdOrderId', name: 'ORDER_API');
//
//     // Show notification after successful order creation
//     await showOrderNotification(
//       orderId: createdOrderId,
//       tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
//       itemCount: newItems.length,
//       isNewOrder: true,
//     );
//
//     _showSuccessAndRefresh(context, tableInfo, tableId, successMessage);
//   }
//
//   /// Add items to existing order
//   Future<void> _addItemsToExistingOrder({
//     required int placedOrderId,
//     required int tableId,
//     required BuildContext context,
//     required TableInfo? tableInfo,
//     required List<Map<String, dynamic>> newItems,
//   }) async {
//     await _orderRepository.addItemsToOrder(placedOrderId, newItems);
//
//     final state = getTableState(tableId);
//     state.placedOrderId.value = placedOrderId;
//     state.addFrozenItems(newItems);
//
//     developer.log('Items added to order: ID $placedOrderId', name: 'REORDER_API');
//
//     // Show notification after successfully adding items
//     await showOrderNotification(
//       orderId: placedOrderId,
//       tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
//       itemCount: newItems.length,
//       isNewOrder: false,
//     );
//
//     _showSuccessAndRefresh(
//       context,
//       tableInfo,
//       tableId,
//       'Items added to existing order',
//     );
//   }
//
//
//   // ==================== UI ACTIONS ====================
//
//   /// Toggle urgent status
//   void toggleUrgentForTable(
//       int tableId,
//       BuildContext context,
//       dynamic tableInfoData,
//       ) {
//     final TableInfo? tableInfo = _parseTableInfo(tableInfoData);
//     final state = getTableState(tableId);
//
//     state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
//
//     final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//     final message = state.isMarkAsUrgent.value
//         ? 'Table $tableNumber marked as urgent'
//         : 'Table $tableNumber removed from urgent';
//
//     SnackBarUtil.show(
//       context,
//       message,
//       title: state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
//       type: state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
//       duration: const Duration(seconds: 1),
//     );
//   }
//
//   /// Navigate to add items screen
//   void navigateToAddItems(int tableId, dynamic tableInfoData) {
//     try {
//       final Map<String, dynamic>? tableMap = tableInfoData is TableInfo
//           ? tableInfoToMap(tableInfoData)
//           : (tableInfoData as Map<String, dynamic>?);
//
//       NavigationService.addItems(tableMap);
//     } catch (e) {
//       developer.log('Navigation error: $e');
//       SnackBarUtil.showError(
//         Get.context!,
//         'Unable to proceed',
//         title: 'Navigation Error',
//       );
//     }
//   }
//
//   /// Check if can proceed to checkout
//   bool canProceedToCheckout(int tableId) {
//     final state = getTableState(tableId);
//     return state.isAvailableForNewOrder;
//   }
//
//   // ==================== PRIVATE HELPERS ====================
//
//   void _updateTotal(TableOrderState state) {
//     final newTotal = TableOrderService.calculateTotal(state.orderItems);
//     state.updateTotal(newTotal);
//     developer.log('TOTAL UPDATE → table:${state.tableId} total:₹$newTotal',
//         name: 'UPDATE_TOTAL');
//   }
//
//   void _removeItem(
//       TableOrderState state,
//       int index,
//       BuildContext context,
//       ) {
//     final removedItem = state.orderItems.removeAt(index);
//     _updateTotal(state);
//     SnackBarUtil.showInfo(
//       context,
//       '${removedItem['item_name']} removed from order',
//       title: 'Item Removed',
//       duration: const Duration(seconds: 1),
//     );
//   }
//
//   bool _isValidIndex(int index, int length, String operation) {
//     if (index < 0 || index >= length) {
//       developer.log('❌ Invalid index $index', name: operation);
//       return false;
//     }
//     return true;
//   }
//
//   void _showCannotReduceWarning(BuildContext context, int frozenQty) {
//     SnackBarUtil.showWarning(
//       context,
//       'Cannot reduce below sent quantity ($frozenQty)',
//       title: 'Item Already Sent',
//       duration: const Duration(seconds: 2),
//     );
//   }
//
//   void _showCannotRemoveWarning(BuildContext context, int frozenQty) {
//     SnackBarUtil.showWarning(
//       context,
//       'Cannot remove - $frozenQty already sent to kitchen',
//       title: 'Item Already Sent',
//       duration: const Duration(seconds: 2),
//     );
//   }
//
//   void _showNoNewItemsWarning(BuildContext context) {
//     SnackBarUtil.showWarning(
//       context,
//       'No new items to send. All items already sent to kitchen',
//       title: 'Warning',
//       duration: const Duration(seconds: 2),
//     );
//   }
//
//   void _showSuccessAndRefresh(
//       BuildContext context,
//       TableInfo? tableInfo,
//       int tableId,
//       String message,
//       ) {
//     final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//
//     SnackBarUtil.showSuccess(
//       context,
//       '$message for Table $tableNumber',
//       title: 'Success',
//       duration: const Duration(seconds: 2),
//     );
//
//     final state = getTableState(tableId);
//     state.hasLoadedOrder.value = false;
//
//     final controller = Get.find<TakeOrdersController>();
//     controller.refreshTables();
//
//     NavigationService.goBack();
//   }
//
//   void _logTableSnapshot(int tableId, TableOrderState state) {
//     final buffer = StringBuffer();
//     buffer.writeln('TABLE SNAPSHOT → table:$tableId');
//     for (var i = 0; i < state.orderItems.length; i++) {
//       final it = state.orderItems[i];
//       final frozen = state.getFrozenQuantity(it['id'].toString());
//       buffer.writeln(
//         '[$i] id:${it['id']} name:${it['item_name']} qty:${it['quantity']} frozen:$frozen',
//       );
//     }
//     buffer.writeln('FINAL TOTAL: ${state.finalCheckoutTotal.value}');
//     developer.log(buffer.toString(), name: 'ORDER_STATE');
//   }
//
//   TableInfo? _parseTableInfo(dynamic tableInfoData) {
//     if (tableInfoData is TableInfo) return tableInfoData;
//     if (tableInfoData is Map<String, dynamic>) {
//       return mapToTableInfo(tableInfoData);
//     }
//     return null;
//   }
//
//   Map<String, dynamic>? tableInfoToMap(TableInfo? tableInfo) {
//     if (tableInfo == null) return null;
//     return {
//       'id': tableInfo.table.id,
//       'tableNumber': tableInfo.table.tableNumber,
//       'tableType': tableInfo.table.tableType,
//       'capacity': tableInfo.table.capacity,
//       'status': tableInfo.table.status,
//       'description': tableInfo.table.description,
//       'location': tableInfo.table.location,
//       'areaName': tableInfo.areaName,
//       'hotelOwnerId': tableInfo.table.hotelOwnerId,
//       'tableAreaId': tableInfo.table.tableAreaId,
//       'createdAt': tableInfo.table.createdAt,
//       'updatedAt': tableInfo.table.updatedAt,
//       'currentOrder': tableInfo.currentOrder?.toJson(),
//     };
//   }
//
//   TableInfo? mapToTableInfo(Map<String, dynamic>? map) {
//     if (map == null) return null;
//     try {
//       return TableInfo(
//         table: Table(
//           id: map['id'] as int,
//           hotelOwnerId: map['hotelOwnerId'] as int,
//           tableAreaId: map['tableAreaId'] as int,
//           tableNumber: map['tableNumber'] as String,
//           tableType: map['tableType'] as String,
//           capacity: map['capacity'] as int,
//           status: map['status'] as String,
//           description: map['description'] as String?,
//           location: map['location'] as String?,
//           createdAt: map['createdAt'] as String,
//           updatedAt: map['updatedAt'] as String,
//         ),
//         currentOrder: map['currentOrder'] != null
//             ? CurrentOrder.fromJson(map['currentOrder'] as Map<String, dynamic>)
//             : null,
//         areaName: map['areaName'] as String,
//       );
//     } catch (e) {
//       developer.log('Error converting map to TableInfo: $e',
//           name: 'MAP_CONVERSION');
//       return null;
//     }
//   }
// }
//
//


import 'package:flutter/material.dart' hide Table;
import 'package:get/get.dart';
import 'package:hotelbilling/app/modules/controllers/WaiterPanelController/take_order_controller.dart';
import 'dart:developer' as developer;
import '../../../core/services/notification_service.dart';
import '../../../core/services/socket_service.dart';
import '../../service/table_order_service.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/RequestModel/create_order_request.dart';
import '../../../data/models/ResponseModel/table_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../route/app_routes.dart';
import '../../model/table_order_state_mode.dart';
import '../../view/WaiterPanel/TakeOrder/widgets/success_order_notification.dart';

class OrderManagementController extends GetxController {
  // Dependencies
  final OrderRepository _orderRepository = OrderRepository();
  final SocketService _socketService = SocketService.instance;

  // State
  final tableOrders = <int, TableOrderState>{}.obs;
  final activeTableId = Rxn<int>();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isSocketConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    developer.log('OrderManagementController initialized', name: 'ORDER_MGMT');
    _initializeSocketListeners();
  }

  @override
  void onClose() {
    _removeSocketListeners();
    tableOrders.values.forEach((state) => state.dispose());
    tableOrders.clear();
    super.onClose();
  }

  // ==================== SOCKET INITIALIZATION ====================

  /// Initialize socket listeners for real-time order updates
  void _initializeSocketListeners() {
    try {
      developer.log(
        '🔌 Setting up socket listeners for orders...',
        name: 'ORDER_MGMT.Socket',
      );

      // Check socket connection status
      isSocketConnected.value = _socketService.isConnected;

      // Initialize repository socket listeners
      _orderRepository.initializeSocketListeners(
        onNewOrder: _handleNewOrder,
        onOrderStatusUpdate: _handleOrderStatusUpdate,
        onPaymentUpdate: _handlePaymentUpdate,
      );

      // Listen to socket connection status changes
      _socketService.on('authenticated', (data) {
        isSocketConnected.value = true;
        developer.log(
          '✅ Socket authenticated - Ready to receive order updates',
          name: 'ORDER_MGMT.Socket',
        );
      });

      _socketService.on('disconnect', (data) {
        isSocketConnected.value = false;
        developer.log(
          '⚠️ Socket disconnected',
          name: 'ORDER_MGMT.Socket',
        );
      });

      developer.log(
        '✅ Socket listeners initialized successfully',
        name: 'ORDER_MGMT.Socket',
      );
    } catch (e) {
      developer.log(
        '❌ Socket listener initialization error: $e',
        name: 'ORDER_MGMT.Socket',
      );
    }
  }

  /// Remove socket listeners
  void _removeSocketListeners() {
    developer.log(
      '🔌 Removing socket listeners...',
      name: 'ORDER_MGMT.Socket',
    );
    _orderRepository.removeSocketListeners();
    _socketService.off('authenticated');
    _socketService.off('disconnect');
  }
// ==================== SOCKET EVENT HANDLERS ====================

  /// Handle new order notification from socket
  void _handleNewOrder(Map<String, dynamic> data) {
    try {
      developer.log(
        '🔔 NEW ORDER EVENT RAW: $data',
        name: 'ORDER_MGMT.Socket',
      );

      // ✅ Handle both data structures
      final orderData = data.containsKey('data')
          ? data['data'] as Map<String, dynamic>?
          : data;

      if (orderData == null || orderData.isEmpty) {
        developer.log(
          '⚠️ Empty order data in new_order event',
          name: 'ORDER_MGMT.Socket',
        );
        return;
      }

      // Extract order details with fallbacks
      final orderId = orderData['id'] ??
          orderData['order_id'] ??
          orderData['orderId'] ??
          0;
      final tableNumber = orderData['table_number'] ??
          orderData['tableNumber'] ??
          'Unknown';
      final message = data['message'] ??
          'New order received for Table $tableNumber';

      developer.log(
        '📋 Parsed order - ID: $orderId, Table: $tableNumber',
        name: 'ORDER_MGMT.Socket',
      );

      // Show notification
      if (Get.context != null) {
        SnackBarUtil.showSuccess(
          Get.context!,
          message,
          title: '🔔 New Order - Table $tableNumber',
          duration: const Duration(seconds: 3),
        );
      }

      // Refresh table list
      try {
        final takeOrderController = Get.find<TakeOrdersController>();
        takeOrderController.refreshTables();
        developer.log(
          '✅ Tables refreshed after new order',
          name: 'ORDER_MGMT.Socket',
        );
      } catch (e) {
        developer.log(
          '⚠️ Could not refresh tables: $e',
          name: 'ORDER_MGMT.Socket',
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error handling new order: $e',
        name: 'ORDER_MGMT.Socket',
      );
    }
  }

  /// Handle order status update from socket
  void _handleOrderStatusUpdate(Map<String, dynamic> data) {
    try {
      developer.log(
        '📊 STATUS UPDATE EVENT RAW: $data',
        name: 'ORDER_MGMT.Socket',
      );

      // ✅ Handle both data structures
      final orderData = data.containsKey('data')
          ? data['data'] as Map<String, dynamic>?
          : data;

      if (orderData == null || orderData.isEmpty) {
        developer.log(
          '⚠️ Empty order data in status update event',
          name: 'ORDER_MGMT.Socket',
        );
        return;
      }

      // Extract with multiple fallbacks
      final orderId = orderData['orderId'] ??
          orderData['order_id'] ??
          orderData['id'] ??
          0;
      final newStatus = orderData['status'] ?? 'unknown';
      final tableNumber = orderData['table_number'] ??
          orderData['tableNumber'] ??
          '';
      final message = data['message'] ??
          'Order #$orderId status: $newStatus';

      developer.log(
        '📋 Parsed status update - Order: $orderId, Status: $newStatus',
        name: 'ORDER_MGMT.Socket',
      );

      // Update local state
      _updateOrderStatusInTables(orderId, newStatus);

      // Show notification
      if (Get.context != null) {
        SnackBarUtil.show(
          Get.context!,
          message,
          title: '📊 Order Status Update',
          type: SnackBarType.info,
          duration: const Duration(seconds: 2),
        );
      }

      // Refresh tables
      try {
        final takeOrderController = Get.find<TakeOrdersController>();
        takeOrderController.refreshTables();
        developer.log(
          '✅ Tables refreshed after status update',
          name: 'ORDER_MGMT.Socket',
        );
      } catch (e) {
        developer.log(
          '⚠️ Could not refresh tables: $e',
          name: 'ORDER_MGMT.Socket',
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error handling status update: $e',
        name: 'ORDER_MGMT.Socket',
      );
    }
  }

  /// Handle payment update from socket
  void _handlePaymentUpdate(Map<String, dynamic> data) {
    try {
      developer.log(
        '💰 PAYMENT UPDATE EVENT RAW: $data',
        name: 'ORDER_MGMT.Socket',
      );

      final message = data['message'] ?? 'Payment updated';
      final orderData = data.containsKey('data') ? data['data'] : data;
      final orderId = orderData?['orderId'] ?? orderData?['order_id'] ?? 0;

      developer.log(
        '📋 Parsed payment update - Order: $orderId',
        name: 'ORDER_MGMT.Socket',
      );

      // Show notification
      if (Get.context != null) {
        SnackBarUtil.showSuccess(
          Get.context!,
          message,
          title: '💰 Payment Received',
          duration: const Duration(seconds: 2),
        );
      }

      // Refresh tables
      try {
        final takeOrderController = Get.find<TakeOrdersController>();
        takeOrderController.refreshTables();
        developer.log(
          '✅ Tables refreshed after payment update',
          name: 'ORDER_MGMT.Socket',
        );
      } catch (e) {
        developer.log(
          '⚠️ Could not refresh tables: $e',
          name: 'ORDER_MGMT.Socket',
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error handling payment update: $e',
        name: 'ORDER_MGMT.Socket',
      );
    }
  }


  /// Update order status in local table states
  void _updateOrderStatusInTables(int orderId, String newStatus) {
    for (var state in tableOrders.values) {
      if (state.placedOrderId.value == orderId) {
        developer.log(
          '📝 Updating status for table ${state.tableId}: order $orderId → $newStatus',
          name: 'ORDER_MGMT.Socket',
        );
        // You can add a status field to TableOrderState if needed
        // state.orderStatus.value = newStatus;
      }
    }
  }

  // ==================== STATE MANAGEMENT ====================

  /// Get or create table state
  TableOrderState getTableState(int tableId) {
    final state = tableOrders.putIfAbsent(
      tableId,
          () => TableOrderState(tableId: tableId),
    );
    developer.log(
      "Table loaded ($tableId). Items: ${state.orderItems.length}",
      name: "TABLE_STATE",
    );
    return state;
  }

  /// Set active table and fetch order if needed
  void setActiveTable(int tableId, dynamic tableInfoData) {
    final TableInfo? tableInfo = _parseTableInfo(tableInfoData);

    activeTableId.value = tableId;
    final state = getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;

    developer.log(
      'SET ACTIVE TABLE → tableId:$tableId, orderId:$orderId, hasLoadedOrder:${state.hasLoadedOrder.value}',
      name: 'ACTIVE_TABLE',
    );

    // Fetch order if exists and not loaded
    if (orderId > 0 && !state.hasLoadedOrder.value) {
      developer.log('TRIGGER FETCH → orderId:$orderId', name: 'ACTIVE_TABLE');
      fetchOrder(orderId, tableId);
    } else if (orderId <= 0 &&
        state.placedOrderId.value != null &&
        state.placedOrderId.value! > 0 &&
        !state.hasLoadedOrder.value) {
      // Fallback: Use stored placedOrderId
      developer.log(
        'TRIGGER FETCH (FALLBACK) → placedOrderId:${state.placedOrderId.value}',
        name: 'ACTIVE_TABLE',
      );
      fetchOrder(state.placedOrderId.value!, tableId);
    }
  }

  /// Reset table state if table becomes available
  void resetTableStateIfNeeded(int tableId, TableInfo? tableInfo) {
    final state = getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;
    final status = tableInfo?.table.status ?? 'unknown';

    if (orderId <= 0 &&
        status.toLowerCase() == 'available' &&
        state.hasLoadedOrder.value) {
      developer.log(
        "Resetting state for available table $tableId",
        name: "RESET_STATE",
      );
      state.clear();
      state.hasLoadedOrder.value = false;
    }
  }

  /// Clear table orders
  void clearTableOrders(int tableId) {
    if (tableOrders.containsKey(tableId)) {
      tableOrders[tableId]?.dispose();
      tableOrders.remove(tableId);
    }
  }

  // ==================== ITEM MANAGEMENT ====================

  /// Add item to table order
  void addItemToTable(int tableId, Map<String, dynamic> item) {
    final state = getTableState(tableId);
    TableOrderService.mergeOrAddItem(state.orderItems, item);
    _updateTotal(state);
  }

  /// Increment item quantity
  void incrementItemQuantity(int tableId, int index) {
    final state = getTableState(tableId);
    if (!_isValidIndex(index, state.orderItems.length, 'ORDER_INC')) return;

    final item = state.orderItems[index];
    final newQty = (item['quantity'] as int) + 1;

    developer.log(
      'INC → table:$tableId index:$index qty:${item['quantity']}→$newQty',
      name: 'ORDER_INC',
    );

    state.orderItems[index] =
        TableOrderService.updateItemQuantity(item, newQty);
    _updateTotal(state);
    _logTableSnapshot(tableId, state);
  }

  /// Decrement item quantity
  void decrementItemQuantity(int tableId, int index, BuildContext context) {
    final state = getTableState(tableId);
    if (!_isValidIndex(index, state.orderItems.length, 'ORDER_DEC')) return;

    final item = state.orderItems[index];
    final currentQty = item['quantity'] as int;
    final frozenQty = state.getFrozenQuantity(item['id'].toString());

    developer.log(
      'DEC REQ → table:$tableId index:$index curr:$currentQty frozen:$frozenQty',
      name: 'ORDER_DEC',
    );

    if (frozenQty == 0) {
      if (currentQty > 1) {
        state.orderItems[index] =
            TableOrderService.updateItemQuantity(item, currentQty - 1);
        _updateTotal(state);
      } else {
        _removeItem(state, index, context);
      }
    } else {
      if (TableOrderService.canDecrementItem(currentQty, frozenQty)) {
        state.orderItems[index] =
            TableOrderService.updateItemQuantity(item, currentQty - 1);
        _updateTotal(state);
      } else {
        _showCannotReduceWarning(context, frozenQty);
      }
    }

    _logTableSnapshot(tableId, state);
  }

  /// Remove item from table
  void removeItemFromTable(int tableId, int index, BuildContext context) {
    final state = getTableState(tableId);
    if (!_isValidIndex(index, state.orderItems.length, 'REMOVE_ITEM')) return;

    final item = state.orderItems[index];
    final frozenQty = state.getFrozenQuantity(item['id'].toString());

    if (!TableOrderService.canRemoveItem(frozenQty)) {
      _showCannotRemoveWarning(context, frozenQty);
      return;
    }

    _removeItem(state, index, context);
    developer.log(
      'REMOVED → table:$tableId id:${item['id']}',
      name: 'REMOVE_ITEM',
    );
    _logTableSnapshot(tableId, state);
  }

  // ==================== ORDER OPERATIONS ====================

  /// Fetch order from server
  Future<void> fetchOrder(int orderId, int tableId) async {
    final state = getTableState(tableId);

    if (state.isLoadingOrder.value ||
        orderId == 0 ||
        state.hasLoadedOrder.value) {
      return;
    }

    try {
      state.isLoadingOrder.value = true;

      final orderData = await _orderRepository.getOrderById(orderId);

      state.placedOrderId.value = orderData.data.order.id;
      state.orderItems.clear();
      state.frozenItems.clear();

      // Process and group items
      final processedItems = TableOrderService.processOrderItems(
        orderData.data.items,
        state.frozenItems,
      );

      state.orderItems.addAll(processedItems);
      _updateTotal(state);

      developer.log(
        'Order fetched: ${state.orderItems.length} items',
        name: 'FETCH_ORDER',
      );
    } catch (e) {
      developer.log('Error fetching order: $e', name: 'FETCH_ORDER');
    } finally {
      state.isLoadingOrder.value = false;
      state.hasLoadedOrder.value = true;
    }
  }

  /// Proceed to checkout
  Future<void> proceedToCheckout(
      int tableId,
      BuildContext context,
      dynamic tableInfoData,
      List<Map<String, dynamic>> orderItems,
      ) async {
    final TableInfo? tableInfo = _parseTableInfo(tableInfoData);

    await _processOrder(
      tableId: tableId,
      context: context,
      tableInfo: tableInfo,
      orderItems: orderItems,
      successMessage: 'KOT sent to manager',
      errorMessage: 'Failed to place order',
    );
  }

  /// Process order (create new or add to existing)
  Future<void> _processOrder({
    required int tableId,
    required BuildContext context,
    required TableInfo? tableInfo,
    required List<Map<String, dynamic>> orderItems,
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      isLoading.value = true;
      final state = getTableState(tableId);

      final newItems = TableOrderService.getNewItems(
        state.frozenItems,
        orderItems,
      );

      if (newItems.isEmpty) {
        _showNoNewItemsWarning(context);
        isLoading.value = false;
        return;
      }

      if (state.isReorderScenario) {
        await _addItemsToExistingOrder(
          placedOrderId: state.placedOrderId.value!,
          tableId: tableId,
          context: context,
          tableInfo: tableInfo,
          newItems: newItems,
        );
      } else {
        await _createNewOrder(
          tableId: tableId,
          context: context,
          tableInfo: tableInfo,
          state: state,
          newItems: newItems,
          successMessage: successMessage,
        );
      }
    } catch (e) {
      developer.log('Order processing error: $e', name: 'ORDER_API');
      SnackBarUtil.showError(context, errorMessage, title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new order (REST API - backend handles socket emission)
  Future<void> _createNewOrder({
    required int tableId,
    required BuildContext context,
    required TableInfo? tableInfo,
    required TableOrderState state,
    required List<Map<String, dynamic>> newItems,
    required String successMessage,
  }) async {
    final request = CreateOrderRequest(
      orderData: OrderData(
        hotelTableId: tableInfo?.table.id ?? tableId,
        customerName: state.fullNameController.text.trim(),
        customerPhone: state.phoneController.text.trim(),
        tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
        status: 'pending',
      ),
      items: newItems
          .map((item) => OrderItemRequest(
        menuItemId: item['id'] as int,
        quantity: item['quantity'] as int,
        specialInstructions: item['special_instructions'] as String?,
      ))
          .toList(),
    );

    // ✅ Use REST API - backend automatically emits socket notification
    final response = await _orderRepository.createOrder(request);
    final createdOrderId = response.data.order.id;

    state.placedOrderId.value = createdOrderId;
    state.addFrozenItems(newItems);

    developer.log(
      '✅ Order created: ID $createdOrderId (Socket notification sent by backend)',
      name: 'ORDER_API',
    );

    // Show local notification
    await showOrderNotification(
      orderId: createdOrderId,
      tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
      itemCount: newItems.length,
      isNewOrder: true,
    );

    _showSuccessAndRefresh(context, tableInfo, tableId, successMessage);
  }

  /// Add items to existing order (REST API - backend handles socket emission)
  Future<void> _addItemsToExistingOrder({
    required int placedOrderId,
    required int tableId,
    required BuildContext context,
    required TableInfo? tableInfo,
    required List<Map<String, dynamic>> newItems,
  }) async {
    // ✅ Use REST API - backend automatically emits socket notification
    await _orderRepository.addItemsToOrder(placedOrderId, newItems);

    final state = getTableState(tableId);
    state.placedOrderId.value = placedOrderId;
    state.addFrozenItems(newItems);

    developer.log(
      '✅ Items added to order: ID $placedOrderId (Socket notification sent by backend)',
      name: 'REORDER_API',
    );

    // Show local notification
    await showOrderNotification(
      orderId: placedOrderId,
      tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
      itemCount: newItems.length,
      isNewOrder: false,
    );

    _showSuccessAndRefresh(
      context,
      tableInfo,
      tableId,
      'Items added to existing order',
    );
  }

  // ==================== UI ACTIONS ====================

  /// Toggle urgent status
  void toggleUrgentForTable(
      int tableId,
      BuildContext context,
      dynamic tableInfoData,
      ) {
    final TableInfo? tableInfo = _parseTableInfo(tableInfoData);
    final state = getTableState(tableId);

    state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;

    final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
    final message = state.isMarkAsUrgent.value
        ? 'Table $tableNumber marked as urgent'
        : 'Table $tableNumber removed from urgent';

    SnackBarUtil.show(
      context,
      message,
      title: state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
      type: state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
      duration: const Duration(seconds: 1),
    );
  }

  /// Navigate to add items screen
  void navigateToAddItems(int tableId, dynamic tableInfoData) {
    try {
      final Map<String, dynamic>? tableMap = tableInfoData is TableInfo
          ? tableInfoToMap(tableInfoData)
          : (tableInfoData as Map<String, dynamic>?);

      NavigationService.addItems(tableMap);
    } catch (e) {
      developer.log('Navigation error: $e');
      SnackBarUtil.showError(
        Get.context!,
        'Unable to proceed',
        title: 'Navigation Error',
      );
    }
  }

  /// Check if can proceed to checkout
  bool canProceedToCheckout(int tableId) {
    final state = getTableState(tableId);
    return state.isAvailableForNewOrder;
  }

  /// Get socket connection status
  bool get socketConnected => isSocketConnected.value;

  /// Manually reconnect socket if disconnected
  Future<void> reconnectSocket() async {
    if (!_socketService.isConnected) {
      developer.log(
        '🔄 Attempting to reconnect socket...',
        name: 'ORDER_MGMT.Socket',
      );
      _socketService.reconnect();
    } else {
      developer.log(
        '✅ Socket already connected',
        name: 'ORDER_MGMT.Socket',
      );
    }
  }

  // ==================== PRIVATE HELPERS ====================

  void _updateTotal(TableOrderState state) {
    final newTotal = TableOrderService.calculateTotal(state.orderItems);
    state.updateTotal(newTotal);
    developer.log(
      'TOTAL UPDATE → table:${state.tableId} total:₹$newTotal',
      name: 'UPDATE_TOTAL',
    );
  }

  void _removeItem(
      TableOrderState state,
      int index,
      BuildContext context,
      ) {
    final removedItem = state.orderItems.removeAt(index);
    _updateTotal(state);
    SnackBarUtil.showInfo(
      context,
      '${removedItem['item_name']} removed from order',
      title: 'Item Removed',
      duration: const Duration(seconds: 1),
    );
  }

  bool _isValidIndex(int index, int length, String operation) {
    if (index < 0 || index >= length) {
      developer.log('❌ Invalid index $index', name: operation);
      return false;
    }
    return true;
  }

  void _showCannotReduceWarning(BuildContext context, int frozenQty) {
    SnackBarUtil.showWarning(
      context,
      'Cannot reduce below sent quantity ($frozenQty)',
      title: 'Item Already Sent',
      duration: const Duration(seconds: 2),
    );
  }

  void _showCannotRemoveWarning(BuildContext context, int frozenQty) {
    SnackBarUtil.showWarning(
      context,
      'Cannot remove - $frozenQty already sent to kitchen',
      title: 'Item Already Sent',
      duration: const Duration(seconds: 2),
    );
  }

  void _showNoNewItemsWarning(BuildContext context) {
    SnackBarUtil.showWarning(
      context,
      'No new items to send. All items already sent to kitchen',
      title: 'Warning',
      duration: const Duration(seconds: 2),
    );
  }

  void _showSuccessAndRefresh(
      BuildContext context,
      TableInfo? tableInfo,
      int tableId,
      String message,
      ) {
    final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();

    SnackBarUtil.showSuccess(
      context,
      '$message for Table $tableNumber',
      title: 'Success',
      duration: const Duration(seconds: 2),
    );

    final state = getTableState(tableId);
    state.hasLoadedOrder.value = false;

    final controller = Get.find<TakeOrdersController>();
    controller.refreshTables();

    NavigationService.goBack();
  }

  void _logTableSnapshot(int tableId, TableOrderState state) {
    final buffer = StringBuffer();
    buffer.writeln('TABLE SNAPSHOT → table:$tableId');
    for (var i = 0; i < state.orderItems.length; i++) {
      final it = state.orderItems[i];
      final frozen = state.getFrozenQuantity(it['id'].toString());
      buffer.writeln(
        '[$i] id:${it['id']} name:${it['item_name']} qty:${it['quantity']} frozen:$frozen',
      );
    }
    buffer.writeln('FINAL TOTAL: ${state.finalCheckoutTotal.value}');
    developer.log(buffer.toString(), name: 'ORDER_STATE');
  }

  TableInfo? _parseTableInfo(dynamic tableInfoData) {
    if (tableInfoData is TableInfo) return tableInfoData;
    if (tableInfoData is Map<String, dynamic>) {
      return mapToTableInfo(tableInfoData);
    }
    return null;
  }

  Map<String, dynamic>? tableInfoToMap(TableInfo? tableInfo) {
    if (tableInfo == null) return null;
    return {
      'id': tableInfo.table.id,
      'tableNumber': tableInfo.table.tableNumber,
      'tableType': tableInfo.table.tableType,
      'capacity': tableInfo.table.capacity,
      'status': tableInfo.table.status,
      'description': tableInfo.table.description,
      'location': tableInfo.table.location,
      'areaName': tableInfo.areaName,
      'hotelOwnerId': tableInfo.table.hotelOwnerId,
      'tableAreaId': tableInfo.table.tableAreaId,
      'createdAt': tableInfo.table.createdAt,
      'updatedAt': tableInfo.table.updatedAt,
      'currentOrder': tableInfo.currentOrder?.toJson(),
    };
  }

  TableInfo? mapToTableInfo(Map<String, dynamic>? map) {
    if (map == null) return null;
    try {
      return TableInfo(
        table: Table(
          id: map['id'] as int,
          hotelOwnerId: map['hotelOwnerId'] as int,
          tableAreaId: map['tableAreaId'] as int,
          tableNumber: map['tableNumber'] as String,
          tableType: map['tableType'] as String,
          capacity: map['capacity'] as int,
          status: map['status'] as String,
          description: map['description'] as String?,
          location: map['location'] as String?,
          createdAt: map['createdAt'] as String,
          updatedAt: map['updatedAt'] as String,
        ),
        currentOrder: map['currentOrder'] != null
            ? CurrentOrder.fromJson(map['currentOrder'] as Map<String, dynamic>)
            : null,
        areaName: map['areaName'] as String,
      );
    } catch (e) {
      developer.log(
        'Error converting map to TableInfo: $e',
        name: 'MAP_CONVERSION',
      );
      return null;
    }
  }
}
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:developer' as developer;
// import '../../../core/constants/api_constant.dart';
// import '../../../core/services/api_service.dart';
// import '../../../core/utils/snakbar_utils.dart';
// import '../../../data/models/ResponseModel/order_model.dart';
// import '../../../data/models/ResponseModel/table_model.dart';
// import '../../../route/app_routes.dart';
//
//
// // Table-specific state model
// class TableOrderState {
//   final int tableId;
//   final orderItems = <Map<String, dynamic>>[].obs;
//   final isMarkAsUrgent = false.obs;
//   final finalCheckoutTotal = 0.0.obs;
//   final fullNameController = TextEditingController();
//   final phoneController = TextEditingController();
//
//   // Track frozen (sent to kitchen) quantities
//   final frozenItems = <Map<String, dynamic>>[].obs;
//   final hasFrozenItems = false.obs;
//
//   // Loading states
//   final isLoadingOrder = false.obs;
//   final hasLoadedOrder = false.obs;
//
//   TableOrderState({required this.tableId});
//
//   void dispose() {
//     fullNameController.dispose();
//     phoneController.dispose();
//   }
//
//   // Clear all data
//   void clearOrderData() {
//     fullNameController.clear();
//     phoneController.clear();
//     orderItems.clear();
//     frozenItems.clear();
//     finalCheckoutTotal.value = 0.0;
//     isMarkAsUrgent.value = false;
//     hasFrozenItems.value = false;
//     hasLoadedOrder.value = false;
//     developer.log('Cleared order data for table $tableId');
//   }
//
//   // Get frozen quantity for a specific item
//   int getFrozenQuantity(String itemId) {
//     final frozenItem = frozenItems.firstWhereOrNull(
//             (item) => item['id'].toString() == itemId.toString());
//     return frozenItem?['frozen_quantity'] ?? 0;
//   }
//
//   // Check if item has frozen quantity
//   bool hasItemFrozenQuantity(String itemId) {
//     return getFrozenQuantity(itemId) > 0;
//   }
// }
//
// // Main Order Management Controller
// class OrderManagementController extends GetxController {
//   final tableOrders = <int, TableOrderState>{}.obs;
//   final activeTableId = Rxn<int>();
//   final formKey = GlobalKey<FormState>();
//   final isLoading = false.obs;
//   final _isInitialized = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _isInitialized.value = true;
//     developer.log('OrderManagementController initialized');
//   }
//
//   @override
//   void onClose() {
//     for (var state in tableOrders.values) {
//       state.dispose();
//     }
//     tableOrders.clear();
//     super.onClose();
//   }
//
//   // Get or create table state
//   TableOrderState getTableState(int tableId) {
//     if (!tableOrders.containsKey(tableId)) {
//       tableOrders[tableId] = TableOrderState(tableId: tableId);
//       developer.log('Created new table state for table ID: $tableId');
//     }
//     return tableOrders[tableId]!;
//   }
//
//   // NEW: Fetch existing order from API
//   Future<void> fetchExistingOrder(int orderId, int tableId) async {
//     final state = getTableState(tableId);
//
//     // Skip if already loaded
//     if (state.hasLoadedOrder.value) {
//       developer.log('Order already loaded for table $tableId');
//       return;
//     }
//
//     if (orderId <= 0) {
//       developer.log('Invalid orderId: $orderId for table $tableId');
//       state.hasLoadedOrder.value = true; // Mark as loaded (empty order)
//       return;
//     }
//
//     try {
//       state.isLoadingOrder.value = true;
//       developer.log('Fetching order $orderId for table $tableId');
//
//       final response = await ApiService.get<OrderResponseModel>(
//         endpoint: ApiConstants.waiterGetTableOrder(orderId),
//         fromJson: (json) => OrderResponseModel.fromJson(json),
//         includeToken: true,
//       );
//
//       if (response.success && response.data != null) {
//         final orderData = response.data!;
//
//         // Populate customer info
//         if (orderData.data.order.customerName != null) {
//           state.fullNameController.text = orderData.data.order.customerName!;
//         }
//         if (orderData.data.order.customerPhone != null) {
//           state.phoneController.text = orderData.data.order.customerPhone!;
//         }
//
//         // Convert API items to local format and freeze them
//         state.orderItems.clear();
//         state.frozenItems.clear();
//
//         for (var apiItem in orderData.data.items) {
//           final localItem = apiItem.toLocalOrderItem();
//           state.orderItems.add(localItem);
//
//           // Freeze all existing items (they're already sent to kitchen)
//           state.frozenItems.add({
//             'id': apiItem.menuItemId,
//             'item_name': apiItem.itemName,
//             'frozen_quantity': apiItem.quantity,
//           });
//         }
//
//         state.hasFrozenItems.value = state.frozenItems.isNotEmpty;
//         _updateTableTotal(state);
//
//         developer.log('Successfully loaded ${orderData.data.items.length} items for table $tableId');
//         state.hasLoadedOrder.value = true;
//       } else {
//         // developer.log('Failed to fetch order: ${response.message}');
//         state.hasLoadedOrder.value = true; // Mark as loaded to prevent retry
//       }
//     } catch (e) {
//       developer.log('Error fetching order for table $tableId: $e');
//       state.hasLoadedOrder.value = true; // Mark as loaded to prevent retry
//
//       // Show error to user
//       if (Get.context != null) {
//         SnackBarUtil.showError(
//           Get.context!,
//           'Failed to load existing order. You can still add new items.',
//           title: 'Load Error',
//           duration: const Duration(seconds: 2),
//         );
//       }
//     } finally {
//       state.isLoadingOrder.value = false;
//     }
//   }
//
//   // Add item to specific table
//   void addItemToTable(int tableId, Map<String, dynamic> item) {
//     final state = getTableState(tableId);
//     state.orderItems.add(item);
//     _updateTableTotal(state);
//     developer.log('Item added to table $tableId: ${item['item_name']}');
//   }
//
//   // Update quantity of specific item
//   void updateItemQuantity(int tableId, int itemIndex, int newQuantity) {
//     final state = getTableState(tableId);
//     if (itemIndex >= 0 && itemIndex < state.orderItems.length && newQuantity > 0) {
//       final item = state.orderItems[itemIndex];
//       final frozenQuantity = state.getFrozenQuantity(item['id'].toString());
//
//       // Prevent setting quantity below frozen amount
//       if (newQuantity < frozenQuantity) {
//         developer.log('Cannot set quantity below frozen amount: $frozenQuantity');
//         return;
//       }
//
//       final price = item['price'] as double;
//       item['quantity'] = newQuantity;
//       item['total_price'] = price * newQuantity;
//
//       state.orderItems[itemIndex] = item;
//       _updateTableTotal(state);
//       developer.log('Updated quantity for ${item['item_name']} in table $tableId: $newQuantity');
//     }
//   }
//
//   // Calculate and update table total
//   void _updateTableTotal(TableOrderState state) {
//     double total = 0.0;
//     for (var item in state.orderItems) {
//       total += item['total_price'] as double;
//     }
//     state.finalCheckoutTotal.value = total;
//   }
//
//   // Set active table
//   void setActiveTable(int tableId, TableInfo? tableInfo) {
//     if (!_isInitialized.value) {
//       _setActiveTableInternal(tableId, tableInfo);
//     } else {
//       _setActiveTableInternal(tableId, tableInfo);
//     }
//   }
//
//   void _setActiveTableInternal(int tableId, TableInfo? tableInfo) {
//     activeTableId.value = tableId;
//     final state = getTableState(tableId);
//     developer.log('Active table set to: $tableId');
//
//     // Fetch existing order if available
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//     if (orderId > 0 && !state.hasLoadedOrder.value) {
//       fetchExistingOrder(orderId, tableId);
//     }
//   }
//
//   // Get current table state
//   TableOrderState? get currentTableState {
//     if (activeTableId.value == null) return null;
//     return getTableState(activeTableId.value!);
//   }
//
//   // Toggle urgent status
//   void toggleUrgentForTable(int tableId, BuildContext context, TableInfo? tableInfo) {
//     final state = getTableState(tableId);
//     state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
//
//     final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//
//     if (state.isMarkAsUrgent.value) {
//       SnackBarUtil.showSuccess(
//         context,
//         'Table $tableNumber marked as urgent',
//         title: 'Marked as urgent',
//         duration: const Duration(seconds: 1),
//       );
//     } else {
//       SnackBarUtil.showInfo(
//         context,
//         'Table $tableNumber removed from urgent',
//         title: 'Normal priority',
//         duration: const Duration(seconds: 1),
//       );
//     }
//
//     developer.log('Urgent status toggled for table $tableId: ${state.isMarkAsUrgent.value}');
//   }
//
//   // Navigation methods
//   void navigateToAddItems(int tableId, TableInfo? tableInfo) {
//     try {
//       final state = getTableState(tableId);
//       final tableMap = _tableInfoToMap(tableInfo);
//       NavigationService.addItems(tableMap);
//       developer.log('Navigating to add items for table $tableId');
//     } catch (e) {
//       developer.log('Navigation error: $e');
//       SnackBarUtil.showError(
//         Get.context!,
//         'Unable to proceed. Please try again.',
//         title: 'Navigation Error',
//         duration: const Duration(seconds: 1),
//       );
//     }
//   }
//
//   Map<String, dynamic>? _tableInfoToMap(TableInfo? tableInfo) {
//     if (tableInfo == null) return null;
//
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
//   void navigateBack() {
//     try {
//       if (Get.context!.canPop()) {
//         Get.context!.pop();
//       } else {
//         Get.context!.go('/take-orders');
//       }
//       developer.log('Navigating back');
//     } catch (e) {
//       developer.log('Back navigation error: $e');
//       Get.back();
//     }
//   }
//
//   // Send to chef method with freezing
//   Future<void> sendToChef(int tableId, context, TableInfo? tableInfo, List<Map<String, dynamic>> orderItems) async {
//     try {
//       isLoading.value = true;
//
//       final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//       final newItemsForKOT = _getNewItemsForKOT(tableId, orderItems);
//       final orderData = _prepareOrderData(tableId, tableInfo, newItemsForKOT, 'chef');
//
//       developer.log('Sending KOT to chef for table $tableId:');
//       developer.log('New items for KOT: ${newItemsForKOT.length}');
//       developer.log('Order Data: ${orderData.toString()}');
//
//       // TODO: Replace with actual API call
//       await Future.delayed(const Duration(seconds: 1));
//
//       _freezeOrderItems(tableId, orderItems);
//
//       SnackBarUtil.showSuccess(
//         context,
//         'KOT sent to chef for Table $tableNumber',
//         title: 'Sent to Chef',
//         duration: const Duration(seconds: 2),
//       );
//       NavigationService.goBack();
//
//       developer.log('KOT successfully sent to chef for table $tableId');
//     } catch (e) {
//       developer.log('Send to chef error for table $tableId: $e');
//       final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//
//       SnackBarUtil.showError(
//         context,
//         'Failed to send KOT to chef for Table $tableNumber. Please try again.',
//         title: 'Error',
//         duration: const Duration(seconds: 2),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Checkout process with freezing
//   Future<void> proceedToCheckout(int tableId, context, TableInfo? tableInfo, List<Map<String, dynamic>> orderItems) async {
//     try {
//       isLoading.value = true;
//
//       final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//       final newItemsForKOT = _getNewItemsForKOT(tableId, orderItems);
//       final orderData = _prepareOrderData(tableId, tableInfo, newItemsForKOT, 'manager');
//
//       developer.log('Processing checkout for table $tableId:');
//       developer.log('New items for KOT: ${newItemsForKOT.length}');
//       developer.log('Order Data: ${orderData.toString()}');
//
//       // TODO: Replace with actual API call
//       await Future.delayed(const Duration(seconds: 2));
//
//       _freezeOrderItems(tableId, orderItems);
//
//       SnackBarUtil.showSuccess(
//         context,
//         'KOT sent to manager for Table $tableNumber!',
//         title: 'Order Confirmed',
//         duration: const Duration(seconds: 3),
//       );
//
//       NavigationService.goBack();
//       developer.log('Order successfully submitted for table $tableId');
//     } catch (e) {
//       developer.log('Checkout error for table $tableId: $e');
//       final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//
//       SnackBarUtil.showError(
//         context,
//         'Failed to place order for Table $tableNumber. Please try again.',
//         title: 'Error',
//         duration: const Duration(seconds: 2),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Freeze order items after sending KOT
//   void _freezeOrderItems(int tableId, List<Map<String, dynamic>> orderItems) {
//     final state = getTableState(tableId);
//
//     for (var item in orderItems) {
//       final itemId = item['id'].toString();
//       final currentQuantity = item['quantity'] as int;
//
//       final frozenIndex = state.frozenItems.indexWhere(
//               (frozen) => frozen['id'].toString() == itemId
//       );
//
//       if (frozenIndex >= 0) {
//         state.frozenItems[frozenIndex]['frozen_quantity'] = currentQuantity;
//       } else {
//         state.frozenItems.add({
//           'id': item['id'],
//           'item_name': item['item_name'],
//           'frozen_quantity': currentQuantity,
//         });
//       }
//     }
//
//     state.hasFrozenItems.value = state.frozenItems.isNotEmpty;
//     developer.log('Frozen ${orderItems.length} items for table $tableId');
//   }
//
//   // Get only new items for KOT (quantities above frozen amounts)
//   List<Map<String, dynamic>> _getNewItemsForKOT(int tableId, List<Map<String, dynamic>> orderItems) {
//     final state = getTableState(tableId);
//     final newItems = <Map<String, dynamic>>[];
//
//     for (var item in orderItems) {
//       final itemId = item['id'].toString();
//       final currentQuantity = item['quantity'] as int;
//       final frozenQuantity = state.getFrozenQuantity(itemId);
//       final newQuantity = currentQuantity - frozenQuantity;
//
//       if (newQuantity > 0) {
//         final newItem = Map<String, dynamic>.from(item);
//         newItem['quantity'] = newQuantity;
//         newItem['total_price'] = (item['price'] as double) * newQuantity;
//         newItems.add(newItem);
//       }
//     }
//
//     return newItems;
//   }
//
//   // Helper method to prepare order data
//   Map<String, dynamic> _prepareOrderData(
//       int tableId,
//       TableInfo? tableInfo,
//       List<Map<String, dynamic>> orderItems,
//       String destination,
//       ) {
//     final state = getTableState(tableId);
//
//     return {
//       'orderId': 'ORD_${tableId}_${DateTime.now().millisecondsSinceEpoch}',
//       'tableId': tableId,
//       'tableNumber': tableInfo?.table.tableNumber,
//       'tableInfo': tableInfo?.toJson(),
//       'recipientName': state.fullNameController.text.trim(),
//       'phoneNumber': state.phoneController.text.trim(),
//       'isUrgent': state.isMarkAsUrgent.value,
//       'orderTime': DateTime.now().toIso8601String(),
//       'status': 'pending',
//       'isOccupied': true,
//       'destination': destination,
//       'items': orderItems.map((item) => {
//         'id': item['id'],
//         'name': item['item_name'],
//         'quantity': item['quantity'],
//         'price': item['price'],
//         'total_price': item['total_price'],
//         'category': item['category'],
//         'description': item['description'],
//         'is_vegetarian': item['is_vegetarian'],
//         'is_featured': item['is_featured'],
//       }).toList(),
//       'itemCount': orderItems.length,
//       'totalAmount': orderItems.fold<double>(0.0, (sum, item) => sum + (item['total_price'] as double)),
//     };
//   }
//
//   // Check if can proceed to checkout
//   bool canProceedToCheckout(int tableId) {
//     final state = getTableState(tableId);
//     return !isLoading.value && state.orderItems.isNotEmpty;
//   }
//
//   // Clear table orders
//   void clearTableOrders(int tableId) {
//     if (tableOrders.containsKey(tableId)) {
//       tableOrders[tableId]?.dispose();
//       tableOrders.remove(tableId);
//       developer.log('Table orders cleared for table $tableId');
//     }
//   }
//
//   // Increment item quantity
//   void incrementItemQuantity(int tableId, int itemIndex) {
//     final state = getTableState(tableId);
//     if (itemIndex >= 0 && itemIndex < state.orderItems.length) {
//       final item = state.orderItems[itemIndex];
//       final price = item['price'] as double;
//       final currentQuantity = item['quantity'] as int;
//       final newQuantity = currentQuantity + 1;
//
//       item['quantity'] = newQuantity;
//       item['total_price'] = price * newQuantity;
//
//       state.orderItems[itemIndex] = item;
//       _updateTableTotal(state);
//
//       developer.log('Incremented ${item['item_name']} to quantity $newQuantity in table $tableId');
//     }
//   }
//
//   // Decrement item quantity (with proper frozen quantity logic)
//   void decrementItemQuantity(int tableId, int itemIndex, context) {
//     final state = getTableState(tableId);
//     if (itemIndex >= 0 && itemIndex < state.orderItems.length) {
//       final item = state.orderItems[itemIndex];
//       final currentQuantity = item['quantity'] as int;
//       final frozenQuantity = state.getFrozenQuantity(item['id'].toString());
//
//       if (frozenQuantity == 0) {
//         if (currentQuantity > 1) {
//           final price = item['price'] as double;
//           final newQuantity = currentQuantity - 1;
//
//           item['quantity'] = newQuantity;
//           item['total_price'] = price * newQuantity;
//
//           state.orderItems[itemIndex] = item;
//           _updateTableTotal(state);
//
//           developer.log('Decremented ${item['item_name']} to quantity $newQuantity in table $tableId');
//         } else if (currentQuantity == 1) {
//           removeItemFromTable(tableId, itemIndex, context, fromDecrement: true);
//         }
//       } else {
//         if (currentQuantity > frozenQuantity) {
//           final price = item['price'] as double;
//           final newQuantity = currentQuantity - 1;
//
//           item['quantity'] = newQuantity;
//           item['total_price'] = price * newQuantity;
//
//           state.orderItems[itemIndex] = item;
//           _updateTableTotal(state);
//
//           developer.log('Decremented ${item['item_name']} to quantity $newQuantity in table $tableId');
//         } else {
//           SnackBarUtil.showWarning(
//             context,
//             'Cannot reduce below sent quantity ($frozenQuantity)',
//             title: 'Item Already Sent',
//             duration: const Duration(seconds: 2),
//           );
//         }
//       }
//     }
//   }
//
//   // Remove item from table (allow removal from decrement logic)
//   void removeItemFromTable(int tableId, int itemIndex, context, {bool fromDecrement = false}) {
//     final state = getTableState(tableId);
//     if (itemIndex >= 0 && itemIndex < state.orderItems.length) {
//       final item = state.orderItems[itemIndex];
//       final frozenQuantity = state.getFrozenQuantity(item['id'].toString());
//
//       if (frozenQuantity > 0 && !fromDecrement) {
//         SnackBarUtil.showWarning(
//           context,
//           'Cannot remove item - $frozenQuantity already sent to kitchen',
//           title: 'Item Already Sent',
//           duration: const Duration(seconds: 2),
//         );
//         return;
//       }
//
//       final removedItem = state.orderItems.removeAt(itemIndex);
//       _updateTableTotal(state);
//
//       developer.log('Removed ${removedItem['item_name']} from table $tableId');
//
//       SnackBarUtil.showInfo(
//         context,
//         '${removedItem['item_name']} removed from order',
//         title: 'Item Removed',
//         duration: const Duration(seconds: 1),
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../core/constants/api_constant.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/ResponseModel/order_model.dart';
import '../../../data/models/ResponseModel/table_model.dart';
import '../../../route/app_routes.dart';

// Simplified frozen item tracking
class FrozenItem {
  final String id;
  final String name;
  final int quantity;

  FrozenItem({required this.id, required this.name, required this.quantity});
}

// Streamlined table state
class TableOrderState {
  final int tableId;
  final orderItems = <Map<String, dynamic>>[].obs;
  final frozenItems = <FrozenItem>[].obs;
  final isMarkAsUrgent = false.obs;
  final finalCheckoutTotal = 0.0.obs;
  final isLoadingOrder = false.obs;
  final hasLoadedOrder = false.obs;
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  TableOrderState({required this.tableId});

  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
  }

  void clear() {
    fullNameController.clear();
    phoneController.clear();
    orderItems.clear();
    frozenItems.clear();
    finalCheckoutTotal.value = 0.0;
    isMarkAsUrgent.value = false;
    hasLoadedOrder.value = false;
  }

  int getFrozenQuantity(String itemId) {
    return frozenItems
        .firstWhereOrNull((item) => item.id == itemId)
        ?.quantity ?? 0;
  }

  bool get hasFrozenItems => frozenItems.isNotEmpty;
}

class OrderManagementController extends GetxController {
  final tableOrders = <int, TableOrderState>{}.obs;
  final activeTableId = Rxn<int>();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    // fetchExistingOrder(); // Dummy call to initialize
    developer.log('OrderManagementController initialized');
  }

  @override
  void onClose() {
    tableOrders.values.forEach((state) => state.dispose());
    tableOrders.clear();
    super.onClose();
  }

  TableOrderState getTableState(int tableId) {
    return tableOrders.putIfAbsent(
      tableId,
          () => TableOrderState(tableId: tableId),
    );
  }

  TableOrderState? get currentTableState =>
      activeTableId.value != null ? getTableState(activeTableId.value!) : null;

  // Fetch existing order
  Future<void> fetchExistingOrder(int orderId, int tableId) async {
    final state = getTableState(tableId);
    if (state.hasLoadedOrder.value || orderId <= 0) {
      state.hasLoadedOrder.value = true;
      return;
    }

    try {
      state.isLoadingOrder.value = true;
      final response = await ApiService.get<OrderResponseModel>(
        endpoint: ApiConstants.waiterGetTableOrder(orderId),
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (response.success && response.data != null) {
        final orderData = response.data!;

        // Populate customer info
        state.fullNameController.text = orderData.data.order.customerName ?? '';
        state.phoneController.text = orderData.data.order.customerPhone ?? '';

        // Load items and freeze them
        state.orderItems.clear();
        state.frozenItems.clear();

        for (var apiItem in orderData.data.items) {
          final localItem = apiItem.toLocalOrderItem();
          state.orderItems.add(localItem);
          state.frozenItems.add(FrozenItem(
            id: apiItem.menuItemId.toString(),
            name: apiItem.itemName,
            quantity: apiItem.quantity,
          ));
        }

        _updateTotal(state);
        developer.log('Loaded ${orderData.data.items.length} items for table $tableId');
      }
    } catch (e) {
      developer.log('Error fetching order: $e');
      if (Get.context != null) {
        SnackBarUtil.showError(
          Get.context!,
          'Failed to load existing order',
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      state.isLoadingOrder.value = false;
      state.hasLoadedOrder.value = true;
    }
  }

  // Set active table and fetch order
  void setActiveTable(int tableId, TableInfo? tableInfo) {
    activeTableId.value = tableId;
    final state = getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;

    if (orderId > 0 && !state.hasLoadedOrder.value) {
      fetchExistingOrder(orderId, tableId);
    }
  }

  // Item management
  void addItemToTable(int tableId, Map<String, dynamic> item) {
    final state = getTableState(tableId);
    state.orderItems.add(item);
    _updateTotal(state);
  }

  void incrementItemQuantity(int tableId, int index) {
    final state = getTableState(tableId);
    if (index < 0 || index >= state.orderItems.length) return;

    final item = state.orderItems[index];
    final quantity = (item['quantity'] as int) + 1;
    _updateItemQuantity(state, index, quantity);
  }

  void decrementItemQuantity(int tableId, int index, BuildContext context) {
    final state = getTableState(tableId);
    if (index < 0 || index >= state.orderItems.length) return;

    final item = state.orderItems[index];
    final currentQty = item['quantity'] as int;
    final frozenQty = state.getFrozenQuantity(item['id'].toString());

    if (frozenQty == 0) {
      // Before KOT: can reduce to 0 (removes item)
      if (currentQty > 1) {
        _updateItemQuantity(state, index, currentQty - 1);
      } else {
        _removeItem(state, index, context, fromDecrement: true);
      }
    } else {
      // After KOT: cannot go below frozen quantity
      if (currentQty > frozenQty) {
        _updateItemQuantity(state, index, currentQty - 1);
      } else {
        SnackBarUtil.showWarning(
          context,
          'Cannot reduce below sent quantity ($frozenQty)',
          title: 'Item Already Sent',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void removeItemFromTable(int tableId, int index, BuildContext context) {
    final state = getTableState(tableId);
    if (index < 0 || index >= state.orderItems.length) return;

    final item = state.orderItems[index];
    final frozenQty = state.getFrozenQuantity(item['id'].toString());

    if (frozenQty > 0) {
      SnackBarUtil.showWarning(
        context,
        'Cannot remove - $frozenQty already sent to kitchen',
        title: 'Item Already Sent',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _removeItem(state, index, context);
  }

  void _updateItemQuantity(TableOrderState state, int index, int quantity) {
    final item = state.orderItems[index];
    final price = item['price'] as double;
    item['quantity'] = quantity;
    item['total_price'] = price * quantity;
    state.orderItems[index] = item;
    _updateTotal(state);
  }

  void _removeItem(TableOrderState state, int index, BuildContext context, {bool fromDecrement = false}) {
    final removedItem = state.orderItems.removeAt(index);
    _updateTotal(state);
    SnackBarUtil.showInfo(
      context,
      '${removedItem['item_name']} removed from order',
      title: 'Item Removed',
      duration: const Duration(seconds: 1),
    );
  }

  void _updateTotal(TableOrderState state) {
    state.finalCheckoutTotal.value = state.orderItems.fold<double>(
      0.0,
          (sum, item) => sum + (item['total_price'] as double),
    );
  }

  // Toggle urgent status
  void toggleUrgentForTable(int tableId, BuildContext context, TableInfo? tableInfo) {
    final state = getTableState(tableId);
    state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
    final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();

    SnackBarUtil.show(
      context,
      state.isMarkAsUrgent.value
          ? 'Table $tableNumber marked as urgent'
          : 'Table $tableNumber removed from urgent',
      title: state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
      type: state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
      duration: const Duration(seconds: 1),
    );

  }

  // Send to chef
  Future<void> sendToChef(int tableId, BuildContext context, TableInfo? tableInfo, List<Map<String, dynamic>> orderItems) async {
    await _processOrder(
      tableId: tableId,
      context: context,
      tableInfo: tableInfo,
      orderItems: orderItems,
      destination: 'chef',
      successMessage: 'KOT sent to chef',
      errorMessage: 'Failed to send KOT to chef',
    );
  }

  // Checkout
  Future<void> proceedToCheckout(int tableId, BuildContext context, TableInfo? tableInfo, List<Map<String, dynamic>> orderItems) async {
    await _processOrder(
      tableId: tableId,
      context: context,
      tableInfo: tableInfo,
      orderItems: orderItems,
      destination: 'manager',
      successMessage: 'KOT sent to manager',
      errorMessage: 'Failed to place order',
    );
  }

  // Unified order processing
  Future<void> _processOrder({
    required int tableId,
    required BuildContext context,
    required TableInfo? tableInfo,
    required List<Map<String, dynamic>> orderItems,
    required String destination,
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      isLoading.value = true;
      final state = getTableState(tableId);
      final newItems = _getNewItems(state, orderItems);

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      _freezeItems(state, orderItems);

      final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
      SnackBarUtil.showSuccess(
        context,
        '$successMessage for Table $tableNumber',
        title: 'Success',
        duration: const Duration(seconds: 2),
      );

      NavigationService.goBack();
    } catch (e) {
      developer.log('Order processing error: $e');
      SnackBarUtil.showError(
        context,
        errorMessage,
        title: 'Error',
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _getNewItems(TableOrderState state, List<Map<String, dynamic>> items) {
    return items.where((item) {
      final frozenQty = state.getFrozenQuantity(item['id'].toString());
      final currentQty = item['quantity'] as int;
      return currentQty > frozenQty;
    }).map((item) {
      final frozenQty = state.getFrozenQuantity(item['id'].toString());
      final newQty = (item['quantity'] as int) - frozenQty;
      return {
        ...item,
        'quantity': newQty,
        'total_price': (item['price'] as double) * newQty,
      };
    }).toList();
  }

  void _freezeItems(TableOrderState state, List<Map<String, dynamic>> items) {
    for (var item in items) {
      final itemId = item['id'].toString();
      final quantity = item['quantity'] as int;

      final existingIndex = state.frozenItems.indexWhere((f) => f.id == itemId);
      if (existingIndex >= 0) {
        state.frozenItems[existingIndex] = FrozenItem(
          id: itemId,
          name: item['item_name'],
          quantity: quantity,
        );
      } else {
        state.frozenItems.add(FrozenItem(
          id: itemId,
          name: item['item_name'],
          quantity: quantity,
        ));
      }
    }
  }

  // Navigation
  void navigateToAddItems(int tableId, TableInfo? tableInfo) {
    try {
      NavigationService.addItems(tableInfoToMap(tableInfo));
    } catch (e) {
      developer.log('Navigation error: $e');
      SnackBarUtil.showError(
        Get.context!,
        'Unable to proceed',
        title: 'Navigation Error',
        duration: const Duration(seconds: 1),
      );
    }
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

  bool canProceedToCheckout(int tableId) {
    final state = getTableState(tableId);
    return !isLoading.value && state.orderItems.isNotEmpty;
  }

  void clearTableOrders(int tableId) {
    if (tableOrders.containsKey(tableId)) {
      tableOrders[tableId]?.dispose();
      tableOrders.remove(tableId);
    }
  }
}
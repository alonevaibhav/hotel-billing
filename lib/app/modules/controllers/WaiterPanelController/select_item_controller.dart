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
// // Simplified frozen item tracking
// class FrozenItem {
//   final String id;
//   final String name;
//   final int quantity;
//
//   FrozenItem({required this.id, required this.name, required this.quantity});
// }
//
// // Streamlined table state
// class TableOrderState {
//   final int tableId;
//   final orderItems = <Map<String, dynamic>>[].obs;
//   final frozenItems = <FrozenItem>[].obs;
//   final isMarkAsUrgent = false.obs;
//   final finalCheckoutTotal = 0.0.obs;
//   final isLoadingOrder = false.obs;
//   final hasLoadedOrder = false.obs;
//   final fullNameController = TextEditingController();
//   final phoneController = TextEditingController();
//
//   TableOrderState({required this.tableId});
//
//   void dispose() {
//     fullNameController.dispose();
//     phoneController.dispose();
//   }
//
//   void clear() {
//     fullNameController.clear();
//     phoneController.clear();
//     orderItems.clear();
//     frozenItems.clear();
//     finalCheckoutTotal.value = 0.0;
//     isMarkAsUrgent.value = false;
//     hasLoadedOrder.value = false;
//   }
//
//   int getFrozenQuantity(String itemId) {
//     return frozenItems
//             .firstWhereOrNull((item) => item.id == itemId)
//             ?.quantity ??
//         0;
//   }
//
//   bool get hasFrozenItems => frozenItems.isNotEmpty;
// }
//
// class OrderManagementController extends GetxController {
//   final tableOrders = <int, TableOrderState>{}.obs;
//   final activeTableId = Rxn<int>();
//   final formKey = GlobalKey<FormState>();
//   final isLoading = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // fetchExistingOrder(); // Dummy call to initialize
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
//   // TableOrderState getTableState(int tableId) {
//   //   return tableOrders.putIfAbsent(
//   //     tableId,
//   //         () => TableOrderState(tableId: tableId),
//   //   );
//   // }
//
//   TableOrderState? get currentTableState =>
//       activeTableId.value != null ? getTableState(activeTableId.value!) : null;
//
//   // Fetch existing order
//   Future<void> fetchExistingOrder(int orderId, int tableId) async {
//     final state = getTableState(tableId);
//     if (state.hasLoadedOrder.value || orderId <= 0) {
//       state.hasLoadedOrder.value = true;
//       return;
//     }
//
//     try {
//       state.isLoadingOrder.value = true;
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
//         state.fullNameController.text = orderData.data.order.customerName ?? '';
//         state.phoneController.text = orderData.data.order.customerPhone ?? '';
//
//         // Load items and freeze them
//         state.orderItems.clear();
//         state.frozenItems.clear();
//
//         for (var apiItem in orderData.data.items) {
//           final localItem = apiItem.toLocalOrderItem();
//           state.orderItems.add(localItem);
//           state.frozenItems.add(FrozenItem(
//             id: apiItem.menuItemId.toString(),
//             name: apiItem.itemName,
//             quantity: apiItem.quantity,
//           ));
//         }
//
//         _updateTotal(state);
//         developer.log(
//             'Loaded ${orderData.data.items.length} items for table $tableId');
//       }
//     } catch (e) {
//       developer.log('Error fetching order: $e');
//       if (Get.context != null) {
//         SnackBarUtil.showError(
//           Get.context!,
//           'Failed to load existing order',
//           duration: const Duration(seconds: 2),
//         );
//       }
//     } finally {
//       state.isLoadingOrder.value = false;
//       state.hasLoadedOrder.value = true;
//     }
//   }
//
//   // Set active table and fetch order
//   // void setActiveTable(int tableId, TableInfo? tableInfo) {
//   //   activeTableId.value = tableId;
//   //   final state = getTableState(tableId);
//   //   final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//   //
//   //   if (orderId > 0 && !state.hasLoadedOrder.value) {
//   //     fetchExistingOrder(orderId, tableId);
//   //   }
//   // }
//
//   // Item management
//   // void addItemToTable(int tableId, Map<String, dynamic> item) {
//   //   final state = getTableState(tableId);
//   //   state.orderItems.add(item);
//   //   _updateTotal(state);
//   // }
//
//   // void incrementItemQuantity(int tableId, int index) {
//   //   final state = getTableState(tableId);
//   //   if (index < 0 || index >= state.orderItems.length) return;
//   //
//   //   final item = state.orderItems[index];
//   //   final quantity = (item['quantity'] as int) + 1;
//   //   _updateItemQuantity(state, index, quantity);
//   // }
//
//   // void decrementItemQuantity(int tableId, int index, BuildContext context) {
//   //   final state = getTableState(tableId);
//   //   if (index < 0 || index >= state.orderItems.length) return;
//   //
//   //   final item = state.orderItems[index];
//   //   final currentQty = item['quantity'] as int;
//   //   final frozenQty = state.getFrozenQuantity(item['id'].toString());
//   //
//   //   if (frozenQty == 0) {
//   //     // Before KOT: can reduce to 0 (removes item)
//   //     if (currentQty > 1) {
//   //       _updateItemQuantity(state, index, currentQty - 1);
//   //     } else {
//   //       _removeItem(state, index, context, fromDecrement: true);
//   //     }
//   //   } else {
//   //     // After KOT: cannot go below frozen quantity
//   //     if (currentQty > frozenQty) {
//   //       _updateItemQuantity(state, index, currentQty - 1);
//   //     } else {
//   //       SnackBarUtil.showWarning(
//   //         context,
//   //         'Cannot reduce below sent quantity ($frozenQty)',
//   //         title: 'Item Already Sent',
//   //         duration: const Duration(seconds: 2),
//   //       );
//   //     }
//   //   }
//   // }
//
//   // void removeItemFromTable(int tableId, int index, BuildContext context) {
//   //   final state = getTableState(tableId);
//   //   if (index < 0 || index >= state.orderItems.length) return;
//   //
//   //   final item = state.orderItems[index];
//   //   final frozenQty = state.getFrozenQuantity(item['id'].toString());
//   //
//   //   if (frozenQty > 0) {
//   //     SnackBarUtil.showWarning(
//   //       context,
//   //       'Cannot remove - $frozenQty already sent to kitchen',
//   //       title: 'Item Already Sent',
//   //       duration: const Duration(seconds: 2),
//   //     );
//   //     return;
//   //   }
//   //
//   //   _removeItem(state, index, context);
//   // }
//
//   // void _updateItemQuantity(TableOrderState state, int index, int quantity) {
//   //   final item = state.orderItems[index];
//   //   final price = item['price'] as double;
//   //   item['quantity'] = quantity;
//   //   item['total_price'] = price * quantity;
//   //   state.orderItems[index] = item;
//   //   _updateTotal(state);
//   // }
//
//   void _removeItem(TableOrderState state, int index, BuildContext context,
//       {bool fromDecrement = false}) {
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
//   // void _updateTotal(TableOrderState state) {
//   //   state.finalCheckoutTotal.value = state.orderItems.fold<double>(
//   //     0.0,
//   //         (sum, item) => sum + (item['total_price'] as double),
//   //   );
//   // }
//
//   // Toggle urgent status
//   // void toggleUrgentForTable(int tableId, BuildContext context, TableInfo? tableInfo) {
//   //   final state = getTableState(tableId);
//   //   state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
//   //   final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//   //
//   //   SnackBarUtil.show(
//   //     context,
//   //     state.isMarkAsUrgent.value
//   //         ? 'Table $tableNumber marked as urgent'
//   //         : 'Table $tableNumber removed from urgent',
//   //     title: state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
//   //     type: state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
//   //     duration: const Duration(seconds: 1),
//   //   );
//   //
//   // }
//
//   // Send to chef
//   Future<void> sendToChef(int tableId, BuildContext context,
//       TableInfo? tableInfo, List<Map<String, dynamic>> orderItems) async {
//     await _processOrder(
//       tableId: tableId,
//       context: context,
//       tableInfo: tableInfo,
//       orderItems: orderItems,
//       destination: 'chef',
//       successMessage: 'KOT sent to chef',
//       errorMessage: 'Failed to send KOT to chef',
//     );
//   }
//
//   // Checkout
//   Future<void> proceedToCheckout(int tableId, BuildContext context,
//       TableInfo? tableInfo, List<Map<String, dynamic>> orderItems) async {
//     await _processOrder(
//       tableId: tableId,
//       context: context,
//       tableInfo: tableInfo,
//       orderItems: orderItems,
//       destination: 'manager',
//       successMessage: 'KOT sent to manager',
//       errorMessage: 'Failed to place order',
//     );
//   }
//
//   // Unified order processing
//   Future<void> _processOrder({
//     required int tableId,
//     required BuildContext context,
//     required TableInfo? tableInfo,
//     required List<Map<String, dynamic>> orderItems,
//     required String destination,
//     required String successMessage,
//     required String errorMessage,
//   }) async {
//     try {
//       isLoading.value = true;
//       final state = getTableState(tableId);
//       final newItems = _getNewItems(state, orderItems);
//
//       // TODO: Replace with actual API call
//       await Future.delayed(const Duration(seconds: 1));
//
//       _freezeItems(state, orderItems);
//
//       final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//       SnackBarUtil.showSuccess(
//         context,
//         '$successMessage for Table $tableNumber',
//         title: 'Success',
//         duration: const Duration(seconds: 2),
//       );
//
//       NavigationService.goBack();
//     } catch (e) {
//       developer.log('Order processing error: $e');
//       SnackBarUtil.showError(
//         context,
//         errorMessage,
//         title: 'Error',
//         duration: const Duration(seconds: 2),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   List<Map<String, dynamic>> _getNewItems(
//       TableOrderState state, List<Map<String, dynamic>> items) {
//     return items.where((item) {
//       final frozenQty = state.getFrozenQuantity(item['id'].toString());
//       final currentQty = item['quantity'] as int;
//       return currentQty > frozenQty;
//     }).map((item) {
//       final frozenQty = state.getFrozenQuantity(item['id'].toString());
//       final newQty = (item['quantity'] as int) - frozenQty;
//       return {
//         ...item,
//         'quantity': newQty,
//         'total_price': (item['price'] as double) * newQty,
//       };
//     }).toList();
//   }
//
//   void _freezeItems(TableOrderState state, List<Map<String, dynamic>> items) {
//     for (var item in items) {
//       final itemId = item['id'].toString();
//       final quantity = item['quantity'] as int;
//
//       final existingIndex = state.frozenItems.indexWhere((f) => f.id == itemId);
//       if (existingIndex >= 0) {
//         state.frozenItems[existingIndex] = FrozenItem(
//           id: itemId,
//           name: item['item_name'],
//           quantity: quantity,
//         );
//       } else {
//         state.frozenItems.add(FrozenItem(
//           id: itemId,
//           name: item['item_name'],
//           quantity: quantity,
//         ));
//       }
//     }
//   }
//
//   // Navigation
//   void navigateToAddItems(int tableId, TableInfo? tableInfo) {
//     try {
//       NavigationService.addItems(tableInfoToMap(tableInfo));
//     } catch (e) {
//       developer.log('Navigation error: $e');
//       SnackBarUtil.showError(
//         Get.context!,
//         'Unable to proceed',
//         title: 'Navigation Error',
//         duration: const Duration(seconds: 1),
//       );
//     }
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
//   bool canProceedToCheckout(int tableId) {
//     final state = getTableState(tableId);
//     return !isLoading.value && state.orderItems.isNotEmpty;
//   }
//
//   void clearTableOrders(int tableId) {
//     if (tableOrders.containsKey(tableId)) {
//       tableOrders[tableId]?.dispose();
//       tableOrders.remove(tableId);
//     }
//   }
//
//   void addItemToTable(int tableId, Map<String, dynamic> item) {
//     final state = getTableState(tableId);
//
//     developer.log("Add item to table $tableId", name: "ADD_ITEM");
//
//     if (item['id'] == null || item['id'] <= 0) {
//       developer.log("Invalid ID: ${item['id']}", name: "ADD_ITEM");
//       return;
//     }
//
//     if (item['quantity'] == null || item['quantity'] <= 0) {
//       developer.log("Invalid Quantity: ${item['quantity']}", name: "ADD_ITEM");
//       return;
//     }
//
//     state.orderItems.add(item);
//     _updateTotal(state);
//
//     developer.log("Item added. Total items: ${state.orderItems.length}",
//         name: "ADD_ITEM");
//   }
//
//   void incrementItemQuantity(int tableId, int index) {
//     final state = getTableState(tableId);
//
//     if (index < 0 || index >= state.orderItems.length) {
//       developer.log("Invalid index $index", name: "INCREMENT_ITEM");
//       return;
//     }
//
//     final item = state.orderItems[index];
//     final newQty = (item['quantity'] as int) + 1;
//
//     developer.log("Incrementing item ${item['item_name']} to $newQty",
//         name: "INCREMENT_ITEM");
//
//     _updateItemQuantity(state, index, newQty);
//   }
//
//   void decrementItemQuantity(int tableId, int index, BuildContext context) {
//     final state = getTableState(tableId);
//
//     if (index < 0 || index >= state.orderItems.length) {
//       developer.log("Invalid index $index", name: "DECREMENT");
//       return;
//     }
//
//     final item = state.orderItems[index];
//     final currentQty = item['quantity'] as int;
//     final frozenQty = state.getFrozenQuantity(item['id'].toString());
//
//     if (frozenQty == 0) {
//       if (currentQty > 1) {
//         _updateItemQuantity(state, index, currentQty - 1);
//         developer.log("Decreased ${item['item_name']} to ${currentQty - 1}",
//             name: "DECREMENT");
//       } else {
//         _removeItem(state, index, context, fromDecrement: true);
//         developer.log("Removed item ${item['item_name']}", name: "DECREMENT");
//       }
//     } else {
//       if (currentQty > frozenQty) {
//         _updateItemQuantity(state, index, currentQty - 1);
//         developer.log("Decreased item but not below frozen level",
//             name: "DECREMENT");
//       } else {
//         developer.log("Cannot reduce below frozen qty ($frozenQty)",
//             name: "DECREMENT");
//       }
//     }
//   }
//
//   void removeItemFromTable(int tableId, int index, BuildContext context) {
//     final state = getTableState(tableId);
//
//     if (index < 0 || index >= state.orderItems.length) {
//       developer.log("Invalid index $index", name: "REMOVE_ITEM");
//       return;
//     }
//
//     final item = state.orderItems[index];
//     final frozenQty = state.getFrozenQuantity(item['id'].toString());
//
//     if (frozenQty > 0) {
//       developer.log("Cannot remove. $frozenQty items frozen.",
//           name: "REMOVE_ITEM");
//       return;
//     }
//
//     _removeItem(state, index, context);
//     developer.log("Item removed: ${item['item_name']}", name: "REMOVE_ITEM");
//   }
//
//   void _updateItemQuantity(TableOrderState state, int index, int quantity) {
//     final item = state.orderItems[index];
//     final price = item['price'] as double;
//
//     item['quantity'] = quantity;
//     item['total_price'] = price * quantity;
//     state.orderItems[index] = item;
//
//     developer.log(
//       "Updated qty: ${item['item_name']} -> $quantity, total: ${item['total_price']}",
//       name: "UPDATE_QTY",
//     );
//
//     _updateTotal(state);
//   }
//
//   void _updateTotal(TableOrderState state) {
//     final newTotal = state.orderItems.fold<double>(
//       0.0,
//       (sum, item) => sum + (item['total_price'] as double),
//     );
//
//     state.finalCheckoutTotal.value = newTotal;
//
//     developer.log("Updated table total → ₹$newTotal", name: "UPDATE_TOTAL");
//   }
//
//   TableOrderState getTableState(int tableId) {
//     final state = tableOrders.putIfAbsent(
//       tableId,
//       () => TableOrderState(tableId: tableId),
//     );
//
//     developer.log("Table loaded ($tableId). Items: ${state.orderItems.length}",
//         name: "TABLE_STATE");
//
//     return state;
//   }
//
//   void setActiveTable(int tableId, TableInfo? tableInfo) {
//     activeTableId.value = tableId;
//     final state = getTableState(tableId);
//
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//     if (orderId > 0 && !state.hasLoadedOrder.value) {
//       developer.log("Loading existing order $orderId for table $tableId",
//           name: "ACTIVE_TABLE");
//       fetchExistingOrder(orderId, tableId);
//     }
//   }
//
//   void toggleUrgentForTable(
//       int tableId, BuildContext context, TableInfo? tableInfo) {
//     final state = getTableState(tableId);
//
//     state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
//
//     developer.log(
//       "Urgent status changed: ${state.isMarkAsUrgent.value}",
//       name: "URGENT",
//     );
//
//     final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//
//     SnackBarUtil.show(
//       context,
//       state.isMarkAsUrgent.value
//           ? 'Table $tableNumber marked as urgent'
//           : 'Table $tableNumber removed from urgent',
//       title:
//           state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
//       type:
//           state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
//       duration: const Duration(seconds: 1),
//     );
//   }
// }

import 'package:flutter/material.dart' hide Table;
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../core/constants/api_constant.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/RequestModel/create_order_request.dart';
import '../../../data/models/ResponseModel/order_model.dart' hide OrderData;
import '../../../data/models/ResponseModel/table_model.dart';
import '../../../route/app_routes.dart';

class FrozenItem {
  final String id;
  final String name;
  final int quantity;

  FrozenItem({required this.id, required this.name, required this.quantity});
}

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
            ?.quantity ??
        0;
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
    developer.log('OrderManagementController initialized');
  }

  @override
  void onClose() {
    tableOrders.values.forEach((state) => state.dispose());
    tableOrders.clear();
    super.onClose();
  }

  TableOrderState getTableState(int tableId) {
    final state = tableOrders.putIfAbsent(
      tableId,
      () => TableOrderState(tableId: tableId),
    );
    developer.log("Table loaded ($tableId). Items: ${state.orderItems.length}",
        name: "TABLE_STATE");
    return state;
  }

  // void setActiveTable(int tableId, TableInfo? tableInfo) {
  //   activeTableId.value = tableId;
  //   final state = getTableState(tableId);
  //   final orderId = tableInfo?.currentOrder?.orderId ?? 0;
  //   if (orderId > 0 && !state.hasLoadedOrder.value) {
  //     developer.log("Loading existing order $orderId for table $tableId", name: "ACTIVE_TABLE");
  //     fetchExistingOrder(orderId, tableId);
  //   }
  // }

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
        state.fullNameController.text = orderData.data.order.customerName ?? '';
        state.phoneController.text = orderData.data.order.customerPhone ?? '';
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
        developer.log(
            'Loaded ${orderData.data.items.length} items for table $tableId');
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

  // Send to chef
  // Future<void> sendToChef(int tableId, BuildContext context,
  //     TableInfo? tableInfo, List<Map<String, dynamic>> orderItems) async {
  //   await _processOrder(
  //     tableId: tableId,
  //     context: context,
  //     tableInfo: tableInfo,
  //     orderItems: orderItems,
  //     destination: 'chef',
  //     successMessage: 'KOT sent to chef',
  //     errorMessage: 'Failed to send KOT to chef',
  //   );
  // }

  // Checkout
  // Future<void> proceedToCheckout(int tableId, BuildContext context,
  //     TableInfo? tableInfo, List<Map<String, dynamic>> orderItems) async {
  //   await _processOrder(
  //     tableId: tableId,
  //     context: context,
  //     tableInfo: tableInfo,
  //     orderItems: orderItems,
  //     destination: 'manager',
  //     successMessage: 'KOT sent to manager',
  //     errorMessage: 'Failed to place order',
  //   );
  // }

  // Unified order processing
  // Future<void> _processOrder({
  //   required int tableId,
  //   required BuildContext context,
  //   required TableInfo? tableInfo,
  //   required List<Map<String, dynamic>> orderItems,
  //   required String destination,
  //   required String successMessage,
  //   required String errorMessage,
  // }) async {
  //   try {
  //     isLoading.value = true;
  //     final state = getTableState(tableId);
  //     final newItems = _getNewItems(state, orderItems);
  //
  //     // TODO: Replace with actual API call
  //     await Future.delayed(const Duration(seconds: 1));
  //
  //     _freezeItems(state, orderItems);
  //
  //     final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
  //     SnackBarUtil.showSuccess(
  //       context,
  //       '$successMessage for Table $tableNumber',
  //       title: 'Success',
  //       duration: const Duration(seconds: 2),
  //     );
  //
  //     NavigationService.goBack();
  //   } catch (e) {
  //     developer.log('Order processing error: $e');
  //     SnackBarUtil.showError(
  //       context,
  //       errorMessage,
  //       title: 'Error',
  //       duration: const Duration(seconds: 2),
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  List<Map<String, dynamic>> _getNewItems(
      TableOrderState state, List<Map<String, dynamic>> items) {
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

  void addItemToTable(int tableId, Map<String, dynamic> item) {
    final state = getTableState(tableId);
    developer.log(
      'TRY ADD → table:$tableId id:${item['id']} name:${item['item_name']} qty:${item['quantity']} price:${item['price']}',
      name: 'ORDER_ADD',
    );
    if (item['id'] == null || item['id'] <= 0) {
      developer.log('❌ Invalid ID: ${item['id']}', name: 'ORDER_ADD');
      return;
    }
    if (item['quantity'] == null || item['quantity'] <= 0) {
      developer.log('❌ Invalid Quantity: ${item['quantity']}',
          name: 'ORDER_ADD');
      return;
    }
    state.orderItems.add(item);
    _updateTotal(state);
    developer.log('✅ ADDED → table:$tableId items:${state.orderItems.length}',
        name: 'ORDER_ADD');
    _logTableSnapshot(tableId, state);
  }

  void incrementItemQuantity(int tableId, int index) {
    final state = getTableState(tableId);
    if (index < 0 || index >= state.orderItems.length) {
      developer.log('❌ Invalid index $index', name: 'ORDER_INC');
      return;
    }
    final item = state.orderItems[index];
    final newQty = (item['quantity'] as int) + 1;
    developer.log(
      'INC → table:$tableId index:$index id:${item['id']} name:${item['item_name']} from:${item['quantity']} to:$newQty',
      name: 'ORDER_INC',
    );
    _updateItemQuantity(state, index, newQty);
    _logTableSnapshot(tableId, state);
  }

  void decrementItemQuantity(int tableId, int index, BuildContext context) {
    final state = getTableState(tableId);
    if (index < 0 || index >= state.orderItems.length) {
      developer.log('❌ Invalid index $index', name: 'ORDER_DEC');
      return;
    }
    final item = state.orderItems[index];
    final currentQty = item['quantity'] as int;
    final frozenQty = state.getFrozenQuantity(item['id'].toString());

    developer.log(
      'DEC REQ → table:$tableId index:$index id:${item['id']} name:${item['item_name']} curr:$currentQty frozen:$frozenQty',
      name: 'ORDER_DEC',
    );

    if (frozenQty == 0) {
      if (currentQty > 1) {
        _updateItemQuantity(state, index, currentQty - 1);
        developer.log('DEC OK → new:${currentQty - 1}', name: 'ORDER_DEC');
      } else {
        _removeItem(state, index, context, fromDecrement: true);
        developer.log(
            'REMOVED (qty→0) id:${item['id']} name:${item['item_name']}',
            name: 'ORDER_DEC');
      }
    } else {
      if (currentQty > frozenQty) {
        _updateItemQuantity(state, index, currentQty - 1);
        developer.log('DEC OK (>= frozen) new:${currentQty - 1}',
            name: 'ORDER_DEC');
      } else {
        developer.log('BLOCKED: cannot go below frozen ($frozenQty)',
            name: 'ORDER_DEC');
        SnackBarUtil.showWarning(
          context,
          'Cannot reduce below sent quantity ($frozenQty)',
          title: 'Item Already Sent',
          duration: const Duration(seconds: 2),
        );
      }
    }
    _logTableSnapshot(tableId, state);
  }

  void removeItemFromTable(int tableId, int index, BuildContext context) {
    final state = getTableState(tableId);
    if (index < 0 || index >= state.orderItems.length) {
      developer.log('❌ Invalid index $index', name: 'REMOVE_ITEM');
      return;
    }
    final item = state.orderItems[index];
    final frozenQty = state.getFrozenQuantity(item['id'].toString());
    if (frozenQty > 0) {
      developer.log(
          'BLOCKED REMOVE → id:${item['id']} name:${item['item_name']} frozen:$frozenQty',
          name: 'REMOVE_ITEM');
      SnackBarUtil.showWarning(
        context,
        'Cannot remove - $frozenQty already sent to kitchen',
        title: 'Item Already Sent',
        duration: const Duration(seconds: 2),
      );
      return;
    }
    _removeItem(state, index, context);
    developer.log(
        'REMOVED → table:$tableId id:${item['id']} name:${item['item_name']}',
        name: 'REMOVE_ITEM');
    _logTableSnapshot(tableId, state);
  }

  void _removeItem(TableOrderState state, int index, BuildContext context,
      {bool fromDecrement = false}) {
    final removedItem = state.orderItems.removeAt(index);
    _updateTotal(state);
    SnackBarUtil.showInfo(
      context,
      '${removedItem['item_name']} removed from order',
      title: 'Item Removed',
      duration: const Duration(seconds: 1),
    );
  }

  void _updateItemQuantity(TableOrderState state, int index, int quantity) {
    final item = state.orderItems[index];
    final price = item['price'] as double;
    item['quantity'] = quantity;
    item['total_price'] = price * quantity;
    state.orderItems[index] = item;
    developer.log(
      'QTY UPDATE → id:${item['id']} name:${item['item_name']} qty:$quantity total:${item['total_price']}',
      name: 'UPDATE_QTY',
    );
    _updateTotal(state);
  }

  void _updateTotal(TableOrderState state) {
    final newTotal = state.orderItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['total_price'] as double),
    );
    state.finalCheckoutTotal.value = newTotal;
    developer.log('TOTAL UPDATE → table:${state.tableId} total:₹$newTotal',
        name: 'UPDATE_TOTAL');
  }

  // void toggleUrgentForTable(int tableId, BuildContext context, TableInfo? tableInfo) {
  //   final state = getTableState(tableId);
  //   state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
  //   developer.log('Urgent status changed: ${state.isMarkAsUrgent.value}', name: 'URGENT');
  //   final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
  //   SnackBarUtil.show(
  //     context,
  //     state.isMarkAsUrgent.value
  //         ? 'Table $tableNumber marked as urgent'
  //         : 'Table $tableNumber removed from urgent',
  //     title: state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
  //     type: state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
  //     duration: const Duration(seconds: 1),
  //   );
  // }

  // void navigateToAddItems(int tableId, TableInfo? tableInfo) {
  //   try {
  //     NavigationService.addItems(tableInfoToMap(tableInfo));
  //   } catch (e) {
  //     developer.log('Navigation error: $e');
  //     SnackBarUtil.showError(
  //       Get.context!,
  //       'Unable to proceed',
  //       title: 'Navigation Error',
  //       duration: const Duration(seconds: 1),
  //     );
  //   }
  // }

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

  // Helper for logging a full snapshot of orderItems + frozen quantities + total
  void _logTableSnapshot(int tableId, TableOrderState state) {
    final buffer = StringBuffer();
    buffer.writeln('TABLE SNAPSHOT → table:$tableId');
    for (var i = 0; i < state.orderItems.length; i++) {
      final it = state.orderItems[i];
      final frozen = state.getFrozenQuantity(it['id'].toString());
      buffer.writeln(
        '[$i] id:${it['id']} name:${it['item_name']} qty:${it['quantity']} frozen:$frozen total:${it['total_price']}',
      );
    }
    buffer.writeln('FINAL TOTAL: ${state.finalCheckoutTotal.value}');
    developer.log(buffer.toString(), name: 'ORDER_STATE');
  }

  // Add this helper method to convert Map back to TableInfo
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
      developer.log('Error converting map to TableInfo: $e',
          name: 'MAP_CONVERSION');
      return null;
    }
  }

// Update the methods that receive tableInfo as dynamic/Object
  Future<void> sendToChef(
    int tableId,
    BuildContext context,
    dynamic tableInfoData, // Change from TableInfo? to dynamic
    List<Map<String, dynamic>> orderItems,
  ) async {
    // Convert if it's a Map
    final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
        ? mapToTableInfo(tableInfoData)
        : tableInfoData as TableInfo?;

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

  Future<void> proceedToCheckout(
    int tableId,
    BuildContext context,
    dynamic tableInfoData, // Change from TableInfo? to dynamic
    List<Map<String, dynamic>> orderItems,
  ) async {
    // Convert if it's a Map
    final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
        ? mapToTableInfo(tableInfoData)
        : tableInfoData as TableInfo?;

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

  void toggleUrgentForTable(
    int tableId,
    BuildContext context,
    dynamic tableInfoData, // Change from TableInfo? to dynamic
  ) {
    // Convert if it's a Map
    final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
        ? mapToTableInfo(tableInfoData)
        : tableInfoData as TableInfo?;

    final state = getTableState(tableId);
    state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
    developer.log('Urgent status changed: ${state.isMarkAsUrgent.value}',
        name: 'URGENT');
    final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
    SnackBarUtil.show(
      context,
      state.isMarkAsUrgent.value
          ? 'Table $tableNumber marked as urgent'
          : 'Table $tableNumber removed from urgent',
      title:
          state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
      type:
          state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
      duration: const Duration(seconds: 1),
    );
  }

  void navigateToAddItems(int tableId, dynamic tableInfoData) {
    try {
      // If it's already a TableInfo, convert to Map
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
        duration: const Duration(seconds: 1),
      );
    }
  }

  void setActiveTable(int tableId, dynamic tableInfoData) {
    // Convert if it's a Map
    final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
        ? mapToTableInfo(tableInfoData)
        : tableInfoData as TableInfo?;

    activeTableId.value = tableId;
    final state = getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;
    if (orderId > 0 && !state.hasLoadedOrder.value) {
      developer.log("Loading existing order $orderId for table $tableId",
          name: "ACTIVE_TABLE");
      fetchExistingOrder(orderId, tableId);
    }
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

      // Validate customer details
      if (state.fullNameController.text.trim().isEmpty) {
        SnackBarUtil.showError(
          context,
          'Please enter customer name',
          title: 'Validation Error',
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
        return;
      }

      if (state.phoneController.text.trim().isEmpty) {
        SnackBarUtil.showError(
          context,
          'Please enter customer phone',
          title: 'Validation Error',
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
        return;
      }

      // Get new items only (not frozen ones)
      final newItems = _getNewItems(state, orderItems);

      if (newItems.isEmpty) {
        SnackBarUtil.showWarning(
          context,
          'No new items to send. All items already sent to kitchen',
          title: 'Warning',
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
        return;
      }

      // Build request body
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

      developer.log(
        'Sending order request: ${request.toJson()}',
        name: 'ORDER_API',
      );

      // Make API call
      final response = await ApiService.post<OrderResponseModel>(
        endpoint: ApiConstants.waiterPostCreateOrder,
        body: request.toJson(),
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (response.success && response.data != null) {
        // Freeze the items after successful API call
        _freezeItems(state, orderItems);

        final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();

        SnackBarUtil.showSuccess(
          context,
          '$successMessage for Table $tableNumber',
          title: 'Success',
          duration: const Duration(seconds: 2),
        );

        developer.log(
          'Order sent successfully. Order ID: ${response.data?.data.order.id}',
          name: 'ORDER_API',
        );

        // Navigate back on success
        NavigationService.goBack();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to process order');
      }
    } catch (e) {
      developer.log('Order processing error: $e', name: 'ORDER_API');
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
}

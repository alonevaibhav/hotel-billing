//
// import 'dart:developer' as Developer;
// import 'package:flutter/material.dart' hide Table;
// import 'package:get/get.dart';
// import 'package:hotelbilling/app/modules/controllers/WaiterPanelController/take_order_controller.dart';
// import 'dart:developer' as developer;
// import '../../../core/constants/api_constant.dart';
// import '../../../core/services/api_service.dart';
// import '../../../core/utils/snakbar_utils.dart';
// import '../../../data/models/RequestModel/create_order_request.dart';
// import '../../../data/models/ResponseModel/order_model.dart' hide OrderData;
// import '../../../data/models/ResponseModel/table_model.dart';
// import '../../../route/app_routes.dart';
// import '../../model/froze_model.dart';
//
//
// class TableOrderState {
//   final int tableId;
//   final orderItems = <Map<String, dynamic>>[].obs;
//   final frozenItems = <FrozenItem>[].obs;
//   final isMarkAsUrgent = false.obs;
//   final finalCheckoutTotal = 0.0.obs;
//   final isLoadingOrder = false.obs;
//   final hasLoadedOrder = false.obs;
//   final placedOrderId = Rxn<int>(); // Store the placed order ID
//   final fullNameController = TextEditingController();
//   final phoneController = TextEditingController();
//
//   TableOrderState({required this.tableId});
//
//   void dispose() {
//     fullNameController.dispose();
//     phoneController.dispose();
//   }
//   int? lastFetchedOrderId;
//
//
//   void clear() {
//     fullNameController.clear();
//     phoneController.clear();
//     orderItems.clear();
//     frozenItems.clear();
//     finalCheckoutTotal.value = 0.0;
//     isMarkAsUrgent.value = false;
//     hasLoadedOrder.value = false;
//     placedOrderId.value = null;
//     lastFetchedOrderId = null; // Reset this too
//
//   }
//
//   int getFrozenQuantity(String itemId) {
//     return frozenItems.firstWhereOrNull((item) => item.id == itemId)?.quantity ?? 0;
//   }
//   bool get hasFrozenItems => frozenItems.isNotEmpty;
//   // Check if this is a reorder scenario (order already exists)
//   bool get isReorderScenario => placedOrderId.value != null && placedOrderId.value! > 0;
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
//
//
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
//   TableOrderState getTableState(int tableId) {
//     final state = tableOrders.putIfAbsent(
//       tableId, () => TableOrderState(tableId: tableId),
//     );
//     developer.log("Table loaded ($tableId). Items: ${state.orderItems.length}",
//         name: "TABLE_STATE");
//     return state;
//   }
//
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
//   void addItemToTable(int tableId, Map<String, dynamic> item) {
//     final state = getTableState(tableId);
//     developer.log(
//       'TRY ADD → table:$tableId id:${item['id']} name:${item['item_name']} qty:${item['quantity']} price:${item['price']}',
//       name: 'ORDER_ADD',
//     );
//     if (item['id'] == null || item['id'] <= 0) {
//       developer.log('❌ Invalid ID: ${item['id']}', name: 'ORDER_ADD');
//       return;
//     }
//     if (item['quantity'] == null || item['quantity'] <= 0) {
//       developer.log('❌ Invalid Quantity: ${item['quantity']}',
//           name: 'ORDER_ADD');
//       return;
//     }
//     state.orderItems.add(item);
//     _updateTotal(state);
//     developer.log('✅ ADDED → table:$tableId items:${state.orderItems.length}',
//         name: 'ORDER_ADD');
//     _logTableSnapshot(tableId, state);
//   }
//
//   void incrementItemQuantity(int tableId, int index) {
//     final state = getTableState(tableId);
//     if (index < 0 || index >= state.orderItems.length) {
//       developer.log('❌ Invalid index $index', name: 'ORDER_INC');
//       return;
//     }
//     final item = state.orderItems[index];
//     final newQty = (item['quantity'] as int) + 1;
//     developer.log(
//       'INC → table:$tableId index:$index id:${item['id']} name:${item['item_name']} from:${item['quantity']} to:$newQty',
//       name: 'ORDER_INC',
//     );
//     _updateItemQuantity(state, index, newQty);
//     _logTableSnapshot(tableId, state);
//   }
//
//   void decrementItemQuantity(int tableId, int index, BuildContext context) {
//     final state = getTableState(tableId);
//     if (index < 0 || index >= state.orderItems.length) {
//       developer.log('❌ Invalid index $index', name: 'ORDER_DEC');
//       return;
//     }
//     final item = state.orderItems[index];
//     final currentQty = item['quantity'] as int;
//     final frozenQty = state.getFrozenQuantity(item['id'].toString());
//
//     developer.log(
//       'DEC REQ → table:$tableId index:$index id:${item['id']} name:${item['item_name']} curr:$currentQty frozen:$frozenQty',
//       name: 'ORDER_DEC',
//     );
//
//     if (frozenQty == 0) {
//       if (currentQty > 1) {
//         _updateItemQuantity(state, index, currentQty - 1);
//         developer.log('DEC OK → new:${currentQty - 1}', name: 'ORDER_DEC');
//       } else {
//         _removeItem(state, index, context, fromDecrement: true);
//         developer.log(
//             'REMOVED (qty→0) id:${item['id']} name:${item['item_name']}',
//             name: 'ORDER_DEC');
//       }
//     } else {
//       if (currentQty > frozenQty) {
//         _updateItemQuantity(state, index, currentQty - 1);
//         developer.log('DEC OK (>= frozen) new:${currentQty - 1}',
//             name: 'ORDER_DEC');
//       } else {
//         developer.log('BLOCKED: cannot go below frozen ($frozenQty)',
//             name: 'ORDER_DEC');
//         SnackBarUtil.showWarning(
//           context,
//           'Cannot reduce below sent quantity ($frozenQty)',
//           title: 'Item Already Sent',
//           duration: const Duration(seconds: 2),
//         );
//       }
//     }
//     _logTableSnapshot(tableId, state);
//   }
//
//   void removeItemFromTable(int tableId, int index, BuildContext context) {
//     final state = getTableState(tableId);
//     if (index < 0 || index >= state.orderItems.length) {
//       developer.log('❌ Invalid index $index', name: 'REMOVE_ITEM');
//       return;
//     }
//     final item = state.orderItems[index];
//     final frozenQty = state.getFrozenQuantity(item['id'].toString());
//     if (frozenQty > 0) {
//       developer.log(
//           'BLOCKED REMOVE → id:${item['id']} name:${item['item_name']} frozen:$frozenQty',
//           name: 'REMOVE_ITEM');
//       SnackBarUtil.showWarning(
//         context,
//         'Cannot remove - $frozenQty already sent to kitchen',
//         title: 'Item Already Sent',
//         duration: const Duration(seconds: 2),
//       );
//       return;
//     }
//     _removeItem(state, index, context);
//     developer.log(
//         'REMOVED → table:$tableId id:${item['id']} name:${item['item_name']}',
//         name: 'REMOVE_ITEM');
//     _logTableSnapshot(tableId, state);
//   }
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
//   void _updateItemQuantity(TableOrderState state, int index, int quantity) {
//     final item = state.orderItems[index];
//     final price = item['price'] as double;
//     item['quantity'] = quantity;
//     item['total_price'] = price * quantity;
//     state.orderItems[index] = item;
//     developer.log(
//       'QTY UPDATE → id:${item['id']} name:${item['item_name']} qty:$quantity total:${item['total_price']}',
//       name: 'UPDATE_QTY',
//     );
//     _updateTotal(state);
//   }
//
//   void _updateTotal(TableOrderState state) {
//     final newTotal = state.orderItems.fold<double>(
//       0.0,
//           (sum, item) => sum + (item['total_price'] as double),
//     );
//     state.finalCheckoutTotal.value = newTotal;
//     developer.log('TOTAL UPDATE → table:${state.tableId} total:₹$newTotal',
//         name: 'UPDATE_TOTAL');
//   }
//
//
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
//   void _logTableSnapshot(int tableId, TableOrderState state) {
//     final buffer = StringBuffer();
//     buffer.writeln('TABLE SNAPSHOT → table:$tableId');
//     for (var i = 0; i < state.orderItems.length; i++) {
//       final it = state.orderItems[i];
//       final frozen = state.getFrozenQuantity(it['id'].toString());
//       buffer.writeln(
//         '[$i] id:${it['id']} name:${it['item_name']} qty:${it['quantity']} frozen:$frozen total:${it['total_price']}',
//       );
//     }
//     buffer.writeln('FINAL TOTAL: ${state.finalCheckoutTotal.value}');
//     developer.log(buffer.toString(), name: 'ORDER_STATE');
//   }
//
//   TableInfo? mapToTableInfo(Map<String, dynamic>? map) {
//     if (map == null) return null;
//
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
//
//
//   Future<void> proceedToCheckout(
//       int tableId,
//       BuildContext context,
//       dynamic tableInfoData,
//       List<Map<String, dynamic>> orderItems,
//       ) async {
//     final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
//         ? mapToTableInfo(tableInfoData)
//         : tableInfoData as TableInfo?;
//
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
//   void toggleUrgentForTable(
//       int tableId,
//       BuildContext context,
//       dynamic tableInfoData,
//       ) {
//     final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
//         ? mapToTableInfo(tableInfoData)
//         : tableInfoData as TableInfo?;
//
//     final state = getTableState(tableId);
//     state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
//     developer.log('Urgent status changed: ${state.isMarkAsUrgent.value}',
//         name: 'URGENT');
//     final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//     SnackBarUtil.show(
//       context,
//       state.isMarkAsUrgent.value
//           ? 'Table $tableNumber marked as urgent'
//           : 'Table $tableNumber removed from urgent',
//       title:
//       state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
//       type:
//       state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
//       duration: const Duration(seconds: 1),
//     );
//   }
//
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
//         duration: const Duration(seconds: 1),
//       );
//     }
//   }
//
//   void resetTableStateIfNeeded(int tableId, TableInfo? tableInfo) {
//     final state = getTableState(tableId);
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//     final status = tableInfo?.table.status ?? 'unknown';
//
//     // Only reset if table is available and has no order
//     if (orderId <= 0 && status.toLowerCase() == 'available' && state.hasLoadedOrder.value) {
//       developer.log(
//           "Resetting state for available table $tableId",
//           name: "RESET_STATE"
//       );
//       state.clear();
//       state.hasLoadedOrder.value = false;
//     }
//   }
//
//   void setActiveTable(int tableId, dynamic tableInfoData) {
//     final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
//         ? mapToTableInfo(tableInfoData)
//         : tableInfoData as TableInfo?;
//
//     activeTableId.value = tableId;
//     final state = getTableState(tableId);
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//     if (orderId > 0 && !state.hasLoadedOrder.value) {
//       developer.log("Loading existing order $orderId for table $tableId",
//           name: "ACTIVE_TABLE");
//       fetchOrder(orderId, tableId);
//     }
//   }
//
//   // NEW: Add items to existing order (Reorder API)
//   Future<void> _addItemsToExistingOrder({
//     required int placedOrderId,
//     required int tableId,
//     required BuildContext context,
//     required TableInfo? tableInfo,
//     required List<Map<String, dynamic>> newItems,
//   }) async {
//     try {
//       // Build reorder request body
//       final requestBody = {
//         "items": newItems.map((item) {
//           final reorderItem = {
//             "menu_item_id": item['id'] as int,
//             "quantity": item['quantity'] as int,
//           };
//
//           // Add special_instructions only if it exists and is not empty
//           if (item['special_instructions'] != null &&
//               item['special_instructions'].toString().trim().isNotEmpty) {
//             reorderItem['special_instructions'] = item['special_instructions'] as int;
//           }
//
//           return reorderItem;
//         }).toList(),
//       };
//
//       developer.log(
//         'Reorder request for Order ID $placedOrderId: $requestBody',
//         name: 'REORDER_API',
//       );
//
//       // Make API call to add items to existing order
//       final response = await ApiService.post<OrderResponseModel>(
//         endpoint: ApiConstants.waiterPostReorder(placedOrderId),
//         body: requestBody,
//         fromJson: (json) => OrderResponseModel.fromJson(json),
//         includeToken: true,
//       );
//
//       if (response.success && response.data != null) {
//         final state = getTableState(tableId);
//
//         // Freeze the newly added items
//         _freezeItems(state, state.orderItems);
//
//         final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//
//         SnackBarUtil.showSuccess(
//           context,
//           'Items added to existing order for Table $tableNumber',
//           title: 'Success',
//           duration: const Duration(seconds: 2),
//         );
//
//         developer.log(
//           'Items added successfully to Order ID: $placedOrderId',
//           name: 'REORDER_API',
//         );
//
//         // Refresh tables
//         final controller = Get.find<TakeOrdersController>();
//         controller.refreshTables();
//
//         // Navigate back
//         NavigationService.goBack();
//       } else {
//         throw Exception(response.errorMessage ?? 'Failed to add items to order');
//       }
//     } catch (e) {
//       developer.log('Reorder error: $e', name: 'REORDER_API');
//       SnackBarUtil.showError(
//         context,
//         'Failed to add items to existing order',
//         title: 'Error',
//         duration: const Duration(seconds: 2),
//       );
//       rethrow;
//     }
//   }
//
//
//   Future<void> fetchOrder(int orderId, int tableId) async {
//     final state = getTableState(tableId);
//
//     if (state.hasLoadedOrder.value || orderId <= 0) {
//       state.hasLoadedOrder.value = false;
//       return;
//     }
//
//     try {
//       developer.log(
//         'isLoadingOrder: ${state.isLoadingOrder.value}',
//         name: 'FETCH_ORDER',
//       );
//       state.isLoadingOrder.value = true;
//       final response = await ApiService.get<OrderResponseModel>(
//         endpoint: ApiConstants.waiterGetTableOrder(orderId),
//         fromJson: (json) => OrderResponseModel.fromJson(json),
//         includeToken: true,
//       );
//       if (response.success && response.data != null) {
//         final orderData = response.data!;
//
//         // Store the placed order ID for reorder scenario
//         state.placedOrderId.value = orderData.data.order.id;
//
//         state.fullNameController.text = orderData.data.order.customerName ?? '';
//         state.phoneController.text = orderData.data.order.customerPhone ?? '';
//         state.orderItems.clear();
//         state.frozenItems.clear();
//         for (var apiItem in orderData.data.items) {
//           final localItem = apiItem.toLocalOrderItem();
//           state.orderItems.add(localItem);
//           state.frozenItems.add(FrozenItem(
//             id: apiItem.menuItemId.toString(),
//             name: apiItem.itemName,
//             quantity: apiItem.quantity,
//           ));
//         }
//         _updateTotal(state);
//         developer.log(
//             'Loaded ${orderData.data.items.length} items for table $tableId. Order ID: ${state.placedOrderId.value}',
//             name: 'FETCH_ORDER');
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
//
//   // UPDATED: Unified order processing with reorder logic
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
//
//       // Get new items only (not frozen ones)
//       final newItems = _getNewItems(state, orderItems);
//
//       if (newItems.isEmpty) {
//         SnackBarUtil.showWarning(
//           context,
//           'No new items to send. All items already sent to kitchen',
//           title: 'Warning',
//           duration: const Duration(seconds: 2),
//         );
//         isLoading.value = false;
//         return;
//       }
//
//       // DECISION: Check if this is a reorder scenario
//       if (state.isReorderScenario) {
//         // Use reorder API for existing orders
//         developer.log(
//           'Reorder scenario detected. Using reorder API for Order ID: ${state.placedOrderId.value}',
//           name: 'ORDER_ROUTING',
//         );
//
//         await _addItemsToExistingOrder(
//           placedOrderId: state.placedOrderId.value!,
//           tableId: tableId,
//           context: context,
//           tableInfo: tableInfo,
//           newItems: newItems,
//         );
//       } else {
//         // Use create order API for new orders
//         developer.log(
//           'New order scenario detected. Using create order API',
//           name: 'ORDER_ROUTING',
//         );
//
//         final request = CreateOrderRequest(
//           orderData: OrderData(
//             hotelTableId: tableInfo?.table.id ?? tableId,
//             customerName: state.fullNameController.text.trim(),
//             customerPhone: state.phoneController.text.trim(),
//             tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
//             status: 'pending',
//           ),
//           items: newItems
//               .map((item) => OrderItemRequest(
//             menuItemId: item['id'] as int,
//             quantity: item['quantity'] as int,
//             specialInstructions: item['special_instructions'] as String?,
//           ))
//               .toList(),
//         );
//
//         developer.log(
//           'Create order request: ${request.toJson()}',
//           name: 'ORDER_API',
//         );
//
//         final response = await ApiService.post<OrderResponseModel>(
//           endpoint: ApiConstants.waiterPostCreateOrder,
//           body: request.toJson(),
//           fromJson: (json) => OrderResponseModel.fromJson(json),
//           includeToken: true,
//         );
//
//         if (response.success && response.data != null) {
//           // Store the placed order ID for future reorders
//           state.placedOrderId.value = response.data!.data.order.id;
//
//           // Freeze the items after successful API call
//           _freezeItems(state, orderItems);
//
//           final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//
//           SnackBarUtil.showSuccess(
//             context,
//             '$successMessage for Table $tableNumber',
//             title: 'Success',
//             duration: const Duration(seconds: 2),
//           );
//
//           developer.log(
//             'Order created successfully. Order ID: ${state.placedOrderId.value}',
//             name: 'ORDER_API',
//           );
//
//           final controller = Get.find<TakeOrdersController>();
//           controller.refreshTables();
//
//           NavigationService.goBack();
//         } else {
//           throw Exception(response.errorMessage ?? 'Failed to process order');
//         }
//       }
//     } catch (e) {
//       developer.log('Order processing error: $e', name: 'ORDER_API');
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
// }

import 'dart:developer' as Developer;
import 'package:flutter/material.dart' hide Table;
import 'package:get/get.dart';
import 'package:hotelbilling/app/modules/controllers/WaiterPanelController/take_order_controller.dart';
import 'dart:developer' as developer;
import '../../../core/constants/api_constant.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/RequestModel/create_order_request.dart';
import '../../../data/models/ResponseModel/order_model.dart' hide OrderData;
import '../../../data/models/ResponseModel/table_model.dart';
import '../../../route/app_routes.dart';
import '../../model/froze_model.dart';

class TableOrderState {
  final int tableId;
  final orderItems = <Map<String, dynamic>>[].obs;
  final frozenItems = <FrozenItem>[].obs;
  final isMarkAsUrgent = false.obs;
  final finalCheckoutTotal = 0.0.obs;
  final isLoadingOrder = false.obs;
  final hasLoadedOrder = false.obs;
  final placedOrderId = Rxn<int>();
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
    placedOrderId.value = null;
  }

  int getFrozenQuantity(String itemId) {
    return frozenItems.firstWhereOrNull((item) => item.id == itemId)?.quantity ?? 0;
  }

  bool get hasFrozenItems => frozenItems.isNotEmpty;
  bool get isReorderScenario => placedOrderId.value != null && placedOrderId.value! > 0;
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
      tableId, () => TableOrderState(tableId: tableId),
    );
    developer.log("Table loaded ($tableId). Items: ${state.orderItems.length}",
        name: "TABLE_STATE");
    return state;
  }

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

  Future<void> proceedToCheckout(
      int tableId,
      BuildContext context,
      dynamic tableInfoData,
      List<Map<String, dynamic>> orderItems,
      ) async {
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
      dynamic tableInfoData,
      ) {
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
      type: state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
      duration: const Duration(seconds: 1),
    );
  }

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
        duration: const Duration(seconds: 1),
      );
    }
  }

  void resetTableStateIfNeeded(int tableId, TableInfo? tableInfo) {
    final state = getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;
    final status = tableInfo?.table.status ?? 'unknown';

    // Only reset if table is available and has no order
    if (orderId <= 0 && status.toLowerCase() == 'available' && state.hasLoadedOrder.value) {
      developer.log(
          "Resetting state for available table $tableId",
          name: "RESET_STATE"
      );
      state.clear();
      state.hasLoadedOrder.value = false;
    }
  }

  // ===== CRITICAL FIX: This method runs when waiter comes back to page =====
  void setActiveTable(int tableId, dynamic tableInfoData) {
    final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
        ? mapToTableInfo(tableInfoData)
        : tableInfoData as TableInfo?;

    activeTableId.value = tableId;
    final state = getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;

    developer.log(
      'SET ACTIVE TABLE → tableId:$tableId, orderId:$orderId, hasLoadedOrder:${state.hasLoadedOrder.value}, placedOrderId:${state.placedOrderId.value}',
      name: 'ACTIVE_TABLE',
    );

    // FIX: Check all conditions to decide if we should fetch
    // 1. Order exists in backend (orderId > 0)
    // 2. We haven't loaded it yet (hasLoadedOrder == false)
    if (orderId > 0 && !state.hasLoadedOrder.value) {
      developer.log(
        'TRIGGER FETCH → orderId:$orderId for table $tableId',
        name: 'ACTIVE_TABLE',
      );
      fetchOrder(orderId, tableId);
    } else if (orderId <= 0 && state.placedOrderId.value != null && state.placedOrderId.value! > 0 && !state.hasLoadedOrder.value) {
      // Fallback: If tableInfo doesn't have orderId but we have it stored locally
      developer.log(
        'TRIGGER FETCH (FALLBACK) → using stored placedOrderId:${state.placedOrderId.value}',
        name: 'ACTIVE_TABLE',
      );
      fetchOrder(state.placedOrderId.value!, tableId);
    } else {
      developer.log(
        'SKIP FETCH → orderId:$orderId, hasLoadedOrder:${state.hasLoadedOrder.value}, placedOrderId:${state.placedOrderId.value}',
        name: 'ACTIVE_TABLE',
      );
    }
  }

  // NEW: Add items to existing order (Reorder API)
  Future<void> _addItemsToExistingOrder({
    required int placedOrderId,
    required int tableId,
    required BuildContext context,
    required TableInfo? tableInfo,
    required List<Map<String, dynamic>> newItems,
  }) async {
    try {
      // Build reorder request body
      final requestBody = {
        "items": newItems.map((item) {
          final reorderItem = {
            "menu_item_id": item['id'] as int,
            "quantity": item['quantity'] as int,
          };

          // Add special_instructions only if it exists and is not empty
          if (item['special_instructions'] != null &&
              item['special_instructions'].toString().trim().isNotEmpty) {
            reorderItem['special_instructions'] = item['special_instructions'] as int;
          }

          return reorderItem;
        }).toList(),
      };

      developer.log(
        'Reorder request for Order ID $placedOrderId: $requestBody',
        name: 'REORDER_API',
      );

      // Make API call to add items to existing order
      final response = await ApiService.post<OrderResponseModel>(
        endpoint: ApiConstants.waiterPostReorder(placedOrderId),
        body: requestBody,
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (response.success && response.data != null) {
        final state = getTableState(tableId);

        // Freeze the newly added items
        _freezeItems(state, state.orderItems);

        final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();

        SnackBarUtil.showSuccess(
          context,
          'Items added to existing order for Table $tableNumber',
          title: 'Success',
          duration: const Duration(seconds: 2),
        );

        developer.log(
          'Items added successfully to Order ID: $placedOrderId',
          name: 'REORDER_API',
        );

        // Refresh tables
        final controller = Get.find<TakeOrdersController>();
        controller.refreshTables();

        // Navigate back
        NavigationService.goBack();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to add items to order');
      }
    } catch (e) {
      developer.log('Reorder error: $e', name: 'REORDER_API');
      SnackBarUtil.showError(
        context,
        'Failed to add items to existing order',
        title: 'Error',
        duration: const Duration(seconds: 2),
      );
      rethrow;
    }
  }

  // 2. Update fetchOrder method - SIMPLE VERSION
  Future<void> fetchOrder(int orderId, int tableId) async {
    final state = getTableState(tableId);

    // Skip if already loading or invalid order ID
    if (state.isLoadingOrder.value || orderId <= 0) {
      developer.log(
        'FETCH SKIPPED → isLoading:${state.isLoadingOrder.value}, orderId:$orderId',
        name: 'FETCH_ORDER',
      );
      return;
    }

    // Skip if already loaded (prevents duplicate API calls)
    if (state.hasLoadedOrder.value) {
      developer.log(
        'FETCH SKIPPED → Already loaded for table $tableId',
        name: 'FETCH_ORDER',
      );
      return;
    }

    try {
      developer.log(
        'FETCH ORDER START → orderId:$orderId, tableId:$tableId',
        name: 'FETCH_ORDER',
      );
      state.isLoadingOrder.value = true;

      final response = await ApiService.get<OrderResponseModel>(
        endpoint: ApiConstants.waiterGetTableOrder(orderId),
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (response.success && response.data != null) {
        final orderData = response.data!;

        // Store the placed order ID
        state.placedOrderId.value = orderData.data.order.id;

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
          'FETCH SUCCESS → Loaded ${orderData.data.items.length} items for table $tableId',
          name: 'FETCH_ORDER',
        );
      } else {
        throw Exception(response.errorMessage ?? 'Failed to fetch order');
      }
    } catch (e) {
      developer.log('FETCH ERROR → $e', name: 'FETCH_ORDER');
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

  // 4. After successful order creation, refresh properly
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

      if (state.isReorderScenario) {
        await _addItemsToExistingOrder(
          placedOrderId: state.placedOrderId.value!,
          tableId: tableId,
          context: context,
          tableInfo: tableInfo,
          newItems: newItems,
        );
      } else {
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

        final response = await ApiService.post<OrderResponseModel>(
          endpoint: ApiConstants.waiterPostCreateOrder,
          body: request.toJson(),
          fromJson: (json) => OrderResponseModel.fromJson(json),
          includeToken: true,
        );

        if (response.success && response.data != null) {
          final createdOrderId = response.data!.data.order.id;

          // ===== CRITICAL FIX: Store order ID BEFORE freezing =====
          state.placedOrderId.value = createdOrderId;
          developer.log(
            'Order created successfully. Order ID: $createdOrderId stored in state',
            name: 'ORDER_API',
          );

          // Now freeze items
          _freezeItems(state, orderItems);

          final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();

          SnackBarUtil.showSuccess(
            context,
            '$successMessage for Table $tableNumber',
            title: 'Success',
            duration: const Duration(seconds: 2),
          );

          // ===== CRITICAL FIX: Reset hasLoadedOrder so fetchOrder can trigger on return =====
          state.hasLoadedOrder.value = false;
          developer.log(
            'hasLoadedOrder reset to false - fetchOrder will trigger when waiter returns',
            name: 'ORDER_API',
          );

          final controller = Get.find<TakeOrdersController>();
          controller.refreshTables();

          NavigationService.goBack();
        } else {
          throw Exception(response.errorMessage ?? 'Failed to process order');
        }
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
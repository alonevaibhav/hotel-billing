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
// class TableOrderState {
//   final int tableId;
//   final orderItems = <Map<String, dynamic>>[].obs;
//   final frozenItems = <FrozenItem>[].obs;
//   final isMarkAsUrgent = false.obs;
//   final finalCheckoutTotal = 0.0.obs;
//   final isLoadingOrder = false.obs;
//   final hasLoadedOrder = false.obs;
//   final placedOrderId = Rxn<int>();
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
//     placedOrderId.value = null;
//   }
//
//   int getFrozenQuantity(String itemId) {
//     return frozenItems
//         .firstWhereOrNull((item) => item.id == itemId)
//         ?.quantity ??
//         0;
//   }
//
//   bool get hasFrozenItems => frozenItems.isNotEmpty;
//   bool get isReorderScenario =>
//       placedOrderId.value != null && placedOrderId.value! > 0;
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
//       tableId,
//           () => TableOrderState(tableId: tableId),
//     );
//     developer.log("Table loaded ($tableId). Items: ${state.orderItems.length}",
//         name: "TABLE_STATE");
//     return state;
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
//   void freezeItems(TableOrderState state, List<Map<String, dynamic>> items) {
//     for (var item in items) {
//       final itemId = item['id'].toString();
//       final quantity = item['quantity'] as int;
//
//       final existingIndex =
//       state.frozenItems.indexWhere((f) => f.id == itemId);
//
//       if (existingIndex >= 0) {
//         // increase frozen quantity
//         final existing = state.frozenItems[existingIndex];
//         state.frozenItems[existingIndex] = FrozenItem(
//           id: existing.id,
//           name: existing.name,
//           quantity: existing.quantity + quantity,
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
//
//   void addItemToTable(int tableId, Map<String, dynamic> item) {
//     final state = getTableState(tableId);
//
//     final int id = item['id'] as int;
//     final int qty = item['quantity'] as int;
//     final double price = item['price'] as double;
//
//     // Check existing row for same menu item
//     final index = state.orderItems.indexWhere((e) => e['id'] == id);
//
//     if (index >= 0) {
//       // ✅ MERGE: Item already exists
//       final existing = state.orderItems[index];
//       final int oldQty = existing['quantity'] as int;
//       final int newQty = oldQty + qty;
//
//       existing['quantity'] = newQty;
//       existing['total_price'] = price * newQty;
//       state.orderItems[index] = existing;
//
//       developer.log(
//         '✅ MERGED: ${item['item_name']} - Old: $oldQty, Added: $qty, New Total: $newQty',
//         name: 'ADD_ITEM',
//       );
//     } else {
//       // ✅ NEW ITEM: Add fresh row
//       state.orderItems.add(item);
//
//       developer.log(
//         '✅ NEW ITEM: ${item['item_name']} - Qty: $qty',
//         name: 'ADD_ITEM',
//       );
//     }
//
//     _updateTotal(state);
//   }
//
//
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
//   // ===== CRITICAL FIX: This method runs when waiter comes back to page =====
//   void setActiveTable(int tableId, dynamic tableInfoData) {
//     final TableInfo? tableInfo = tableInfoData is Map<String, dynamic>
//         ? mapToTableInfo(tableInfoData)
//         : tableInfoData as TableInfo?;
//
//     activeTableId.value = tableId;
//     final state = getTableState(tableId);
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//
//     developer.log(
//       'SET ACTIVE TABLE → tableId:$tableId, orderId:$orderId, hasLoadedOrder:${state.hasLoadedOrder.value}, placedOrderId:${state.placedOrderId.value}',
//       name: 'ACTIVE_TABLE',
//     );
//
//     // FIX: Check all conditions to decide if we should fetch
//     // 1. Order exists in backend (orderId > 0)
//     // 2. We haven't loaded it yet (hasLoadedOrder == false)
//     if (orderId > 0 && !state.hasLoadedOrder.value) {
//       developer.log(
//         'TRIGGER FETCH → orderId:$orderId for table $tableId',
//         name: 'ACTIVE_TABLE',
//       );
//       fetchOrder(orderId, tableId);
//     } else if (orderId <= 0 &&
//         state.placedOrderId.value != null &&
//         state.placedOrderId.value! > 0 &&
//         !state.hasLoadedOrder.value) {
//       // Fallback: If tableInfo doesn't have orderId but we have it stored locally
//       developer.log(
//         'TRIGGER FETCH (FALLBACK) → using stored placedOrderId:${state.placedOrderId.value}',
//         name: 'ACTIVE_TABLE',
//       );
//       fetchOrder(state.placedOrderId.value!, tableId);
//     } else {
//       developer.log(
//         'SKIP FETCH → orderId:$orderId, hasLoadedOrder:${state.hasLoadedOrder.value}, placedOrderId:${state.placedOrderId.value}',
//         name: 'ACTIVE_TABLE',
//       );
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
//       final requestBody = {
//         "items": newItems.map((item) {
//           final reorderItem = {
//             "menu_item_id": item['id'] as int,
//             "quantity": item['quantity'] as int,
//           };
//
//           if (item['special_instructions'] != null &&
//               item['special_instructions'].toString().trim().isNotEmpty) {
//             reorderItem['special_instructions'] =
//             item['special_instructions'] as int;
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
//         state.hasLoadedOrder.value = false;
//         state.placedOrderId.value = placedOrderId;
//
//         // ✅ FIX: Freeze only newItems (not all orderItems)
//         freezeItems(state, newItems);
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
//         final controller = Get.find<TakeOrdersController>();
//         controller.refreshTables();
//
//         NavigationService.goBack();
//       } else {
//         throw Exception(
//             response.errorMessage ?? 'Failed to add items to order');
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
//   Future<void> fetchOrder(int orderId, int tableId) async {
//     final state = getTableState(tableId);
//
//     if (state.isLoadingOrder.value || orderId == 0) return;
//     if (state.hasLoadedOrder.value) return;
//
//     try {
//       state.isLoadingOrder.value = true;
//
//       final response = await ApiService.get<OrderResponseModel>(
//         endpoint: ApiConstants.waiterGetTableOrder(orderId),
//         fromJson: (json) => OrderResponseModel.fromJson(json),
//         includeToken: true,
//       );
//
//       if (response.success && response.data != null) {
//         final orderData = response.data!;
//         state.placedOrderId.value = orderData.data.order.id;
//
//         state.orderItems.clear();
//         state.frozenItems.clear();
//
//         // 1) Group by menuItemId
//         final Map<int, int> groupedQty = {};
//         for (final apiItem in orderData.data.items) {
//           final id = apiItem.menuItemId;
//           groupedQty[id] = (groupedQty[id] ?? 0) + apiItem.quantity;
//         }
//
//         // 2) Build single local item per menuItemId
//         groupedQty.forEach((id, totalQty) {
//           final apiSample =
//           orderData.data.items.firstWhere((e) => e.menuItemId == id);
//           final localItem = apiSample.toLocalOrderItem();
//
//           // ✅ FIX: Ensure 'id' field is set correctly for addItemToTable to find it
//           localItem['id'] = id;
//           localItem['quantity'] = totalQty;
//           localItem['total_price'] =
//               (localItem['price'] as double) * totalQty.toDouble();
//           state.orderItems.add(localItem);
//
//           // Frozen = full quantity from backend
//           state.frozenItems.add(FrozenItem(
//             id: id.toString(),
//             name: apiSample.itemName,
//             quantity: totalQty,
//           ));
//         });
//
//         _updateTotal(state);
//       } else {
//         throw Exception(response.errorMessage ?? 'Failed to fetch order');
//       }
//     } finally {
//       state.isLoadingOrder.value = false;
//       state.hasLoadedOrder.value = true;
//     }
//   }
//
//
//   // 4. After successful order creation, refresh properly
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
//       if (state.isReorderScenario) {
//         await _addItemsToExistingOrder(
//           placedOrderId: state.placedOrderId.value!,
//           tableId: tableId,
//           context: context,
//           tableInfo: tableInfo,
//           newItems: newItems,
//         );
//       } else {
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
//             specialInstructions:
//             item['special_instructions'] as String?,
//           ))
//               .toList(),
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
//           final createdOrderId = response.data!.data.order.id;
//
//           state.placedOrderId.value = createdOrderId;
//           developer.log(
//             'Order created successfully. Order ID: $createdOrderId stored in state',
//             name: 'ORDER_API',
//           );
//
//           // ✅ FIX: Freeze only newItems (not orderItems)
//           freezeItems(state, newItems);
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
//           state.hasLoadedOrder.value = false;
//           developer.log(
//             'hasLoadedOrder reset to false - fetchOrder will trigger when waiter returns',
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
//
// }
//
//

import 'package:flutter/material.dart' hide Table;
import 'package:get/get.dart';
import 'package:hotelbilling/app/modules/controllers/WaiterPanelController/take_order_controller.dart';
import 'dart:developer' as developer;
import '../../service/table_order_service.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/RequestModel/create_order_request.dart';
import '../../../data/models/ResponseModel/table_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../route/app_routes.dart';
import '../../model/table_order_state_mode.dart';

class OrderManagementController extends GetxController {
  // Dependencies
  final OrderRepository _orderRepository = OrderRepository();

  // State
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

  // ==================== STATE MANAGEMENT ====================

  /// Get or create table state
  TableOrderState getTableState(int tableId) {
    final state = tableOrders.putIfAbsent(tableId, () => TableOrderState(tableId: tableId),);
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
      developer.log("Resetting state for available table $tableId",
          name: "RESET_STATE");
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
    developer.log('REMOVED → table:$tableId id:${item['id']}',
        name: 'REMOVE_ITEM');
    _logTableSnapshot(tableId, state);
  }

  // ==================== ORDER OPERATIONS ====================

  /// Fetch order from server
  Future<void> fetchOrder(int orderId, int tableId) async {
    final state = getTableState(tableId);

    if (state.isLoadingOrder.value || orderId == 0 || state.hasLoadedOrder.value) {
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

  /// Create new order
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

    final response = await _orderRepository.createOrder(request);
    final createdOrderId = response.data.order.id;

    state.placedOrderId.value = createdOrderId;
    state.addFrozenItems(newItems);

    developer.log('Order created: ID $createdOrderId', name: 'ORDER_API');

    _showSuccessAndRefresh(context, tableInfo, tableId, successMessage);
  }

  /// Add items to existing order
  Future<void> _addItemsToExistingOrder({
    required int placedOrderId,
    required int tableId,
    required BuildContext context,
    required TableInfo? tableInfo,
    required List<Map<String, dynamic>> newItems,
  }) async {
    await _orderRepository.addItemsToOrder(placedOrderId, newItems);

    final state = getTableState(tableId);
    state.placedOrderId.value = placedOrderId;
    state.addFrozenItems(newItems);

    developer.log('Items added to order: ID $placedOrderId', name: 'REORDER_API');

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

  // ==================== PRIVATE HELPERS ====================

  void _updateTotal(TableOrderState state) {
    final newTotal = TableOrderService.calculateTotal(state.orderItems);
    state.updateTotal(newTotal);
    developer.log('TOTAL UPDATE → table:${state.tableId} total:₹$newTotal',
        name: 'UPDATE_TOTAL');
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
      developer.log('Error converting map to TableInfo: $e',
          name: 'MAP_CONVERSION');
      return null;
    }
  }
}



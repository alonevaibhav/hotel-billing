
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../core/utils/snakbar_utils.dart';
import '../../../route/app_routes.dart';

// Table-specific state model
class TableOrderState {
  final int tableId;
  final orderItems = <Map<String, dynamic>>[].obs;
  final isMarkAsUrgent = false.obs;
  final finalCheckoutTotal = 0.0.obs;
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  // NEW: Track frozen (sent to kitchen) quantities
  final frozenItems = <Map<String, dynamic>>[].obs;
  final hasFrozenItems = false.obs;

  TableOrderState({required this.tableId});

  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
  }

  // Clear all data
  void clearOrderData() {
    fullNameController.clear();
    phoneController.clear();
    orderItems.clear();
    frozenItems.clear();
    finalCheckoutTotal.value = 0.0;
    isMarkAsUrgent.value = false;
    hasFrozenItems.value = false;
    developer.log('Cleared order data for table $tableId');
  }

  // Get frozen quantity for a specific item
  int getFrozenQuantity(String itemId) {
    final frozenItem = frozenItems.firstWhereOrNull((item) => item['id'].toString() == itemId.toString()
    );
    return frozenItem?['frozen_quantity'] ?? 0;
  }

  // Check if item has frozen quantity
  bool hasItemFrozenQuantity(String itemId) {
    return getFrozenQuantity(itemId) > 0;
  }
}

// Main Order Management Controller
class OrderManagementController extends GetxController {
  final tableOrders = <int, TableOrderState>{}.obs;
  final activeTableId = Rxn<int>();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final _isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _isInitialized.value = true;
    developer.log('OrderManagementController initialized');
  }

  @override
  void onClose() {
    for (var state in tableOrders.values) {
      state.dispose();
    }
    tableOrders.clear();
    super.onClose();
  }

  // Get or create table state
  TableOrderState getTableState(int tableId) {
    if (!tableOrders.containsKey(tableId)) {
      tableOrders[tableId] = TableOrderState(tableId: tableId);
      developer.log('Created new table state for table ID: $tableId');
    }
    return tableOrders[tableId]!;
  }

  // Add item to specific table
  void addItemToTable(int tableId, Map<String, dynamic> item) {
    final state = getTableState(tableId);
    state.orderItems.add(item);
    _updateTableTotal(state);
    developer.log('Item added to table $tableId: ${item['item_name']}');
  }

  // Update quantity of specific item
  void updateItemQuantity(int tableId, int itemIndex, int newQuantity) {
    final state = getTableState(tableId);
    if (itemIndex >= 0 && itemIndex < state.orderItems.length && newQuantity > 0) {
      final item = state.orderItems[itemIndex];
      final frozenQuantity = state.getFrozenQuantity(item['id'].toString());

      // Prevent setting quantity below frozen amount
      if (newQuantity < frozenQuantity) {
        developer.log('Cannot set quantity below frozen amount: $frozenQuantity');
        return;
      }

      final price = item['price'] as double;
      item['quantity'] = newQuantity;
      item['total_price'] = price * newQuantity;

      state.orderItems[itemIndex] = item;
      _updateTableTotal(state);
      developer.log('Updated quantity for ${item['item_name']} in table $tableId: $newQuantity');
    }
  }

  // Calculate and update table total
  void _updateTableTotal(TableOrderState state) {
    double total = 0.0;
    for (var item in state.orderItems) {
      total += item['total_price'] as double;
    }
    state.finalCheckoutTotal.value = total;
  }

  // Set active table
  void setActiveTable(int tableId, Map<String, dynamic>? tableData) {
    if (!_isInitialized.value) {
      _setActiveTableInternal(tableId, tableData);
    } else {
      _setActiveTableInternal(tableId, tableData);
    }
  }

  void _setActiveTableInternal(int tableId, Map<String, dynamic>? tableData) {
    activeTableId.value = tableId;
    final state = getTableState(tableId);
    developer.log('Active table set to: $tableId');
  }

  // Get current table state
  TableOrderState? get currentTableState {
    if (activeTableId.value == null) return null;
    return getTableState(activeTableId.value!);
  }

  // Toggle urgent status
  void toggleUrgentForTable(int tableId, BuildContext context, Map<String, dynamic>? tableData) {
    final state = getTableState(tableId);
    state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;

    final tableNumber = tableData?['tableNumber'] ?? tableId;

    if (state.isMarkAsUrgent.value) {
      SnackBarUtil.showSuccess(
        context,
        'Table $tableNumber marked as urgent',
        title: 'Marked as urgent',
        duration: const Duration(seconds: 1),
      );
    } else {
      SnackBarUtil.showInfo(
        context,
        'Table $tableNumber removed from urgent',
        title: 'Normal priority',
        duration: const Duration(seconds: 1),
      );
    }

    developer.log('Urgent status toggled for table $tableId: ${state.isMarkAsUrgent.value}');
  }

  // Navigation methods
  void navigateToAddItems(int tableId, Map<String, dynamic>? tableData) {
    try {
      final state = getTableState(tableId);
      NavigationService.addItems(tableData);
      developer.log('Navigating to add items for table $tableId');
    } catch (e) {
      developer.log('Navigation error: $e');
      SnackBarUtil.showError(
        Get.context!,
        'Unable to proceed. Please try again.',
        title: 'Navigation Error',
        duration: const Duration(seconds: 1),
      );
    }
  }

  void navigateBack() {
    try {
      if (Get.context!.canPop()) {
        Get.context!.pop();
      } else {
        Get.context!.go('/take-orders');
      }
      developer.log('Navigating back');
    } catch (e) {
      developer.log('Back navigation error: $e');
      Get.back();
    }
  }

  // UPDATED: Send to chef method with freezing
  Future<void> sendToChef(int tableId, context, Map<String, dynamic>? table, List<Map<String, dynamic>> orderItems) async {
    try {
      isLoading.value = true;

      final tableNumber = table?['tableNumber'] ?? tableId;

      // Get only new items (not frozen ones) for KOT
      final newItemsForKOT = _getNewItemsForKOT(tableId, orderItems);
      final orderData = _prepareOrderData(tableId, table, newItemsForKOT, 'chef');

      developer.log('Sending KOT to chef for table $tableId:');
      developer.log('New items for KOT: ${newItemsForKOT.length}');
      developer.log('Order Data: ${orderData.toString()}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // FREEZE current quantities after successful send
      _freezeOrderItems(tableId, orderItems);

      SnackBarUtil.showSuccess(
        context,
        'KOT sent to chef for Table $tableNumber',
        title: 'Sent to Chef',
        duration: const Duration(seconds: 2),
      );
      NavigationService.goBack();

      developer.log('KOT successfully sent to chef for table $tableId');
    } catch (e) {
      developer.log('Send to chef error for table $tableId: $e');
      final tableNumber = table?['tableNumber'] ?? tableId;

      SnackBarUtil.showError(
        context,
        'Failed to send KOT to chef for Table $tableNumber. Please try again.',
        title: 'Error',
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // UPDATED: Checkout process with freezing
  Future<void> proceedToCheckout(int tableId, context, Map<String, dynamic>? table, List<Map<String, dynamic>> orderItems) async {
    try {
      isLoading.value = true;

      final tableNumber = table?['tableNumber'] ?? tableId;

      // Get only new items (not frozen ones) for KOT
      final newItemsForKOT = _getNewItemsForKOT(tableId, orderItems);
      final orderData = _prepareOrderData(tableId, table, newItemsForKOT, 'manager');

      developer.log('Processing checkout for table $tableId:');
      developer.log('New items for KOT: ${newItemsForKOT.length}');
      developer.log('Order Data: ${orderData.toString()}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // FREEZE current quantities after successful send
      _freezeOrderItems(tableId, orderItems);

      SnackBarUtil.showSuccess(
        context,
        'KOT sent to manager for Table $tableNumber!',
        title: 'Order Confirmed',
        duration: const Duration(seconds: 3),
      );

      NavigationService.goBack();
      developer.log('Order successfully submitted for table $tableId');
    } catch (e) {
      developer.log('Checkout error for table $tableId: $e');
      final tableNumber = table?['tableNumber'] ?? tableId;

      SnackBarUtil.showError(
        context,
        'Failed to place order for Table $tableNumber. Please try again.',
        title: 'Error',
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // NEW: Freeze order items after sending KOT
  void _freezeOrderItems(int tableId, List<Map<String, dynamic>> orderItems) {
    final state = getTableState(tableId);

    for (var item in orderItems) {
      final itemId = item['id'].toString();
      final currentQuantity = item['quantity'] as int;

      // Update or add frozen item
      final frozenIndex = state.frozenItems.indexWhere(
              (frozen) => frozen['id'].toString() == itemId
      );

      if (frozenIndex >= 0) {
        // Update existing frozen item
        state.frozenItems[frozenIndex]['frozen_quantity'] = currentQuantity;
      } else {
        // Add new frozen item
        state.frozenItems.add({
          'id': item['id'],
          'item_name': item['item_name'],
          'frozen_quantity': currentQuantity,
        });
      }
    }

    state.hasFrozenItems.value = state.frozenItems.isNotEmpty;
    developer.log('Frozen ${orderItems.length} items for table $tableId');
  }

  // NEW: Get only new items for KOT (quantities above frozen amounts)
  List<Map<String, dynamic>> _getNewItemsForKOT(int tableId, List<Map<String, dynamic>> orderItems) {
    final state = getTableState(tableId);
    final newItems = <Map<String, dynamic>>[];

    for (var item in orderItems) {
      final itemId = item['id'].toString();
      final currentQuantity = item['quantity'] as int;
      final frozenQuantity = state.getFrozenQuantity(itemId);
      final newQuantity = currentQuantity - frozenQuantity;

      if (newQuantity > 0) {
        // Create a copy with only the new quantity
        final newItem = Map<String, dynamic>.from(item);
        newItem['quantity'] = newQuantity;
        newItem['total_price'] = (item['price'] as double) * newQuantity;
        newItems.add(newItem);
      }
    }

    return newItems;
  }

  // Helper method to prepare order data
  Map<String, dynamic> _prepareOrderData(
      int tableId,
      Map<String, dynamic>? table,
      List<Map<String, dynamic>> orderItems,
      String destination,
      ) {
    final state = getTableState(tableId);

    return {
      'orderId': 'ORD_${tableId}_${DateTime.now().millisecondsSinceEpoch}',
      'tableId': tableId,
      'tableNumber': table?['tableNumber'],
      'table': table,
      'recipientName': state.fullNameController.text.trim(),
      'phoneNumber': state.phoneController.text.trim(),
      'isUrgent': state.isMarkAsUrgent.value,
      'orderTime': DateTime.now().toIso8601String(),
      'status': 'pending',
      'isOccupied': true,
      'destination': destination,
      'items': orderItems.map((item) => {
        'id': item['id'],
        'name': item['item_name'],
        'quantity': item['quantity'],
        'price': item['price'],
        'total_price': item['total_price'],
        'category': item['category'],
        'description': item['description'],
        'is_vegetarian': item['is_vegetarian'],
        'is_featured': item['is_featured'],
      }).toList(),
      'itemCount': orderItems.length,
      'totalAmount': orderItems.fold<double>(0.0, (sum, item) => sum + (item['total_price'] as double)),
    };
  }

  // Check if can proceed to checkout
  bool canProceedToCheckout(int tableId) {
    final state = getTableState(tableId);
    return !isLoading.value && state.orderItems.isNotEmpty;
  }

  // Clear table orders
  void clearTableOrders(int tableId) {
    if (tableOrders.containsKey(tableId)) {
      tableOrders[tableId]?.dispose();
      tableOrders.remove(tableId);
      developer.log('Table orders cleared for table $tableId');
    }
  }

  // UPDATED: Increment item quantity
  void incrementItemQuantity(int tableId, int itemIndex) {
    final state = getTableState(tableId);
    if (itemIndex >= 0 && itemIndex < state.orderItems.length) {
      final item = state.orderItems[itemIndex];
      final price = item['price'] as double;
      final currentQuantity = item['quantity'] as int;
      final newQuantity = currentQuantity + 1;

      item['quantity'] = newQuantity;
      item['total_price'] = price * newQuantity;

      state.orderItems[itemIndex] = item;
      _updateTableTotal(state);

      developer.log('Incremented ${item['item_name']} to quantity $newQuantity in table $tableId');
    }
  }

  // FIXED: Decrement item quantity (with proper frozen quantity logic)
  void decrementItemQuantity(int tableId, int itemIndex, context) {
    final state = getTableState(tableId);
    if (itemIndex >= 0 && itemIndex < state.orderItems.length) {
      final item = state.orderItems[itemIndex];
      final currentQuantity = item['quantity'] as int;
      final frozenQuantity = state.getFrozenQuantity(item['id'].toString());

      // CASE 1: If no frozen quantity (before KOT), allow removal when quantity becomes 0
      if (frozenQuantity == 0) {
        if (currentQuantity > 1) {
          // Normal decrement
          final price = item['price'] as double;
          final newQuantity = currentQuantity - 1;

          item['quantity'] = newQuantity;
          item['total_price'] = price * newQuantity;

          state.orderItems[itemIndex] = item;
          _updateTableTotal(state);

          developer.log('Decremented ${item['item_name']} to quantity $newQuantity in table $tableId');
        } else if (currentQuantity == 1) {
          // Remove item when quantity would become 0 (call with fromDecrement flag)
          removeItemFromTable(tableId, itemIndex, context, fromDecrement: true);
        }
      }
      // CASE 2: If has frozen quantity (after KOT), stop at frozen quantity
      else {
        if (currentQuantity > frozenQuantity) {
          final price = item['price'] as double;
          final newQuantity = currentQuantity - 1;

          item['quantity'] = newQuantity;
          item['total_price'] = price * newQuantity;

          state.orderItems[itemIndex] = item;
          _updateTableTotal(state);

          developer.log('Decremented ${item['item_name']} to quantity $newQuantity in table $tableId');
        } else {
          // Cannot decrement below frozen quantity
          SnackBarUtil.showWarning(
            context,
            'Cannot reduce below sent quantity ($frozenQuantity)',
            title: 'Item Already Sent',
            duration: const Duration(seconds: 2),
          );
        }
      }
    }
  }

  // FIXED: Remove item from table (allow removal from decrement logic)
  void removeItemFromTable(int tableId, int itemIndex, context, {bool fromDecrement = false}) {
    final state = getTableState(tableId);
    if (itemIndex >= 0 && itemIndex < state.orderItems.length) {
      final item = state.orderItems[itemIndex];
      final frozenQuantity = state.getFrozenQuantity(item['id'].toString());

      // Only prevent direct removal (delete button), allow removal from decrement logic
      if (frozenQuantity > 0 && !fromDecrement) {
        SnackBarUtil.showWarning(
          context,
          'Cannot remove item - $frozenQuantity already sent to kitchen',
          title: 'Item Already Sent',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final removedItem = state.orderItems.removeAt(itemIndex);
      _updateTableTotal(state);

      developer.log('Removed ${removedItem['item_name']} from table $tableId');

      SnackBarUtil.showInfo(
        context,
        '${removedItem['item_name']} removed from order',
        title: 'Item Removed',
        duration: const Duration(seconds: 1),
      );
    }
  }
}
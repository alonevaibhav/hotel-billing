import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../core/utils/snakbar_utils.dart';
import '../../route/app_routes.dart';

// Table-specific state model
class TableOrderState {
  final int tableId;
  final orderItems = <Map<String, dynamic>>[].obs; // This will now store actual items
  final isMarkAsUrgent = false.obs;
  final finalCheckoutTotal = 0.0.obs; // This will be calculated from items
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  TableOrderState({required this.tableId});

  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
  }


  // Clear all later when needed
  void clearOrderData() {
    fullNameController.clear();
    phoneController.clear();
    orderItems.clear();
    finalCheckoutTotal.value = 0.0;
    isMarkAsUrgent.value = false;
    developer.log('Cleared order data for table $tableId');
  }

}

// Main Order Management Controller
class OrderManagementController extends GetxController {
  // Store orders per table ID
  final tableOrders = <int, TableOrderState>{}.obs;

  // Current active table
  final activeTableId = Rxn<int>();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Loading state
  final isLoading = false.obs;

  // Initialization flag to prevent build-time updates
  final _isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _isInitialized.value = true;
    developer.log('OrderManagementController initialized');
  }

  @override
  void onClose() {
    // Clean up all table states
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
    if (itemIndex >= 0 &&
        itemIndex < state.orderItems.length &&
        newQuantity > 0) {
      final item = state.orderItems[itemIndex];
      final price = item['price'] as double;

      item['quantity'] = newQuantity;
      item['total_price'] = price * newQuantity;

      state.orderItems[itemIndex] = item;
      _updateTableTotal(state);
      developer.log(
          'Updated quantity for ${item['item_name']} in table $tableId: $newQuantity');
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






  // Safe table context setting - can be called from initState
  void setActiveTable(int tableId, Map<String, dynamic>? tableData) {
    if (!_isInitialized.value) {
      _setActiveTableInternal(tableId, tableData);
    } else {
      _setActiveTableInternal(tableId, tableData);
    }
  }

  void _setActiveTableInternal(int tableId, Map<String, dynamic>? tableData) {
    activeTableId.value = tableId;
    // Initialize table state if needed
    final state = getTableState(tableId);
    developer.log('Active table set to: $tableId');
  }

  // Get current table state
  TableOrderState? get currentTableState {
    if (activeTableId.value == null) return null;
    return getTableState(activeTableId.value!);
  }

  // Table-specific operations
  void toggleUrgentForTable(
      int tableId, BuildContext context, Map<String, dynamic>? tableData) {
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

    developer.log(
        'Urgent status toggled for table $tableId: ${state.isMarkAsUrgent.value}');
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

// Send to chef method - now includes actual order items
  Future<void> sendToChef(int tableId,  context,
      Map<String, dynamic>? table, List<Map<String, dynamic>> orderItems) async {
    try {
      isLoading.value = true;

      final tableNumber = table?['tableNumber'] ?? tableId;
      final orderData = _prepareOrderData(tableId, table, orderItems, 'chef');

      developer.log('Sending KOT to chef for table $tableId:');
      developer.log('Order Dataa: ${orderData.toString()}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

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

// Checkout process - now includes actual order items
  Future<void> proceedToCheckout(int tableId,  context,
      Map<String, dynamic>? table, List<Map<String, dynamic>> orderItems) async {
    try {
      isLoading.value = true;

      final tableNumber = table?['tableNumber'] ?? tableId;
      final orderData = _prepareOrderData(tableId, table, orderItems, 'manager');

      developer.log('Processing checkout for table $tableId:');
      developer.log('Order Data: ${orderData.toString()}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final state = getTableState(tableId);

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

// Helper method to prepare order data with actual items
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
      'destination': destination, // 'chef' or 'manager'
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
      'totalAmount': state.finalCheckoutTotal.value,
    };
  }

// Updated can proceed check
  bool canProceedToCheckout(int tableId) {
    final state = getTableState(tableId);
    return !isLoading.value && state.orderItems.isNotEmpty;
  }


  void clearTableOrders(int tableId) {
    if (tableOrders.containsKey(tableId)) {
      tableOrders[tableId]?.dispose();
      tableOrders.remove(tableId);
      developer.log('Table orders cleared for table $tableId');
    }
  }

  // bool canProceedToCheckout(int tableId) {
  //   // Since you removed form validation, we'll just check if not loading
  //   return !isLoading.value;
  // }


  //After Adding Items from AddItemsView, increment/decrement/remove items in the order list

  // Increment item quantity in the order list
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

      developer.log(
          'Incremented ${item['item_name']} to quantity $newQuantity in table $tableId');
    }
  }

// Decrement item quantity in the order list
  void decrementItemQuantity(int tableId, int itemIndex, context) {
    final state = getTableState(tableId);
    if (itemIndex >= 0 && itemIndex < state.orderItems.length) {
      final item = state.orderItems[itemIndex];
      final currentQuantity = item['quantity'] as int;

      if (currentQuantity > 1) {
        final price = item['price'] as double;
        final newQuantity = currentQuantity - 1;

        item['quantity'] = newQuantity;
        item['total_price'] = price * newQuantity;

        state.orderItems[itemIndex] = item;
        _updateTableTotal(state);

        developer.log(
            'Decremented ${item['item_name']} to quantity $newQuantity in table $tableId');
      } else {
        // Remove item if quantity becomes 0
        removeItemFromTable(tableId, itemIndex, context);
      }
    }
  }

// Remove item completely from the order
  void removeItemFromTable(int tableId, int itemIndex, context) {
    final state = getTableState(tableId);
    if (itemIndex >= 0 && itemIndex < state.orderItems.length) {
      final removedItem = state.orderItems.removeAt(itemIndex);
      _updateTableTotal(state);

      developer.log('Removed ${removedItem['item_name']} from table $tableId');

      // Show confirmation snackbar
      SnackBarUtil.showInfo(
        context,
        '${removedItem['item_name']} removed from order',
        title: 'Item Removed',
        duration: const Duration(seconds: 1),
      );
    }
  }
}

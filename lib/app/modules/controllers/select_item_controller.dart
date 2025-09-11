import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../core/utils/snakbar_utils.dart';

// Table-specific state model
class TableOrderState {
  final int tableId;
  final orderItems = <Map<String, dynamic>>[].obs;
  final isMarkAsUrgent = false.obs;
  final finalCheckoutTotal = 0.0.obs;
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  TableOrderState({required this.tableId});

  void updateTotal() {
    double total = 0.0;
    for (var item in orderItems) {
      final price = (item['price'] ?? 0.0) as double;
      final quantity = (item['quantity'] ?? 1) as int;
      total += price * quantity;
    }
    finalCheckoutTotal.value = total;
  }

  int get totalItemsCount {
    return orderItems.fold(
        0, (sum, item) => sum + (item['quantity'] as int? ?? 1));
  }

  // Clean up controllers when disposing
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
  }

  // Clear all order data
  void clearOrderData() {
    fullNameController.clear();
    phoneController.clear();
    orderItems.clear();
    finalCheckoutTotal.value = 0.0;
    isMarkAsUrgent.value = false;
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

  @override
  void onInit() {
    super.onInit();
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

  // Switch active table context
  void setActiveTable(int tableId, Map<String, dynamic>? tableData) {
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

  void addItemToTable(int tableId, Map<String, dynamic> item,
      BuildContext context, Map<String, dynamic>? tableData) {
    final state = getTableState(tableId);

    // Add table context to item
    final itemWithContext = Map<String, dynamic>.from(item);
    itemWithContext['tableId'] = tableId;
    itemWithContext['addedAt'] = DateTime.now().toIso8601String();
    itemWithContext['itemId'] =
        '${tableId}_${state.orderItems.length}_${DateTime.now().millisecondsSinceEpoch}';

    // Ensure quantity is set
    if (!itemWithContext.containsKey('quantity')) {
      itemWithContext['quantity'] = 1;
    }

    state.orderItems.add(itemWithContext);
    state.updateTotal();

    final tableNumber = tableData?['tableNumber'] ?? tableId;

    SnackBarUtil.showSuccess(
      context,
      '${itemWithContext['name']} added to Table $tableNumber',
      title: 'Item Added',
      duration: const Duration(seconds: 1),
    );

    developer.log('Item added to table $tableId: ${itemWithContext['name']}');
  }

  void removeItemFromTable(int tableId, int index, BuildContext context,
      Map<String, dynamic>? tableData) {
    final state = getTableState(tableId);

    if (index >= 0 && index < state.orderItems.length) {
      final removedItem = state.orderItems[index];
      state.orderItems.removeAt(index);
      state.updateTotal();

      final tableNumber = tableData?['tableNumber'] ?? tableId;

      SnackBarUtil.showInfo(
        context,
        '${removedItem['name']} removed from Table $tableNumber',
        title: 'Item Removed',
        duration: const Duration(seconds: 1),
      );

      developer.log(
          'Item removed from table $tableId at index $index: ${removedItem['name']}');
    }
  }

  void updateItemQuantity(int tableId, int index, int newQuantity,
      BuildContext context, Map<String, dynamic>? tableData) {
    final state = getTableState(tableId);

    if (index >= 0 && index < state.orderItems.length && newQuantity > 0) {
      state.orderItems[index]['quantity'] = newQuantity;
      state.updateTotal();
      developer.log(
          'Item quantity updated for table $tableId at index $index: $newQuantity');
    } else if (newQuantity <= 0) {
      removeItemFromTable(tableId, index, context, tableData);
    }
  }

  void clearAllItemsForTable(
      int tableId, BuildContext context, Map<String, dynamic>? tableData) {
    final state = getTableState(tableId);

    if (state.orderItems.isNotEmpty) {
      state.orderItems.clear();
      state.updateTotal();

      final tableNumber = tableData?['tableNumber'] ?? tableId;

      SnackBarUtil.showInfo(
        context,
        'All items cleared for Table $tableNumber',
        title: 'Items Cleared',
        duration: const Duration(seconds: 1),
      );

      developer.log('All items cleared for table $tableId');
    }
  }

  // Navigation methods
  void navigateToAddItems(int tableId, Map<String, dynamic>? tableData) {
    try {
      final state = getTableState(tableId);

      Get.context!.go('/add-items', extra: {
        'tableData': tableData,
        'currentOrders': state.orderItems.toList(),
        'tableId': tableId,
        'tableNumber': tableData?['tableNumber'] ?? tableId,
      });

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

  // Checkout process
  Future<void> proceedToCheckout(int tableId, BuildContext context,
      Map<String, dynamic>? tableData) async {
    final state = getTableState(tableId);

    if (state.orderItems.isEmpty) {
      final tableNumber = tableData?['tableNumber'] ?? tableId;
      SnackBarUtil.showWarning(
        context,
        'Please add items to your order for Table $tableNumber',
        title: 'No Items',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Mock API call for order submission
      await Future.delayed(const Duration(seconds: 2));

      final orderData = {
        'orderId': 'ORD_${tableId}_${DateTime.now().millisecondsSinceEpoch}',
        'tableId': tableId,
        'tableNumber': tableData?['tableNumber'],
        'table': tableData,
        'recipientName': state.fullNameController.text.trim(),
        'phoneNumber': state.phoneController.text.trim(),
        'isUrgent': state.isMarkAsUrgent.value,
        'orderItems': state.orderItems.toList(),
        'totalAmount': state.finalCheckoutTotal.value,
        'orderTime': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      final tableNumber = tableData?['tableNumber'] ?? tableId;

      SnackBarUtil.showSuccess(
        context,
        'Order placed successfully for Table $tableNumber!',
        title: 'Success',
        duration: const Duration(seconds: 2),
      );

      // Clear the table data after successful submission
      state.clearOrderData();

      // Navigate to order confirmation
      Get.context!.go('/order-confirmation', extra: orderData);

      developer.log('Order submitted for table $tableId: $orderData');
    } catch (e) {
      developer.log('Checkout error for table $tableId: $e');
      final tableNumber = tableData?['tableNumber'] ?? tableId;

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

  // Clear specific table when order is completed
  void clearTableOrders(int tableId) {
    if (tableOrders.containsKey(tableId)) {
      tableOrders[tableId]?.dispose();
      tableOrders.remove(tableId);
      developer.log('Table orders cleared for table $tableId');
    }
  }

  // Validation
  bool validateForm(int tableId) {
    return formKey.currentState?.validate() ?? false;
  }

  // Check if table can proceed to checkout
  bool canProceedToCheckout(int tableId) {
    final state = getTableState(tableId);
    return state.orderItems.isNotEmpty && !isLoading.value;
  }
}

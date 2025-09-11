//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:developer' as developer;
//
// import '../../core/utils/snakbar_utils.dart';
//
// class SelectItemController extends GetxController {
//   // Form controllers
//   final fullNameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   // Reactive variables
//   final isLoading = false.obs;
//   final isMarkAsUrgent = false.obs;
//   final finalCheckoutTotal = 0.0.obs;
//   final errorMessage = ''.obs;
//
//   // Table data received from previous screen - now properly unique
//   final selectedTable = Rxn<Map<String, dynamic>>();
//
//   // Order items list - unique per table
//   final orderItems = <Map<String, dynamic>>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('SelectItemController initialized');
//
//     // Get table data if passed from previous screen
//     if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
//       selectedTable.value = Get.arguments as Map<String, dynamic>;
//       developer.log('Received table data: ${selectedTable.value}');
//
//       // Load any existing orders for this specific table
//       _loadExistingOrdersForTable();
//     }
//   }
//
//   @override
//   void onClose() {
//     fullNameController.dispose();
//     phoneController.dispose();
//     super.onClose();
//   }
//
//   // Load existing orders for the specific table (if any)
//   void _loadExistingOrdersForTable() {
//     try {
//       final tableId = selectedTable.value?['id'];
//       if (tableId != null) {
//         // In a real app, you would fetch existing orders from API/database
//         // For now, initialize empty order list for each table
//         orderItems.clear();
//         finalCheckoutTotal.value = 0.0;
//         developer.log('Initialized empty order list for table ID: $tableId');
//       }
//     } catch (e) {
//       developer.log('Error loading existing orders: $e');
//     }
//   }
//
//   // Get unique table identifier
//   String get tableIdentifier {
//     final tableId = selectedTable.value?['id'] ?? 0;
//     final tableNumber = selectedTable.value?['tableNumber'] ?? 0;
//     return 'Table $tableNumber (ID: $tableId)';
//   }
//
//   // Get table number for display
//   int get tableNumber {
//     return selectedTable.value?['tableNumber'] ?? 1;
//   }
//
//   // Get table ID
//   int get tableId {
//     return selectedTable.value?['id'] ?? 1;
//   }
//
//   // Check if table is occupied
//   bool get isTableOccupied {
//     return selectedTable.value?['isOccupied'] ?? false;
//   }
//
//   // Toggle urgent status
//   void toggleUrgentStatus(BuildContext context) {
//     isMarkAsUrgent.value = !isMarkAsUrgent.value;
//     developer.log('Urgent status toggled for ${tableIdentifier}: ${isMarkAsUrgent.value}');
//
//     if (isMarkAsUrgent.value) {
//       SnackBarUtil.showSuccess(
//         context,
//         'Selected order as urgent for ${tableIdentifier}',
//         title: 'Marked as urgent',
//         duration: const Duration(seconds: 1),
//       );
//     } else {
//       SnackBarUtil.showInfo(
//         context,
//         'Removed urgent status for ${tableIdentifier}',
//         title: 'Normal priority',
//         duration: const Duration(seconds: 1),
//       );
//     }
//   }
//
//   // Add items navigation with table context
//   void navigateToAddItems() {
//     try {
//       // Pass table data to add items screen
//       Get.context!.go('/add-items', extra: {
//         'tableData': selectedTable.value,
//         'currentOrders': orderItems.toList(),
//         'tableId': tableId,
//         'tableNumber': tableNumber,
//       });
//       developer.log('Navigating to add items for ${tableIdentifier}');
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
//   // Add this method to set table data
//   void setTableData(Map<String, dynamic> tableData) {
//     if (selectedTable.value == null) {
//       selectedTable.value = tableData;
//       developer.log('Table data set: ${selectedTable.value}');
//       _loadExistingOrdersForTable();
//     }
//   }
//
//   // Back navigation
//   void navigateBack([String? controllerTag]) {
//     try {
//       if (Get.context!.canPop()) {
//         Get.context!.pop();
//       } else {
//         Get.context!.go('/take-orders');
//       }
//       developer.log('Navigating back from ${tableIdentifier}');
//
//       // Clean up controller instance when navigating back
//       if (controllerTag != null) {
//         Get.delete<SelectItemController>(tag: controllerTag);
//       }
//     } catch (e) {
//       developer.log('Back navigation error: $e');
//       Get.back();
//     }
//   }
//
//   // Handle final checkout with table-specific data
//   Future<void> proceedToCheckout(BuildContext context) async {
//     if (orderItems.isEmpty) {
//       SnackBarUtil.showWarning(
//         context,
//         'Please add items to your order for ${tableIdentifier}',
//         title: 'No Items',
//         duration: const Duration(seconds: 2),
//       );
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//
//       // Mock API call for order submission
//       await Future.delayed(const Duration(seconds: 2));
//
//       final orderData = {
//         'orderId': 'ORD_${tableId}_${DateTime.now().millisecondsSinceEpoch}',
//         'tableId': selectedTable.value?['id'],
//         'tableNumber': selectedTable.value?['tableNumber'],
//         'table': selectedTable.value,
//         'recipientName': fullNameController.text.trim(),
//         'phoneNumber': phoneController.text.trim(),
//         'isUrgent': isMarkAsUrgent.value,
//         'orderItems': orderItems.toList(),
//         'totalAmount': finalCheckoutTotal.value,
//         'orderTime': DateTime.now().toIso8601String(),
//         'status': 'pending',
//       };
//
//       developer.log('Order submitted for ${tableIdentifier}: $orderData');
//
//       SnackBarUtil.showSuccess(
//         context,
//         'Order placed successfully for ${tableIdentifier}!',
//         title: 'Success',
//         duration: const Duration(seconds: 2),
//       );
//
//       // Clear the form and orders after successful submission
//       _clearOrderData();
//
//       // Navigate to order confirmation
//       Get.context!.go('/order-confirmation', extra: orderData);
//     } catch (e) {
//       developer.log('Checkout error for ${tableIdentifier}: $e');
//       errorMessage.value = e.toString();
//       SnackBarUtil.showError(
//         context,
//         'Failed to place order for ${tableIdentifier}. Please try again.',
//         title: 'Error',
//         duration: const Duration(seconds: 2),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Clear order data after successful submission
//   void _clearOrderData() {
//     fullNameController.clear();
//     phoneController.clear();
//     orderItems.clear();
//     finalCheckoutTotal.value = 0.0;
//     isMarkAsUrgent.value = false;
//     developer.log('Order data cleared for ${tableIdentifier}');
//   }
//
//   // Update total amount
//   void updateTotal() {
//     double total = 0.0;
//     for (var item in orderItems) {
//       final price = (item['price'] ?? 0.0) as double;
//       final quantity = (item['quantity'] ?? 1) as int;
//       total += price * quantity;
//     }
//     finalCheckoutTotal.value = total;
//     developer.log('Total updated for ${tableIdentifier}: ₹${total.toStringAsFixed(2)}');
//   }
//
//   // Add item to order with table context
//   void addItemToOrder(Map<String, dynamic> item,context) {
//     try {
//       // Ensure item has table context and unique identifier
//       final itemWithContext = Map<String, dynamic>.from(item);
//       itemWithContext['tableId'] = selectedTable.value?['id'];
//       itemWithContext['tableNumber'] = selectedTable.value?['tableNumber'];
//       itemWithContext['addedAt'] = DateTime.now().toIso8601String();
//       itemWithContext['itemId'] = '${tableId}_${orderItems.length}_${DateTime.now().millisecondsSinceEpoch}';
//
//       // Ensure quantity is set
//       if (!itemWithContext.containsKey('quantity')) {
//         itemWithContext['quantity'] = 1;
//       }
//
//       orderItems.add(itemWithContext);
//       updateTotal();
//       developer.log('Item added to order for ${tableIdentifier}: ${itemWithContext['name']}');
//
//       // Show success message
//         SnackBarUtil.showSuccess(
//           context,
//           '${itemWithContext['name']} added to ${tableIdentifier}',
//           title: 'Item Added',
//           duration: const Duration(seconds: 1),
//         );
//
//     } catch (e) {
//       developer.log('Error adding item to order: $e');
//     }
//   }
//
//   // Remove item from order
//   void removeItemFromOrder(int index,context) {
//     if (index >= 0 && index < orderItems.length) {
//       try {
//         final removedItem = orderItems[index];
//         orderItems.removeAt(index);
//         updateTotal();
//         developer.log('Item removed from order for ${tableIdentifier} at index $index: ${removedItem['name']}');
//
//           SnackBarUtil.showInfo(
//             context,
//             '${removedItem['name']} removed from ${tableIdentifier}',
//             title: 'Item Removed',
//             duration: const Duration(seconds: 1),
//           );
//
//       } catch (e) {
//         developer.log('Error removing item from order: $e');
//       }
//     }
//   }
//
//   // Update item quantity
//   void updateItemQuantity(int index, int newQuantity,context) {
//     if (index >= 0 && index < orderItems.length && newQuantity > 0) {
//       try {
//         orderItems[index]['quantity'] = newQuantity;
//         updateTotal();
//         developer.log('Item quantity updated for ${tableIdentifier} at index $index: $newQuantity');
//       } catch (e) {
//         developer.log('Error updating item quantity: $e');
//       }
//     } else if (newQuantity <= 0) {
//       removeItemFromOrder(index,context);
//     }
//   }
//
//   // Clear all items (useful for canceling order)
//   void clearAllItems(BuildContext context) {
//     if (orderItems.isNotEmpty) {
//       orderItems.clear();
//       updateTotal();
//       developer.log('All items cleared for ${tableIdentifier}');
//
//       SnackBarUtil.showInfo(
//         context,
//         'All items cleared for ${tableIdentifier}',
//         title: 'Items Cleared',
//         duration: const Duration(seconds: 1),
//       );
//     }
//   }
//
//   // Get total items count
//   int get totalItemsCount {
//     return orderItems.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 1));
//   }
//
//   // Validate form (if needed in future)
//   bool validateForm() {
//     return formKey.currentState?.validate() ?? false;
//   }
//
//   // Check if order is ready for checkout
//   bool get canProceedToCheckout {
//     return orderItems.isNotEmpty && !isLoading.value;
//   }
// }


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
    return orderItems.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 1));
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

  void addItemToTable(int tableId, Map<String, dynamic> item, BuildContext context, Map<String, dynamic>? tableData) {
    final state = getTableState(tableId);

    // Add table context to item
    final itemWithContext = Map<String, dynamic>.from(item);
    itemWithContext['tableId'] = tableId;
    itemWithContext['addedAt'] = DateTime.now().toIso8601String();
    itemWithContext['itemId'] = '${tableId}_${state.orderItems.length}_${DateTime.now().millisecondsSinceEpoch}';

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

  void removeItemFromTable(int tableId, int index, BuildContext context, Map<String, dynamic>? tableData) {
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

      developer.log('Item removed from table $tableId at index $index: ${removedItem['name']}');
    }
  }

  void updateItemQuantity(int tableId, int index, int newQuantity, BuildContext context, Map<String, dynamic>? tableData) {
    final state = getTableState(tableId);

    if (index >= 0 && index < state.orderItems.length && newQuantity > 0) {
      state.orderItems[index]['quantity'] = newQuantity;
      state.updateTotal();
      developer.log('Item quantity updated for table $tableId at index $index: $newQuantity');
    } else if (newQuantity <= 0) {
      removeItemFromTable(tableId, index, context, tableData);
    }
  }

  void clearAllItemsForTable(int tableId, BuildContext context, Map<String, dynamic>? tableData) {
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
  Future<void> proceedToCheckout(int tableId, BuildContext context, Map<String, dynamic>? tableData) async {
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

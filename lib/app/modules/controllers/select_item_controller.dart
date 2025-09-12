import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../core/utils/snakbar_utils.dart';
import '../../route/app_routes.dart';

// Table-specific state model
class TableOrderState {
  final int tableId;
  final orderItems = <Map<String, dynamic>>[].obs; // Empty for now, will be used later
  final isMarkAsUrgent = false.obs;
  final finalCheckoutTotal = 0.0.obs; // Always 0 for now, will be calculated later
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  TableOrderState({required this.tableId});

  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
  }

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

  // Send to chef method
  Future<void> sendToChef(int tableId,  context,
      Map<String, dynamic>? tableData) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      final tableNumber = tableData?['tableNumber'] ?? tableId;

      SnackBarUtil.showSuccess(
        context,
        'KOT sent to chef for Table $tableNumber',
        title: 'Sent to Chef',
        duration: const Duration(seconds: 2),
      );

      developer.log('KOT sent to chef for table $tableId');
    } catch (e) {
      developer.log('Send to chef error for table $tableId: $e');
      final tableNumber = tableData?['tableNumber'] ?? tableId;

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

  // Basic checkout process
  Future<void> proceedToCheckout(int tableId,  context,
      Map<String, dynamic>? tableData) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));

      final state = getTableState(tableId);
      final tableNumber = tableData?['tableNumber'] ?? tableId;

      final orderData = {
        'orderId': 'ORD_${tableId}_${DateTime.now().millisecondsSinceEpoch}',
        'tableId': tableId,
        'tableNumber': tableData?['tableNumber'],
        'table': tableData,
        'recipientName': state.fullNameController.text.trim(),
        'phoneNumber': state.phoneController.text.trim(),
        'isUrgent': state.isMarkAsUrgent.value,
        'orderTime': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      SnackBarUtil.showSuccess(
        context,
        'KOT sent to manager for Table $tableNumber!',
        title: 'Order Confirmed',
        duration: const Duration(seconds: 3),
      );

      state.clearOrderData();
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

  void clearTableOrders(int tableId) {
    if (tableOrders.containsKey(tableId)) {
      tableOrders[tableId]?.dispose();
      tableOrders.remove(tableId);
      developer.log('Table orders cleared for table $tableId');
    }
  }

  bool canProceedToCheckout(int tableId) {
    // Since you removed form validation, we'll just check if not loading
    return !isLoading.value;
  }
}

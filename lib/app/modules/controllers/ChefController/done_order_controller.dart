// // lib/features/accept_order/controllers/accept_order_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../core/utils/snakbar_utils.dart';
//
// class DoneOrderController extends GetxController {
//   // Reactive state variables
//   final isLoading = false.obs;
//   final ordersData = <Map<String, dynamic>>[].obs;
//   final errorMessage = ''.obs;
//   final rejectionReason = ''.obs;
//   final isRejectDialogVisible = false.obs;
//   final selectedOrderId = Rxn<int>();
//   final expandedOrders = <int>{}.obs; // Track which orders are expanded
//
//   // Text controller for rejection reason
//   final TextEditingController reasonController = TextEditingController();
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Initialize with sample data (in production, this would come from arguments)
//     _initializeOrdersData();
//   }
//
//   @override
//   void onReady() {
//     super.onReady();
//     // Any additional setup after widget is ready
//   }
//
//   @override
//   void onClose() {
//     reasonController.dispose();
//     super.onClose();
//   }
//
//   // Initialize orders data with the provided JSON
//   void _initializeOrdersData() {
//     ordersData.value = [
//       {
//         "tableId": 1,
//         "tableNumber": 7,
//         "orderNumber": 1,
//         "items": [
//           {
//             "id": 2,
//             "name": "Butter Chicken",
//             "quantity": 1,
//             "price": 319.99,
//             "total_price": 319.99,
//             "category": "Main Course",
//             "description": "Creamy tomato-based chicken curry",
//             "is_vegetarian": 0,
//             "is_featured": 0
//           },
//           {
//             "id": 1,
//             "name": "Chicken Biryani",
//             "quantity": 3,
//             "price": 299.0,
//             "total_price": 897.0,
//             "category": "Main Course",
//             "description": "Aromatic basmati rice with spiced chicken",
//             "is_vegetarian": 0,
//             "is_featured": 1
//           },
//           {
//             "id": 1,
//             "name": "Chicken Biryani",
//             "quantity": 3,
//             "price": 299.0,
//             "total_price": 897.0,
//             "category": "Main Course",
//             "description": "Aromatic basmati rice with spiced chicken",
//             "is_vegetarian": 0,
//             "is_featured": 1
//           },
//           {
//             "id": 1,
//             "name": "Chicken Biryani",
//             "quantity": 3,
//             "price": 299.0,
//             "total_price": 897.0,
//             "category": "Main Course",
//             "description": "Aromatic basmati rice with spiced chicken",
//             "is_vegetarian": 0,
//             "is_featured": 1
//           },
//           {
//             "id": 1,
//             "name": "Chicken Biryani",
//             "quantity": 3,
//             "price": 299.0,
//             "total_price": 897.0,
//             "category": "Main Course",
//             "description": "Aromatic basmati rice with spiced chicken",
//             "is_vegetarian": 0,
//             "is_featured": 1
//           },
//         ],
//         "itemCount": 6,
//         "totalAmount": 2802.99
//       },
//     ];
//   }
//
// // Toggle order expansion method
//   void toggleOrderExpansion(int tableId) {
//     if (expandedOrders.contains(tableId)) {
//       expandedOrders.remove(tableId);
//     } else {
//       expandedOrders.add(tableId);
//     }
//   }
//
//   // Accept order functionality
//   Future<void> markAsDoneOrder(context, int tableId) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       // Find the order
//       final orderIndex =
//           ordersData.indexWhere((order) => order['tableId'] == tableId);
//       if (orderIndex == -1) return;
//
//       final order = ordersData[orderIndex];
//
//       // Mock API call - simulate network delay
//       await Future.delayed(const Duration(seconds: 1));
//
//       // In production, make actual API call here
//       final response = {
//         'orderId': order['tableId'],
//         'status': 'accepted',
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//         'message': 'Order accepted successfully'
//       };
//
//       // Update order status
//       ordersData[orderIndex] = {
//         ...order,
//         'status': 'accepted',
//         'acceptedAt': DateTime.now().toIso8601String(),
//       };
//
//       // Show success message
//       SnackBarUtil.showSuccess(
//         context,
//         'Order #${order['orderNumber']} has been accepted successfully',
//         title: 'Order Accepted',
//         duration: const Duration(seconds: 2),
//       );
//
//       // Remove the accepted order from the list after a short delay
//       Future.delayed(const Duration(milliseconds: 1500), () {
//         ordersData.removeAt(orderIndex);
//       });
//     } catch (e) {
//       errorMessage.value = e.toString();
//       SnackBarUtil.showError(
//         context,
//         'Failed to accept order: ${e.toString()}',
//         title: 'Accept Failed',
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Update rejection reason
//   void updateRejectionReason(String reason) {
//     rejectionReason.value = reason;
//   }
//
//   // Format currency
//   String formatCurrency(double amount) {
//     return '₹${amount.toStringAsFixed(2)}';
//   }
//
//   // Get total items count for an order
//   int getTotalItemsCount(List<dynamic> items) {
//     return items.fold(
//         0, (total, item) => total + (item['quantity'] as int? ?? 0));
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/repositories/pending_orders_repository.dart';
import '../../../data/models/ResponseModel/pending_orders_model.dart';
import '../../../data/repositories/preparing_orders_repository.dart';

class DoneOrderController extends GetxController {

  final PreparingOrdersRepository _repository;

  DoneOrderController({PreparingOrdersRepository? repository})
      : _repository = repository ?? PreparingOrdersRepository();

  // Reactive state variables - NOW USING MODEL DIRECTLY
  final isLoading = false.obs;
  final ordersData = <GroupedOrder>[].obs;
  final errorMessage = ''.obs;
  final rejectionReason = ''.obs;
  final isRejectDialogVisible = false.obs;
  final selectedOrderId = Rxn<int>();
  final expandedOrders = <int>{}.obs;

  final TextEditingController reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPendingOrders();
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  /// Fetch pending orders from API
  Future<void> fetchPendingOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final groupedOrders = await _repository.getPendingOrders();
      ordersData.value = groupedOrders;
    } catch (e) {
      errorMessage.value = e.toString();
      SnackBarUtil.showError(
        Get.context!,
        'Failed to load orders: ${e.toString()}',
        title: 'Error',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await fetchPendingOrders();
  }

  /// Toggle order expansion
  void toggleOrderExpansion(int orderId) {
    if (expandedOrders.contains(orderId)) {
      expandedOrders.remove(orderId);
    } else {
      expandedOrders.add(orderId);
    }
  }

  /// Accept order
  Future<void> acceptOrder(BuildContext context, int orderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final orderIndex = ordersData.indexWhere((order) => order.orderId == orderId);
      if (orderIndex == -1) return;

      final order = ordersData[orderIndex];

      // Update status for all items in the order
      await _repository.updateAllOrderItemsStatus(
        orderId: order.orderId,
        itemIds: order.items.map((item) => item.id).toList(),
        status: 'ready',
      );

      SnackBarUtil.showSuccess(
        context,
        'Order #${order.orderId} has been completed successfully',
        title: 'Order Accepted',
        duration: const Duration(seconds: 2),
      );

      // Remove the accepted order from the list
      Future.delayed(const Duration(milliseconds: 500), () {
        ordersData.removeAt(orderIndex);
      });
    } catch (e) {
      errorMessage.value = e.toString();
      SnackBarUtil.showError(
        context,
        'Failed to accept order: ${e.toString()}',
        title: 'Accept Failed',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Show rejection dialog
  void showRejectDialog(int orderId) {
    selectedOrderId.value = orderId;
    isRejectDialogVisible.value = true;
    reasonController.clear();
    rejectionReason.value = '';
  }

  /// Hide rejection dialog
  void hideRejectDialog() {
    isRejectDialogVisible.value = false;
    selectedOrderId.value = null;
    reasonController.clear();
    rejectionReason.value = '';
  }

  /// Update rejection reason
  void updateRejectionReason(String reason) {
    rejectionReason.value = reason;
  }

  /// Reject order
  Future<void> rejectOrder(BuildContext context) async {
    if (reasonController.text.trim().isEmpty) {
      SnackBarUtil.showWarning(
        context,
        'Please provide a reason for cancelling the order',
        title: 'Reason Required',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedOrderId.value == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final orderIndex = ordersData.indexWhere((order) => order.orderId == selectedOrderId.value);
      if (orderIndex == -1) return;

      final order = ordersData[orderIndex];

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      hideRejectDialog();

      SnackBarUtil.showSuccess(
        context,
        'Order #${order.orderId} has been cancelled',
        title: 'Order Cancelled',
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(milliseconds: 1500), () {
        ordersData.removeAt(orderIndex);
      });
    } catch (e) {
      errorMessage.value = e.toString();
      SnackBarUtil.showError(
        context,
        'Failed to reject order: ${e.toString()}',
        title: 'Rejection Failed',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Validate rejection reason
  String? validateRejectionReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide a reason for cancellation';
    }
    if (value.trim().length < 10) {
      return 'Reason must be at least 10 characters long';
    }
    if (value.trim().length > 500) {
      return 'Reason cannot exceed 500 characters';
    }
    return null;
  }
}
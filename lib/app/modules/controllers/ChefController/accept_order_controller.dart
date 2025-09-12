// lib/features/accept_order/controllers/accept_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snakbar_utils.dart';

class AcceptOrderController extends GetxController {
  // Reactive state variables
  final isLoading = false.obs;
  final ordersData = <Map<String, dynamic>>[].obs;
  final errorMessage = ''.obs;
  final rejectionReason = ''.obs;
  final isRejectDialogVisible = false.obs;
  final selectedOrderId = Rxn<int>();
  final expandedOrders = <int>{}.obs; // Track which orders are expanded


  // Text controller for rejection reason
  final TextEditingController reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Initialize with sample data (in production, this would come from arguments)
    _initializeOrdersData();
  }

  @override
  void onReady() {
    super.onReady();
    // Any additional setup after widget is ready
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  // Initialize orders data with the provided JSON
  void _initializeOrdersData() {
    ordersData.value = [
      {
        "tableId": 1,
        "tableNumber": 7,
        "orderNumber": 1,
        "items": [
          {
            "id": 2,
            "name": "Butter Chicken",
            "quantity": 1,
            "price": 319.99,
            "total_price": 319.99,
            "category": "Main Course",
            "description": "Creamy tomato-based chicken curry",
            "is_vegetarian": 0,
            "is_featured": 0
          },
          {
            "id": 1,
            "name": "Chicken Biryani",
            "quantity": 3,
            "price": 299.0,
            "total_price": 897.0,
            "category": "Main Course",
            "description": "Aromatic basmati rice with spiced chicken",
            "is_vegetarian": 0,
            "is_featured": 1
          }  , {
            "id": 1,
            "name": "Chicken Biryani",
            "quantity": 3,
            "price": 299.0,
            "total_price": 897.0,
            "category": "Main Course",
            "description": "Aromatic basmati rice with spiced chicken",
            "is_vegetarian": 0,
            "is_featured": 1
          }, {
            "id": 1,
            "name": "Chicken Biryani",
            "quantity": 3,
            "price": 299.0,
            "total_price": 897.0,
            "category": "Main Course",
            "description": "Aromatic basmati rice with spiced chicken",
            "is_vegetarian": 0,
            "is_featured": 1
          }, {
            "id": 1,
            "name": "Chicken Biryani",
            "quantity": 3,
            "price": 299.0,
            "total_price": 897.0,
            "category": "Main Course",
            "description": "Aromatic basmati rice with spiced chicken",
            "is_vegetarian": 0,
            "is_featured": 1
          },
        ],
        "itemCount": 6,
        "totalAmount": 2802.99
      },
      {
        "tableId": 2,
        "tableNumber": 3,
        "orderNumber": 2,
        "items": [
          {
            "id": 3,
            "name": "Paneer Makhani",
            "quantity": 2,
            "price": 249.0,
            "total_price": 498.0,
            "category": "Main Course",
            "description": "Cottage cheese in rich tomato gravy",
            "is_vegetarian": 1,
            "is_featured": 1
          },
          {
            "id": 4,
            "name": "Fresh Lime Soda",
            "quantity": 3,
            "price": 89.0,
            "total_price": 267.0,
            "category": "Beverages",
            "description": "Refreshing lime soda with mint",
            "is_vegetarian": 1,
            "is_featured": 0
          }
        ],
        "itemCount": 7,
        "totalAmount": 855.0
      }
    ];
  }


// Toggle order expansion method
  void toggleOrderExpansion(int tableId) {
    if (expandedOrders.contains(tableId)) {
      expandedOrders.remove(tableId);
    } else {
      expandedOrders.add(tableId);
    }
  }

  // Get specific order by tableId
  Map<String, dynamic>? getOrderByTableId(int tableId) {
    try {
      return ordersData.firstWhere((order) => order['tableId'] == tableId);
    } catch (e) {
      return null;
    }
  }

  // Accept order functionality
  Future<void> acceptOrder( context, int tableId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Find the order
      final orderIndex =
          ordersData.indexWhere((order) => order['tableId'] == tableId);
      if (orderIndex == -1) return;

      final order = ordersData[orderIndex];

      // Mock API call - simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In production, make actual API call here
      final response = {
        'orderId': order['tableId'],
        'status': 'accepted',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': 'Order accepted successfully'
      };

      // Update order status
      ordersData[orderIndex] = {
        ...order,
        'status': 'accepted',
        'acceptedAt': DateTime.now().toIso8601String(),
      };

      // Show success message
      SnackBarUtil.showSuccess(
        context,
        'Order #${order['orderNumber']} has been accepted successfully',
        title: 'Order Accepted',
        duration: const Duration(seconds: 2),
      );

      // Remove the accepted order from the list after a short delay
      Future.delayed(const Duration(milliseconds: 1500), () {
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

  // Show rejection dialog
  void showRejectDialog(int tableId) {
    selectedOrderId.value = tableId;
    isRejectDialogVisible.value = true;
    reasonController.clear();
    rejectionReason.value = '';
  }

  // Hide rejection dialog
  void hideRejectDialog() {
    isRejectDialogVisible.value = false;
    selectedOrderId.value = null;
    reasonController.clear();
    rejectionReason.value = '';
  }

  // Update rejection reason
  void updateRejectionReason(String reason) {
    rejectionReason.value = reason;
  }

  // Reject order functionality
  Future<void> rejectOrder(BuildContext context) async {
    // Validate rejection reason
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

      // Find the order
      final orderIndex = ordersData
          .indexWhere((order) => order['tableId'] == selectedOrderId.value);
      if (orderIndex == -1) return;

      final order = ordersData[orderIndex];

      // Mock API call - simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In production, make actual API call here
      final response = {
        'orderId': order['tableId'],
        'status': 'rejected',
        'reason': reasonController.text.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': 'Order rejected successfully'
      };

      // Update order status
      ordersData[orderIndex] = {
        ...order,
        'status': 'rejected',
        'rejectionReason': reasonController.text.trim(),
        'rejectedAt': DateTime.now().toIso8601String(),
      };

      // Hide dialog first
      hideRejectDialog();

      // Show success message
      SnackBarUtil.showSuccess(
        context,
        'Order #${order['orderNumber']} has been cancelled',
        title: 'Order Cancelled',
        duration: const Duration(seconds: 2),
      );

      // Remove the rejected order from the list after a short delay
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

  // Format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Get item display name with quantity
  String getItemDisplayText(Map<String, dynamic> item) {
    final name = item['name'] ?? '';
    final quantity = item['quantity'] ?? 0;
    return quantity > 1 ? '$name (x$quantity)' : name;
  }

  // Validate rejection reason
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

  // Get total items count for an order
  int getTotalItemsCount(List<dynamic> items) {
    return items.fold(
        0, (total, item) => total + (item['quantity'] as int? ?? 0));
  }
}

// lib/features/accept_order/controllers/accept_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snakbar_utils.dart';

class ReadyOrderController extends GetxController {
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
          },
        ],
        "itemCount": 6,
        "totalAmount": 2802.99
      },
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

  // Accept order functionality
  Future<void> markAsDoneOrder(context, int tableId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Find the order
      final orderIndex = ordersData.indexWhere((order) => order['tableId'] == tableId);
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

  // Update rejection reason
  void updateRejectionReason(String reason) {
    rejectionReason.value = reason;
  }

  // Format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Get total items count for an order
  int getTotalItemsCount(List<dynamic> items) {
    return items.fold(
        0, (total, item) => total + (item['quantity'] as int? ?? 0));
  }
}

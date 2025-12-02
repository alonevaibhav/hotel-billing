// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:developer' as developer;
// import '../../../core/constants/api_constant.dart';
// import '../../../core/services/api_service.dart';
// import '../../../data/models/ResponseModel/table_model.dart';
// import '../../../route/app_routes.dart';
// import '../../../core/utils/snakbar_utils.dart';
//
// class TakeOrdersController extends GetxController {
//   // Reactive variables
//   final isLoading = false.obs;
//   final errorMessage = ''.obs;
//
//   // Tables data
//   final tableResponseModel = Rxn<TableResponseModel>();
//
//   // Grouped tables by area
//   final groupedTables = RxMap<String, List<TableInfo>>();
//
//   // All tables list for quick access
//   final allTables = <TableInfo>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('TakeOrdersController initialized', name: 'TakeOrders');
//     fetchTablesData();
//   }
//
//   @override
//   void onReady() {
//     super.onReady();
//     developer.log('TakeOrdersController ready', name: 'TakeOrders');
//   }
//
//   @override
//   void onClose() {
//     super.onClose();
//     developer.log('TakeOrdersController disposed', name: 'TakeOrders');
//   }
//
//   // Fetch tables data from API
//   Future<void> fetchTablesData() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       developer.log('Fetching tables data from API', name: 'TakeOrders');
//
//       final apiResponse = await ApiService.get<TableResponseModel>(
//         endpoint: ApiConstants.waiterGetTable,
//         fromJson: (json) => TableResponseModel.fromJson(json),
//         includeToken: true,
//       );
//
//       if (apiResponse != null && apiResponse.data != null) {
//         final response = apiResponse.data!;
//
//         if (response.success && response.data != null) {
//           tableResponseModel.value = response;
//           allTables.value = response.data!.tables;
//           _groupTablesByArea(response.data!.tables);
//
//           developer.log(
//             'Tables data loaded successfully: ${allTables.length} tables',
//             name: 'TakeOrders',
//           );
//         } else {
//           errorMessage.value = response.message.isNotEmpty
//               ? response.message
//               : 'Failed to load tables';
//           developer.log(
//             'Failed to load tables: ${errorMessage.value}',
//             name: 'TakeOrders.Error',
//           );
//         }
//       } else {
//         errorMessage.value = 'Failed to load tables data';
//         developer.log(
//           'API response is null',
//           name: 'TakeOrders.Error',
//         );
//       }
//     } catch (e) {
//       errorMessage.value = 'Error loading tables: ${e.toString()}';
//       developer.log(
//         'Error fetching tables data: ${e.toString()}',
//         name: 'TakeOrders.Error',
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Group tables by area name
//   void _groupTablesByArea(List<TableInfo> tables) {
//     groupedTables.clear();
//
//     for (var tableInfo in tables) {
//       if (!groupedTables.containsKey(tableInfo.areaName)) {
//         groupedTables[tableInfo.areaName] = [];
//       }
//       groupedTables[tableInfo.areaName]!.add(tableInfo);
//     }
//
//     developer.log(
//       'Tables grouped into ${groupedTables.length} areas',
//       name: 'TakeOrders',
//     );
//   }
//
//   // Get tables for a specific area
//   List<TableInfo> getTablesForArea(String areaName) {
//     return groupedTables[areaName] ?? [];
//   }
//
//   // Calculate time elapsed since order creation (in minutes)
//   int calculateElapsedTime(String createdAt) {
//     try {
//       final orderTime = DateTime.parse(createdAt);
//       final now = DateTime.now();
//       final difference = now.difference(orderTime);
//       return difference.inMinutes;
//     } catch (e) {
//       developer.log(
//         'Error calculating elapsed time: ${e.toString()}',
//         name: 'TakeOrders.Error',
//       );
//       return 0;
//     }
//   }
//
//   // Handle table selection
//   void handleTableTap(TableInfo tableInfo, BuildContext context) {
//     try {
//       final tableNumber = tableInfo.table.tableNumber;
//       final isOccupied = tableInfo.table.status == 'occupied';
//
//       developer.log(
//         'Table tapped: Table $tableNumber (ID: ${tableInfo.table.id}), Status: ${tableInfo.table.status}',
//         name: 'TakeOrders',
//       );
//
//       // Pass the complete table data
//       NavigationService.selectItem(tableInfo);
//
//       if (isOccupied && tableInfo.currentOrder != null) {
//         final order = tableInfo.currentOrder!;
//         SnackBarUtil.showInfo(
//           context,
//           'Table $tableNumber - Order #${order.orderId} (₹${order.totalAmount})',
//           title: 'Occupied Table',
//           duration: const Duration(seconds: 2),
//         );
//       } else if (isOccupied) {
//         SnackBarUtil.showInfo(
//           context,
//           'Table $tableNumber is occupied',
//           title: 'Table Info',
//           duration: const Duration(seconds: 1),
//         );
//       } else {
//         SnackBarUtil.showSuccess(
//           context,
//           'Table $tableNumber selected successfully',
//           title: 'Available Table',
//           duration: const Duration(seconds: 1),
//         );
//       }
//     } catch (e) {
//       developer.log(
//         'Error handling table tap: ${e.toString()}',
//         name: 'TakeOrders.Error',
//       );
//       SnackBarUtil.showError(
//         context,
//         'Failed to select table',
//         title: 'Error',
//         duration: const Duration(seconds: 1),
//       );
//     }
//   }
//
//   // Refresh tables data
//   Future<void> refreshTables() async {
//     await fetchTablesData();
//   }
//
//   // Get table by ID
//   TableInfo? getTableById(int tableId) {
//     try {
//       return allTables.firstWhere((table) => table.table.id == tableId);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // Get occupied tables count
//   int get occupiedTablesCount {
//     return allTables.where((t) => t.table.status == 'occupied').length;
//   }
//
//   // Get available tables count
//   int get availableTablesCount {
//     return allTables.where((t) => t.table.status == 'available').length;
//   }
//
//   // Get total revenue from current orders
//   int get totalRevenue {
//     return allTables.where((t) => t.currentOrder != null).fold<int>(
//         0, (sum, t) => sum + (t.currentOrder?.totalAmount?.round() ?? 0));
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../core/constants/api_constant.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/ResponseModel/table_model.dart';
import '../../../route/app_routes.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../service/socket_connection_manager.dart';

class TakeOrdersController extends GetxController {
  // Reactive variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Tables data
  final tableResponseModel = Rxn<TableResponseModel>();

  // Grouped tables by area
  final groupedTables = RxMap<String, List<TableInfo>>();

  // All tables list for quick access
  final allTables = <TableInfo>[].obs;

  // Socket connection manager
  final SocketConnectionManager _socketManager = SocketConnectionManager.instance;

  // Socket connection status
  final isSocketConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    developer.log('TakeOrdersController initialized', name: 'TakeOrders');

    // ✅ Setup socket listeners
    _setupSocketListeners();

    // Check socket connection status
    isSocketConnected.value = _socketManager.connectionStatus;

    // Fetch initial data
    fetchTablesData();
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('TakeOrdersController ready', name: 'TakeOrders');
  }

  @override
  void onClose() {
    // ✅ Remove socket listeners
    _removeSocketListeners();

    developer.log('TakeOrdersController disposed', name: 'TakeOrders');
    super.onClose();
  }

  /// ==================== SOCKET LISTENERS ====================

  /// Setup real-time socket event listeners
  void _setupSocketListeners() {
    developer.log('🔌 Setting up socket listeners', name: 'TakeOrders.Socket');

    // Listen for new orders (from OTHER users)
    _socketManager.socketService.on('new_order', _handleNewOrder);

    // Listen for order status updates (chef updates order)
    _socketManager.socketService.on('order_status_update', _handleOrderStatusUpdate);

    // Listen for payment updates
    _socketManager.socketService.on('payment_update', _handlePaymentUpdate);

    // Listen for table status changes
    _socketManager.socketService.on('table_status_update', _handleTableStatusUpdate);

    // Listen for order placement acknowledgment
    _socketManager.socketService.on('placeOrder_ack', _handleOrderPlaced);

    // Monitor socket connection status
    ever(_socketManager.isConnected, (connected) {
      isSocketConnected.value = connected;
      developer.log(
        'Socket connection status changed: $connected',
        name: 'TakeOrders.Socket',
      );

      if (Get.context != null) {
        SnackBarUtil.show(
          Get.context!,
          connected ? 'Real-time updates enabled' : 'Real-time updates disconnected',
          title: connected ? '✅ Connected' : '⚠️ Disconnected',
          type: connected ? SnackBarType.success : SnackBarType.warning,
          duration: const Duration(seconds: 2),
        );
      }
    });

    developer.log('✅ Socket listeners registered', name: 'TakeOrders.Socket');
  }

  /// Remove socket listeners on controller disposal
  void _removeSocketListeners() {
    developer.log('🔌 Removing socket listeners', name: 'TakeOrders.Socket');

    _socketManager.socketService.off('new_order', _handleNewOrder);
    _socketManager.socketService.off('order_status_update', _handleOrderStatusUpdate);
    _socketManager.socketService.off('payment_update', _handlePaymentUpdate);
    _socketManager.socketService.off('table_status_update', _handleTableStatusUpdate);
    _socketManager.socketService.off('placeOrder_ack', _handleOrderPlaced);

    developer.log('✅ Socket listeners removed', name: 'TakeOrders.Socket');
  }

  /// ==================== SOCKET EVENT HANDLERS ====================

  /// Handle new order event from socket (created by OTHER users)
  void _handleNewOrder(dynamic rawData) {
    try {
      // Convert to Map<String, dynamic>
      final data = rawData is Map ? Map<String, dynamic>.from(rawData) : {};

      developer.log(
        '🔔 NEW ORDER EVENT RECEIVED: $data',
        name: 'TakeOrders.Socket',
      );

      // Extract order details
      final orderData = data.containsKey('data')
          ? (data['data'] as Map?)
          : data;

      final orderId = orderData?['id'] ??
          orderData?['order_id'] ??
          orderData?['orderId'] ??
          0;
      final tableNumber = orderData?['table_number'] ??
          orderData?['tableNumber'] ??
          'Unknown';
      final message = data['message'] ??
          'New order received for Table $tableNumber';

      developer.log(
        '📋 Parsed: Order #$orderId, Table $tableNumber',
        name: 'TakeOrders.Socket',
      );

      // ✅ Auto-refresh tables to show new order
      refreshTables();

      // Show real-time notification
      if (Get.context != null) {
        SnackBarUtil.showSuccess(
          Get.context!,
          message,
          title: '🔔 New Order - Table $tableNumber',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error handling new order: $e',
        name: 'TakeOrders.Socket.Error',
      );
    }
  }

  /// Handle order status update event
  void _handleOrderStatusUpdate(dynamic rawData) {
    try {
      final data = rawData is Map ? Map<String, dynamic>.from(rawData) : {};

      developer.log(
        '📊 STATUS UPDATE EVENT RECEIVED: $data',
        name: 'TakeOrders.Socket',
      );

      final orderData = data.containsKey('data')
          ? (data['data'] as Map?)
          : data;

      final orderId = orderData?['orderId'] ??
          orderData?['order_id'] ??
          orderData?['id'] ??
          0;
      final newStatus = orderData?['status'] ?? 'unknown';
      final message = data['message'] ??
          'Order #$orderId status: $newStatus';

      developer.log(
        '📋 Parsed: Order #$orderId → Status: $newStatus',
        name: 'TakeOrders.Socket',
      );

      // ✅ Auto-refresh tables to show status change
      refreshTables();

      // Show notification
      if (Get.context != null) {
        SnackBarUtil.show(
          Get.context!,
          message,
          title: '📊 Order Status Update',
          type: SnackBarType.info,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error handling status update: $e',
        name: 'TakeOrders.Socket.Error',
      );
    }
  }

  /// Handle payment update event
  void _handlePaymentUpdate(dynamic rawData) {
    try {
      final data = rawData is Map ? Map<String, dynamic>.from(rawData) : {};

      developer.log(
        '💰 PAYMENT UPDATE EVENT RECEIVED: $data',
        name: 'TakeOrders.Socket',
      );

      final message = data['message'] ?? 'Payment completed';
      final orderData = data.containsKey('data') ? data['data'] : data;
      final orderId = orderData?['orderId'] ?? orderData?['order_id'] ?? 0;

      developer.log(
        '📋 Parsed: Order #$orderId payment updated',
        name: 'TakeOrders.Socket',
      );

      // ✅ Auto-refresh tables
      refreshTables();

      // Show notification
      if (Get.context != null) {
        SnackBarUtil.showSuccess(
          Get.context!,
          message,
          title: '💰 Payment Received',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error handling payment update: $e',
        name: 'TakeOrders.Socket.Error',
      );
    }
  }

  /// Handle table status update event
  void _handleTableStatusUpdate(dynamic rawData) {
    try {
      final data = rawData is Map ? Map<String, dynamic>.from(rawData) : {};

      developer.log(
        '📋 TABLE STATUS UPDATE EVENT RECEIVED: $data',
        name: 'TakeOrders.Socket',
      );

      // ✅ Auto-refresh tables
      refreshTables();

      final message = data['message'] ?? 'Table status updated';

      // Show notification
      if (Get.context != null) {
        SnackBarUtil.show(
          Get.context!,
          message,
          title: '📋 Table Update',
          type: SnackBarType.info,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error handling table status update: $e',
        name: 'TakeOrders.Socket.Error',
      );
    }
  }

  /// Handle order placement acknowledgment
  void _handleOrderPlaced(dynamic rawData) {
    try {
      final data = rawData is Map ? Map<String, dynamic>.from(rawData) : {};

      developer.log(
        '✅ ORDER PLACED ACK RECEIVED: $data',
        name: 'TakeOrders.Socket',
      );

      // ✅ Auto-refresh tables
      refreshTables();
    } catch (e) {
      developer.log(
        '❌ Error handling order placement: $e',
        name: 'TakeOrders.Socket.Error',
      );
    }
  }

  /// ==================== API METHODS ====================

  // Fetch tables data from API
  Future<void> fetchTablesData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      developer.log('Fetching tables data from API', name: 'TakeOrders');

      final apiResponse = await ApiService.get<TableResponseModel>(
        endpoint: ApiConstants.waiterGetTable,
        fromJson: (json) => TableResponseModel.fromJson(json),
        includeToken: true,
      );

      if (apiResponse != null && apiResponse.data != null) {
        final response = apiResponse.data!;

        if (response.success && response.data != null) {
          tableResponseModel.value = response;
          allTables.value = response.data!.tables;
          _groupTablesByArea(response.data!.tables);

          developer.log(
            'Tables data loaded successfully: ${allTables.length} tables',
            name: 'TakeOrders',
          );
        } else {
          errorMessage.value = response.message.isNotEmpty
              ? response.message
              : 'Failed to load tables';
          developer.log(
            'Failed to load tables: ${errorMessage.value}',
            name: 'TakeOrders.Error',
          );
        }
      } else {
        errorMessage.value = 'Failed to load tables data';
        developer.log(
          'API response is null',
          name: 'TakeOrders.Error',
        );
      }
    } catch (e) {
      errorMessage.value = 'Error loading tables: ${e.toString()}';
      developer.log(
        'Error fetching tables data: ${e.toString()}',
        name: 'TakeOrders.Error',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Group tables by area name
  void _groupTablesByArea(List<TableInfo> tables) {
    groupedTables.clear();

    for (var tableInfo in tables) {
      if (!groupedTables.containsKey(tableInfo.areaName)) {
        groupedTables[tableInfo.areaName] = [];
      }
      groupedTables[tableInfo.areaName]!.add(tableInfo);
    }

    developer.log(
      'Tables grouped into ${groupedTables.length} areas',
      name: 'TakeOrders',
    );
  }

  // Get tables for a specific area
  List<TableInfo> getTablesForArea(String areaName) {
    return groupedTables[areaName] ?? [];
  }

  // Calculate time elapsed since order creation (in minutes)
  int calculateElapsedTime(String createdAt) {
    try {
      final orderTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(orderTime);
      return difference.inMinutes;
    } catch (e) {
      developer.log(
        'Error calculating elapsed time: ${e.toString()}',
        name: 'TakeOrders.Error',
      );
      return 0;
    }
  }

  // Handle table selection
  void handleTableTap(TableInfo tableInfo, BuildContext context) {
    try {
      final tableNumber = tableInfo.table.tableNumber;
      final isOccupied = tableInfo.table.status == 'occupied';

      developer.log(
        'Table tapped: Table $tableNumber (ID: ${tableInfo.table.id}), Status: ${tableInfo.table.status}',
        name: 'TakeOrders',
      );

      // Pass the complete table data
      NavigationService.selectItem(tableInfo);

      if (isOccupied && tableInfo.currentOrder != null) {
        final order = tableInfo.currentOrder!;
        SnackBarUtil.showInfo(
          context,
          'Table $tableNumber - Order #${order.orderId} (₹${order.totalAmount})',
          title: 'Occupied Table',
          duration: const Duration(seconds: 2),
        );
      } else if (isOccupied) {
        SnackBarUtil.showInfo(
          context,
          'Table $tableNumber is occupied',
          title: 'Table Info',
          duration: const Duration(seconds: 1),
        );
      } else {
        SnackBarUtil.showSuccess(
          context,
          'Table $tableNumber selected successfully',
          title: 'Available Table',
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      developer.log(
        'Error handling table tap: ${e.toString()}',
        name: 'TakeOrders.Error',
      );
      SnackBarUtil.showError(
        context,
        'Failed to select table',
        title: 'Error',
        duration: const Duration(seconds: 1),
      );
    }
  }

  // Refresh tables data
  Future<void> refreshTables() async {
    developer.log('♻️ Refreshing tables data', name: 'TakeOrders');
    await fetchTablesData();
  }

  // Get table by ID
  TableInfo? getTableById(int tableId) {
    try {
      return allTables.firstWhere((table) => table.table.id == tableId);
    } catch (e) {
      return null;
    }
  }

  // Get occupied tables count
  int get occupiedTablesCount {
    return allTables.where((t) => t.table.status == 'occupied').length;
  }

  // Get available tables count
  int get availableTablesCount {
    return allTables.where((t) => t.table.status == 'available').length;
  }

  // Get total revenue from current orders
  int get totalRevenue {
    return allTables.where((t) => t.currentOrder != null).fold<int>(
        0, (sum, t) => sum + (t.currentOrder?.totalAmount?.round() ?? 0));
  }

  /// ==================== SOCKET UTILITY METHODS ====================

  /// Get socket connection status
  bool get socketConnected => isSocketConnected.value;

  /// Get socket connection info for debugging
  Map<String, dynamic> getSocketInfo() {
    return _socketManager.getConnectionInfo();
  }


}

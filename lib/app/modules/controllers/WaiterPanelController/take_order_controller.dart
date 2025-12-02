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

import 'package:flutter/material.dart' hide Table;
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'dart:async';
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
  final tableResponseModel = Rxn<TableResponseModel>();
  final groupedTables = RxMap<String, List<TableInfo>>();
  final allTables = <TableInfo>[].obs;
  final isSocketConnected = false.obs;

  // Socket & debounce
  final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
  Timer? _refreshDebounceTimer;
  final _refreshDebounceDelay = const Duration(milliseconds: 500);
  bool _isRefreshing = false;
  final Set<String> _processedEvents = {};

  @override
  void onInit() {
    super.onInit();
    developer.log('TakeOrdersController initialized', name: 'TakeOrders');
    _setupSocketListeners();
    isSocketConnected.value = _socketManager.connectionStatus;
    fetchTablesData();
  }

  @override
  void onClose() {
    _refreshDebounceTimer?.cancel();
    _removeSocketListeners();
    developer.log('TakeOrdersController disposed', name: 'TakeOrders');
    super.onClose();
  }

  /// ==================== SOCKET SETUP ====================

  void _setupSocketListeners() {
    developer.log('🔌 Setting up socket listeners', name: 'TakeOrders.Socket');
    _removeSocketListeners();

    // Map event names to handlers
    final eventHandlers = {
      'new_order': _handleNewOrder,
      'order_status_update': _handleGenericUpdate,
      'payment_update': _handlePaymentUpdate,
      'table_status_update': _handleGenericUpdate,
      'placeOrder_ack': _handleGenericUpdate,
      'order_completed': _handleGenericUpdate,
      'payment_completed': _handleTableFreed,
      'table_cleared': _handleTableFreed,
      'table_freed': _handleTableFreed,
    };

    // Register all handlers
    eventHandlers.forEach((event, handler) {
      _socketManager.socketService.on(event, handler);
    });

    // Monitor connection status
    ever(_socketManager.isConnected, _onSocketConnectionChanged);

    developer.log('✅ Socket listeners registered', name: 'TakeOrders.Socket');
  }

  void _removeSocketListeners() {
    final events = [
      'new_order', 'order_status_update', 'payment_update',
      'table_status_update', 'placeOrder_ack', 'order_completed',
      'payment_completed', 'table_cleared', 'table_freed'
    ];
    events.forEach(_socketManager.socketService.off);
    developer.log('✅ Socket listeners removed', name: 'TakeOrders.Socket');
  }

  void _onSocketConnectionChanged(bool connected) {
    isSocketConnected.value = connected;
    developer.log('Socket connection: $connected', name: 'TakeOrders.Socket');

    if (Get.context != null) {
      SnackBarUtil.show(
        Get.context!,
        connected ? 'Real-time updates enabled' : 'Real-time updates disconnected',
        title: connected ? '✅ Connected' : '⚠️ Disconnected',
        type: connected ? SnackBarType.success : SnackBarType.warning,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// ==================== SOCKET EVENT HANDLERS ====================

  void _handleNewOrder(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('🔔 NEW ORDER EVENT', name: 'TakeOrders.Socket');

    // Check for duplicates
    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
    final eventId = '$orderId-$timestamp';

    if (_isDuplicateEvent(eventId)) return;

    final tableNumber = _extractTableNumber(orderData);
    final message = data['message'] ?? 'New order received for Table $tableNumber';

    developer.log('📋 Order #$orderId, Table $tableNumber', name: 'TakeOrders.Socket');
    _debouncedRefreshTables();

    if (Get.context != null && orderId > 0) {
      SnackBarUtil.showSuccess(
        Get.context!,
        message,
        title: '🔔 New Order - Table $tableNumber',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _handlePaymentUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('💰 PAYMENT UPDATE EVENT', name: 'TakeOrders.Socket');

    final orderData = data['data'] ?? data;
    final tableId = _extractTableId(orderData);
    final message = data['message'] ?? 'Payment completed';

    _debouncedRefreshTables();

    // Optimistic update
    if (tableId != null) {
      _updateLocalTableStatus(tableId, 'available');
    }

    if (Get.context != null) {
      SnackBarUtil.showSuccess(
        Get.context!,
        message,
        title: '💰 Payment Received',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _handleTableFreed(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    final eventType = _getEventType(rawData);
    developer.log('$eventType EVENT', name: 'TakeOrders.Socket');

    final tableData = data['data'] ?? data;
    final tableId = _extractTableId(tableData);
    final tableNumber = _extractTableNumber(tableData);

    _debouncedRefreshTables();

    // Optimistic update
    if (tableId != null) {
      _updateLocalTableStatus(tableId, 'available');
    }

    if (Get.context != null) {
      final icons = {'payment_completed': '💰', 'table_cleared': '🧹', 'table_freed': '🆓'};
      final icon = icons[eventType] ?? '✅';

      SnackBarUtil.showSuccess(
        Get.context!,
        'Table $tableNumber is now available',
        title: '$icon Table Available',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _handleGenericUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('📊 Generic update event', name: 'TakeOrders.Socket');
    _debouncedRefreshTables();

    if (Get.context != null && data['message'] != null) {
      SnackBarUtil.show(
        Get.context!,
        data['message'],
        title: '📊 Update',
        type: SnackBarType.info,
        duration: const Duration(seconds: 1),
      );
    }
  }

  /// ==================== HELPER METHODS ====================

  Map<String, dynamic>? _parseSocketData(dynamic rawData) {
    try {
      return rawData is Map ? Map<String, dynamic>.from(rawData) : {};
    } catch (e) {
      developer.log('❌ Parse error: $e', name: 'TakeOrders.Socket.Error');
      return null;
    }
  }

  bool _isDuplicateEvent(String eventId) {
    if (_processedEvents.contains(eventId)) {
      developer.log('⏭️ SKIPPING duplicate: $eventId', name: 'TakeOrders.Socket');
      return true;
    }
    _processedEvents.add(eventId);
    if (_processedEvents.length > 50) _processedEvents.clear();
    return false;
  }

  int _extractOrderId(Map<String, dynamic>? data) {
    return data?['id'] ?? data?['order_id'] ?? data?['orderId'] ?? 0;
  }

  int? _extractTableId(Map<String, dynamic>? data) {
    return data?['tableId'] ?? data?['table_id'] ?? data?['hotel_table_id'];
  }

  String _extractTableNumber(Map<String, dynamic>? data) {
    return data?['table_number']?.toString() ??
        data?['tableNumber']?.toString() ??
        'Unknown';
  }

  String _getEventType(dynamic rawData) {
    if (rawData is Map && rawData.containsKey('event')) {
      return rawData['event'];
    }
    return '📊 UPDATE';
  }

  void _updateLocalTableStatus(int tableId, String newStatus) {
    try {
      final tableIndex = allTables.indexWhere((t) => t.table.id == tableId);
      if (tableIndex == -1) {
        developer.log('⚠️ Table #$tableId not found', name: 'TakeOrders.Socket');
        return;
      }

      final tableInfo = allTables[tableIndex];
      final updatedTable = Table(
        id: tableInfo.table.id,
        hotelOwnerId: tableInfo.table.hotelOwnerId,
        tableAreaId: tableInfo.table.tableAreaId,
        tableNumber: tableInfo.table.tableNumber,
        tableType: tableInfo.table.tableType,
        capacity: tableInfo.table.capacity,
        status: newStatus,
        description: tableInfo.table.description,
        location: tableInfo.table.location,
        createdAt: tableInfo.table.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      allTables[tableIndex] = TableInfo(
        table: updatedTable,
        currentOrder: newStatus == 'available' ? null : tableInfo.currentOrder,
        areaName: tableInfo.areaName,
      );

      _groupTablesByArea(allTables);
      developer.log('✅ Table #$tableId → $newStatus', name: 'TakeOrders.Socket');
    } catch (e, stackTrace) {
      developer.log('❌ Update error: $e\n$stackTrace', name: 'TakeOrders.Socket.Error');
    }
  }

  void _debouncedRefreshTables() {
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
      if (!_isRefreshing) {
        developer.log('⏰ Refreshing tables', name: 'TakeOrders');
        fetchTablesData();
      }
    });
  }

  /// ==================== API METHODS ====================

  Future<void> fetchTablesData() async {
    if (_isRefreshing) {
      developer.log('⏭️ Already refreshing', name: 'TakeOrders');
      return;
    }

    try {
      _isRefreshing = true;
      isLoading.value = true;
      errorMessage.value = '';

      final apiResponse = await ApiService.get<TableResponseModel>(
        endpoint: ApiConstants.waiterGetTable,
        fromJson: (json) => TableResponseModel.fromJson(json),
        includeToken: true,
      );

      if (apiResponse?.data != null) {
        final response = apiResponse!.data!;
        if (response.success && response.data != null) {
          tableResponseModel.value = response;
          allTables.value = response.data!.tables;
          _groupTablesByArea(response.data!.tables);
          developer.log('✅ ${allTables.length} tables loaded', name: 'TakeOrders');
        } else {
          errorMessage.value = response.message.isNotEmpty ? response.message : 'Failed to load tables';
        }
      } else {
        errorMessage.value = 'Failed to load tables data';
      }
    } catch (e) {
      errorMessage.value = 'Error loading tables: ${e.toString()}';
      developer.log('❌ Fetch error: $e', name: 'TakeOrders.Error');
    } finally {
      isLoading.value = false;
      _isRefreshing = false;
    }
  }

  void _groupTablesByArea(List<TableInfo> tables) {
    groupedTables.clear();
    for (var tableInfo in tables) {
      groupedTables.putIfAbsent(tableInfo.areaName, () => []).add(tableInfo);
    }
    developer.log('Tables grouped into ${groupedTables.length} areas', name: 'TakeOrders');
  }

  /// ==================== PUBLIC METHODS ====================

  List<TableInfo> getTablesForArea(String areaName) => groupedTables[areaName] ?? [];

  TableInfo? getTableById(int tableId) {
    try {
      return allTables.firstWhere((table) => table.table.id == tableId);
    } catch (e) {
      return null;
    }
  }

  int calculateElapsedTime(String createdAt) {
    try {
      final orderTime = DateTime.parse(createdAt);
      return DateTime.now().difference(orderTime).inMinutes;
    } catch (e) {
      developer.log('❌ Elapsed time error: $e', name: 'TakeOrders.Error');
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

  Future<void> refreshTables() async {
    developer.log('♻️ Manual refresh', name: 'TakeOrders');
    await fetchTablesData();
  }

  // Getters
  int get occupiedTablesCount => allTables.where((t) => t.table.status == 'occupied').length;
  int get availableTablesCount => allTables.where((t) => t.table.status == 'available').length;
  int get totalRevenue => allTables
      .where((t) => t.currentOrder != null)
      .fold<int>(0, (sum, t) => sum + (t.currentOrder?.totalAmount?.round() ?? 0));
  bool get socketConnected => isSocketConnected.value;
  Map<String, dynamic> getSocketInfo() => _socketManager.getConnectionInfo();
}
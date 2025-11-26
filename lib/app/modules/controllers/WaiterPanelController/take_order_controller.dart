// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:developer' as developer;
// import '../../../route/app_routes.dart';
// import '../../../core/utils/snakbar_utils.dart';
//
// class TakeOrdersController extends GetxController {
//   // Reactive variables
//   final isLoading = false.obs;
//   final errorMessage = ''.obs;
//
//   // Tables data - storing directly in Map for now
//   final tablesData = Rxn<Map<String, dynamic>>();
//
//   // Common area tables list
//   final commonAreaTables = <Map<String, dynamic>>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('TakeOrdersController initialized', name: 'TakeOrders');
//     _initializeTablesData();
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
//   void _initializeTablesData() {
//     try {
//       developer.log('Initializing tables data', name: 'TakeOrders');
//
//       // Fixed mock data - each table now has unique tableNumber and id
//       final mockTables = [
//         {
//           'id': 1,
//           'tableNumber': 1, // Table 1
//           'price': 0,
//           'time': 10,
//           'isOccupied': false, // red color
//         },
//         {
//           'id': 2,
//           'tableNumber': 2, // Table 2 - now unique
//           'price': 0,
//           'time': 0,
//           'isOccupied': false, // green color
//         },
//         {
//           'id': 3,
//           'tableNumber': 3, // Table 3 - now unique
//           'price': 0,
//           'time': 15,
//           'isOccupied': false, // red color
//         },
//         {
//           'id': 4,
//           'tableNumber': 4, // Table 4 - now unique
//           'price': 0,
//           'time': 5,
//           'isOccupied': false, // red color
//         },
//         {
//           'id': 5,
//           'tableNumber': 5, // Table 5 - now unique
//           'price': 0,
//           'time': 20,
//           'isOccupied': false, // red color
//         },
//         {
//           'id': 6,
//           'tableNumber': 6, // Table 6 - now unique
//           'price': 0,
//           'time': 0,
//           'isOccupied': false, // green color - available
//         },
//         {
//           'id': 7,
//           'tableNumber': 7, // Table 7 - now unique
//           'price': 0,
//           'time': 25,
//           'isOccupied': false, // red color
//         },
//         {
//           'id': 8,
//           'tableNumber': 8, // Table 8 - now unique
//           'price': 0,
//           'time': 0,
//           'isOccupied': false, // green color - available
//         },
//         {
//           'id': 9,
//           'tableNumber': 9, // Table 9 - now unique
//           'price': 0,
//           'time': 12,
//           'isOccupied': false, // red color
//         },
//         {
//           'id': 10,
//           'tableNumber': 10, // Table 10 - now unique
//           'price': 0,
//           'time': 8,
//           'isOccupied': false, // red color
//         },
//       ];
//
//       commonAreaTables.value = mockTables;
//
//       tablesData.value = {
//         'commonArea': {
//           'title': 'Common area',
//           'tables': mockTables,
//         }
//       };
//
//       developer.log('Tables data initialized with ${mockTables.length} tables',
//           name: 'TakeOrders');
//     } catch (e) {
//       developer.log('Error initializing tables data: ${e.toString()}',
//           name: 'TakeOrders.Error');
//       errorMessage.value = 'Failed to load tables data';
//     }
//   }
//
//   // Handle table selection - now uses unique table ID for proper identification
//   void handleTableTap(int index, BuildContext context) {
//     try {
//       final table = commonAreaTables[index];
//       final tableId = table['id'];
//       final tableNumber = table['tableNumber'];
//
//       developer.log(
//           'Table tapped: Table $tableNumber (ID: $tableId), Index: $index',
//           name: 'TakeOrders');
//
//       // Pass the complete table data including unique ID
//       NavigationService.selectItem(table);
//
//       if (table['isOccupied']) {
//         SnackBarUtil.showInfo(
//           context,
//           'Table $tableNumber is occupied (₹${table['price']})',
//           title: 'Table Info',
//           duration: const Duration(seconds: 1),
//         );
//       } else {
//         SnackBarUtil.showSuccess(
//           context,
//           'Table $tableNumber selected successfully',
//           title: 'Table Selected',
//           duration: const Duration(seconds: 1),
//         );
//         // Navigate to order details with unique table data
//       }
//     } catch (e) {
//       developer.log('Error handling table tap: ${e.toString()}',
//           name: 'TakeOrders.Error');
//       SnackBarUtil.showError(
//         context,
//         'Failed to select table',
//         title: 'Error',
//         duration: const Duration(seconds: 1),
//       );
//     }
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

  @override
  void onInit() {
    super.onInit();
    developer.log('TakeOrdersController initialized', name: 'TakeOrders');
    fetchTablesData();
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('TakeOrdersController ready', name: 'TakeOrders');
  }

  @override
  void onClose() {
    super.onClose();
    developer.log('TakeOrdersController disposed', name: 'TakeOrders');
  }

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
    return allTables
        .where((t) => t.currentOrder != null)
        .fold<int>(0, (sum, t) => sum + (t.currentOrder?.totalAmount?.round() ?? 0));
  }
}
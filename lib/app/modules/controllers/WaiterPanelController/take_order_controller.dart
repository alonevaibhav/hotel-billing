import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../route/app_routes.dart';
import '../../../core/utils/snakbar_utils.dart';

class TakeOrdersController extends GetxController {
  // Reactive variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Tables data - storing directly in Map for now
  final tablesData = Rxn<Map<String, dynamic>>();

  // Common area tables list
  final commonAreaTables = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    developer.log('TakeOrdersController initialized', name: 'TakeOrders');
    _initializeTablesData();
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

  void _initializeTablesData() {
    try {
      developer.log('Initializing tables data', name: 'TakeOrders');

      // Fixed mock data - each table now has unique tableNumber and id
      final mockTables = [
        {
          'id': 1,
          'tableNumber': 1, // Table 1
          'price': 0,
          'time': 10,
          'isOccupied': false, // red color
        },
        {
          'id': 2,
          'tableNumber': 2, // Table 2 - now unique
          'price': 0,
          'time': 0,
          'isOccupied': false, // green color
        },
        {
          'id': 3,
          'tableNumber': 3, // Table 3 - now unique
          'price': 0,
          'time': 15,
          'isOccupied': false, // red color
        },
        {
          'id': 4,
          'tableNumber': 4, // Table 4 - now unique
          'price': 0,
          'time': 5,
          'isOccupied': false, // red color
        },
        {
          'id': 5,
          'tableNumber': 5, // Table 5 - now unique
          'price': 0,
          'time': 20,
          'isOccupied': false, // red color
        },
        {
          'id': 6,
          'tableNumber': 6, // Table 6 - now unique
          'price': 0,
          'time': 0,
          'isOccupied': false, // green color - available
        },
        {
          'id': 7,
          'tableNumber': 7, // Table 7 - now unique
          'price': 0,
          'time': 25,
          'isOccupied': false, // red color
        },
        {
          'id': 8,
          'tableNumber': 8, // Table 8 - now unique
          'price': 0,
          'time': 0,
          'isOccupied': false, // green color - available
        },
        {
          'id': 9,
          'tableNumber': 9, // Table 9 - now unique
          'price': 0,
          'time': 12,
          'isOccupied': false, // red color
        },
        {
          'id': 10,
          'tableNumber': 10, // Table 10 - now unique
          'price': 0,
          'time': 8,
          'isOccupied': false, // red color
        },
      ];

      commonAreaTables.value = mockTables;

      tablesData.value = {
        'commonArea': {
          'title': 'Common area',
          'tables': mockTables,
        }
      };

      developer.log('Tables data initialized with ${mockTables.length} tables',
          name: 'TakeOrders');
    } catch (e) {
      developer.log('Error initializing tables data: ${e.toString()}',
          name: 'TakeOrders.Error');
      errorMessage.value = 'Failed to load tables data';
    }
  }

  // Handle table selection - now uses unique table ID for proper identification
  void handleTableTap(int index, BuildContext context) {
    try {
      final table = commonAreaTables[index];
      final tableId = table['id'];
      final tableNumber = table['tableNumber'];

      developer.log(
          'Table tapped: Table $tableNumber (ID: $tableId), Index: $index',
          name: 'TakeOrders');

      // Pass the complete table data including unique ID
      NavigationService.selectItem(table);

      if (table['isOccupied']) {
        SnackBarUtil.showInfo(
          context,
          'Table $tableNumber is occupied (₹${table['price']})',
          title: 'Table Info',
          duration: const Duration(seconds: 1),
        );
      } else {
        SnackBarUtil.showSuccess(
          context,
          'Table $tableNumber selected successfully',
          title: 'Table Selected',
          duration: const Duration(seconds: 1),
        );
        // Navigate to order details with unique table data
      }
    } catch (e) {
      developer.log('Error handling table tap: ${e.toString()}',
          name: 'TakeOrders.Error');
      SnackBarUtil.showError(
        context,
        'Failed to select table',
        title: 'Error',
        duration: const Duration(seconds: 1),
      );
    }
  }

  // Method to update specific table data
  void updateTableData(int tableId, Map<String, dynamic> updates) {
    try {
      final index =
          commonAreaTables.indexWhere((table) => table['id'] == tableId);
      if (index != -1) {
        // Create a new map with updated data
        final updatedTable = Map<String, dynamic>.from(commonAreaTables[index]);
        updatedTable.addAll(updates);

        // Update the table in the list
        commonAreaTables[index] = updatedTable;

        developer.log('Table $tableId updated successfully',
            name: 'TakeOrders');
      }
    } catch (e) {
      developer.log('Error updating table data: ${e.toString()}',
          name: 'TakeOrders.Error');
    }
  }

  // Method to get specific table by ID
  Map<String, dynamic>? getTableById(int tableId) {
    try {
      return commonAreaTables.firstWhere((table) => table['id'] == tableId);
    } catch (e) {
      developer.log('Table with ID $tableId not found',
          name: 'TakeOrders.Error');
      return null;
    }
  }

  // Method to mark table as occupied/available
  void updateTableOccupancy(int tableId, bool isOccupied,
      {double? price, int? time}) {
    try {
      final updates = <String, dynamic>{
        'isOccupied': isOccupied,
      };

      if (price != null) updates['price'] = price;
      if (time != null) updates['time'] = time;

      updateTableData(tableId, updates);
      developer.log('Table $tableId occupancy updated: $isOccupied',
          name: 'TakeOrders');
    } catch (e) {
      developer.log('Error updating table occupancy: ${e.toString()}',
          name: 'TakeOrders.Error');
    }
  }

  // Refresh tables data
  Future<void> refreshTables( context) async {
    try {
      isLoading.value = true;
      developer.log('Refreshing tables data', name: 'TakeOrders');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Re-initialize data (in real app, this would be API call)
      _initializeTablesData();

      developer.log('Tables data refreshed successfully', name: 'TakeOrders');
    } catch (e) {
      developer.log('Error refreshing tables: ${e.toString()}',
          name: 'TakeOrders.Error');
      errorMessage.value = 'Failed to refresh tables';
      SnackBarUtil.showError(
        context,
        'Failed to refresh tables',
        title: 'Error',
        duration: const Duration(seconds: 1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get available tables count
  int get availableTablesCount {
    return commonAreaTables.where((table) => !table['isOccupied']).length;
  }

  // Get occupied tables count
  int get occupiedTablesCount {
    return commonAreaTables.where((table) => table['isOccupied']).length;
  }

  // Get total revenue from occupied tables
  double get totalRevenue {
    return commonAreaTables
        .where((table) => table['isOccupied'])
        .fold(0.0, (sum, table) => sum + (table['price'] ?? 0));
  }
}

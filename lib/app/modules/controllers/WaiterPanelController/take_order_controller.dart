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
}

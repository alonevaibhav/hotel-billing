// lib/features/take_orders/controllers/take_orders_controller.dart
import 'package:get/get.dart';
import 'dart:developer' as developer;

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

      // Mock data based on the screenshot
      final mockTables = [
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
        {
          'tableNumber': 1,
          'price': 0,
          'time': 10,
          'isOccupied': false, // green color
        },
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
        {
          'tableNumber': 1,
          'price': 3500,
          'time': 10,
          'isOccupied': true, // red color
        },
      ];

      commonAreaTables.value = mockTables;

      tablesData.value = {
        'commonArea': {
          'title': 'Common area',
          'tables': mockTables,
        }
      };

      developer.log('Tables data initialized with ${mockTables.length} tables', name: 'TakeOrders');
    } catch (e) {
      developer.log('Error initializing tables data: ${e.toString()}', name: 'TakeOrders.Error');
      errorMessage.value = 'Failed to load tables data';
    }
  }

  // Handle table selection
  void handleTableTap(int index) {
    try {
      final table = commonAreaTables[index];
      developer.log('Table tapped: Table ${table['tableNumber']}, Index: $index', name: 'TakeOrders');

      if (table['isOccupied']) {
        Get.snackbar('Info', 'Table ${table['tableNumber']} is occupied');
      } else {
        Get.snackbar('Info', 'Table ${table['tableNumber']} selected');
        // Here you can navigate to order details or show menu
      }
    } catch (e) {
      developer.log('Error handling table tap: ${e.toString()}', name: 'TakeOrders.Error');
      Get.snackbar('Error', 'Failed to select table');
    }
  }

  // Refresh tables data
  Future<void> refreshTables() async {
    try {
      isLoading.value = true;
      developer.log('Refreshing tables data', name: 'TakeOrders');

      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      // Re-initialize data (in real app, this would be API call)
      _initializeTablesData();

      developer.log('Tables data refreshed successfully', name: 'TakeOrders');
    } catch (e) {
      developer.log('Error refreshing tables: ${e.toString()}', name: 'TakeOrders.Error');
      errorMessage.value = 'Failed to refresh tables';
      Get.snackbar('Error', 'Failed to refresh tables');
    } finally {
      isLoading.value = false;
    }
  }
}
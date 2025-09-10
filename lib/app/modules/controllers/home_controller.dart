
// lib/features/restaurant/controllers/restaurant_controller.dart
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../../route/app_routes.dart';

class RestaurantController extends GetxController {
  // Reactive variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isDrawerOpen = false.obs;

  // Restaurant data
  final restaurantData = Rxn<Map<String, dynamic>>();

  // Hotel information
  final hotelName = 'Alpani Hotel'.obs;
  final hotelAddress = '2672 Westheimer Rd. Santa Ana, Illinois 85486'.obs;
  final phoneNumber = 'Tel: (406) 555-0120'.obs;

  // Selection states
  final selectedMainButton = 'take_orders'.obs; // 'take_orders' or 'ready_orders'
  final selectedSidebarItem = 'RESTAURANT'.obs; // 'RESTAURANT', 'NOTIFICATION', 'HISTORY', 'SETTINGS'

  @override
  void onInit() {
    super.onInit();
    developer.log('RestaurantController initialized', name: 'Restaurant');
    _initializeData();
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('RestaurantController ready', name: 'Restaurant');
  }

  @override
  void onClose() {
    super.onClose();
    developer.log('RestaurantController disposed', name: 'Restaurant');
  }

  void _initializeData() {
    // Initialize restaurant basic data
    restaurantData.value = {
      'name': hotelName.value,
      'address': hotelAddress.value,
      'phone': phoneNumber.value,
    };
    developer.log('Restaurant data initialized', name: 'Restaurant');
  }

  // Header actions
  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
    developer.log('Drawer toggled: ${isDrawerOpen.value}', name: 'Restaurant');
  }

  void handleLogout() {
    developer.log('Logout button pressed', name: 'Restaurant');
  }

  // Sidebar navigation
  void handleNotification() {
    selectedSidebarItem.value = 'NOTIFICATION';
    developer.log('Notification menu pressed', name: 'Restaurant');
    Get.snackbar('Info', 'Notifications feature will be implemented');
  }

  void handleHistory() {
    selectedSidebarItem.value = 'HISTORY';
    developer.log('History menu pressed', name: 'Restaurant');
    Get.snackbar('Info', 'History feature will be implemented');
  }

  void handleSettings() {
    selectedSidebarItem.value = 'SETTINGS';
    developer.log('Settings menu pressed', name: 'Restaurant');
    Get.snackbar('Info', 'Settings feature will be implemented');
  }

  void handleRestaurant() {
    selectedSidebarItem.value = 'RESTAURANT';
    developer.log('Restaurant menu pressed', name: 'Restaurant');
  }

  // Main action buttons
  void handleTakeOrders() {
    selectedMainButton.value = 'take_orders';

    NavigationService.goToTakeOrders();
  }

  void handleReadyOrders() {
    selectedMainButton.value = 'ready_orders';
    developer.log('Ready Orders button pressed', name: 'Restaurant');
    NavigationService.goToReadyOrders();

  }
}
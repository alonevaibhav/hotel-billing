//
// import 'package:get/get.dart';
// import 'dart:developer' as developer;
// import '../../route/app_routes.dart';
// import '../auth/login_view_controller.dart';
//
// class WaiterDrawerController extends GetxController {
//   // Reactive variables
//   final isLoading = false.obs;
//   final errorMessage = ''.obs;
//   final isDrawerOpen = false.obs;
//
//   // Restaurant data
//   final restaurantData = Rxn<Map<String, dynamic>>();
//
//
//
//   // Hotel information
//   final hotelName = 'Alpani Hotel'.obs;
//   final hotelAddress = '2672 Westheimer Rd. Santa Ana, Illinois 85486'.obs;
//   final phoneNumber = 'Tel: (406) 555-0120'.obs;
//
//   // Selection states
//   final selectedMainButton = 'take_orders'.obs; // 'take_orders' or 'ready_orders'
//   final selectedSidebarItem = 'RESTAURANT'.obs; // 'RESTAURANT', 'NOTIFICATION', 'HISTORY', 'SETTINGS'
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('RestaurantController initialized', name: 'Restaurant');
//     _initializeData();
//   }
//
//   @override
//   void onReady() {
//     super.onReady();
//     developer.log('RestaurantController ready', name: 'Restaurant');
//   }
//
//   @override
//   void onClose() {
//     super.onClose();
//     developer.log('RestaurantController disposed', name: 'Restaurant');
//   }
//
//   void _initializeData() {
//     // Initialize restaurant basic data
//     restaurantData.value = {
//       'name': hotelName.value,
//       'address': hotelAddress.value,
//       'phone': phoneNumber.value,
//     };
//     developer.log('Restaurant data initialized', name: 'Restaurant');
//   }
//
//   // Header actions
//   void toggleDrawer() {
//     isDrawerOpen.value = !isDrawerOpen.value;
//     developer.log('Drawer toggled: ${isDrawerOpen.value}', name: 'Restaurant');
//   }
//   void handleLogout() {
//     developer.log('Logout button pressed', name: 'Restaurant');
//
//     final loginController = Get.find<LoginViewController>();
//     loginController.logout();
//   }
//
//
//   // Sidebar navigation
//   void handleNotification() {
//     selectedSidebarItem.value = 'NOTIFICATION';
//     developer.log('Notification menu pressed', name: 'Restaurant');
//     Get.snackbar('Info', 'Notifications feature will be implemented');
//
//     NavigationService.pushToWaiterNotification();
//   }
//
//   void handleHistory() {
//     selectedSidebarItem.value = 'HISTORY';
//     developer.log('History menu pressed', name: 'Restaurant');
//     NavigationService.pushToWaiterHistory();
//   }
//
//   void handleSettings() {
//     selectedSidebarItem.value = 'SETTINGS';
//     developer.log('Settings menu pressed', name: 'Restaurant');
//     Get.snackbar('Info', 'Settings feature will be implemented');
//   }
//
//   void handleRestaurant() {
//     selectedSidebarItem.value = 'RESTAURANT';
//     developer.log('Restaurant menu pressed', name: 'Restaurant');
//   }
//
//   // Main action buttons - Fixed navigation methods
//   void handleTakeOrders() {
//     selectedMainButton.value = 'take_orders';
//   }
//
//   void handleReadyOrders() {
//     selectedMainButton.value = 'ready_orders';
//   }
//
//   // Additional utility methods
//   void refreshData() {
//     isLoading.value = true;
//     // Simulate loading
//     Future.delayed(const Duration(seconds: 2), () {
//       _initializeData();
//       isLoading.value = false;
//       Get.snackbar('Success', 'Data refreshed successfully');
//     });
//   }
//
//   void showError(String message) {
//     errorMessage.value = message;
//     Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
//   }
// }

import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../route/app_routes.dart';
import '../auth/login_view_controller.dart';

class WaiterDrawerController extends GetxController {
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
    developer.log('WaiterDrawerController initialized', name: 'Restaurant');
    _initializeData();
    _setupRouteListener();
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('WaiterDrawerController ready', name: 'Restaurant');
  }

  @override
  void onClose() {
    super.onClose();
    developer.log('WaiterDrawerController disposed', name: 'Restaurant');
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

  // Setup route listener to auto-update selection based on current route
  void _setupRouteListener() {
    // Listen to route changes
    ever(Get.currentRoute.obs, (route) {
      _updateSelectionBasedOnRoute(route);
    });
  }

  void _updateSelectionBasedOnRoute(String route) {
    developer.log('Route changed to: $route', name: 'Restaurant');

    if (route == AppRoutes.waiterDashboard || route == '/restaurant') {
      if (selectedSidebarItem.value != 'RESTAURANT') {
        selectedSidebarItem.value = 'RESTAURANT';
        developer.log('Selection reset to RESTAURANT', name: 'Restaurant');
      }
    } else if (route.contains('NotificationView')) {
      selectedSidebarItem.value = 'NOTIFICATION';
    } else if (route.contains('orderView') || route.contains('history')) {
      selectedSidebarItem.value = 'HISTORY';
    }
  }

  // Header actions
  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
    developer.log('Drawer toggled: ${isDrawerOpen.value}', name: 'Restaurant');
  }

  void handleLogout() {
    developer.log('Logout button pressed', name: 'Restaurant');

    // Reset selection to default before logout
    selectedSidebarItem.value = 'RESTAURANT';

    final loginController = Get.find<LoginViewController>();
    loginController.logout();
  }

  // Sidebar navigation with automatic reset on return
  void handleNotification() {
    selectedSidebarItem.value = 'NOTIFICATION';
    developer.log('Notification menu pressed', name: 'Restaurant');

    NavigationService.pushToWaiterNotification();
  }

  void handleHistory() {
    selectedSidebarItem.value = 'HISTORY';
    developer.log('History menu pressed', name: 'Restaurant');

    NavigationService.pushToWaiterHistory();
  }

  void handleSettings() {
    selectedSidebarItem.value = 'SETTINGS';
    developer.log('Settings menu pressed', name: 'Restaurant');
    Get.snackbar('Info', 'Settings feature will be implemented');
  }

  void handleRestaurant() {
    selectedSidebarItem.value = 'RESTAURANT';
    developer.log('Restaurant menu pressed', name: 'Restaurant');

    // Navigate back to dashboard if not already there
    if (Get.currentRoute != AppRoutes.waiterDashboard) {
      NavigationService.goToWaiterDashboard();
    }
  }

  // Main action buttons
  void handleTakeOrders() {
    selectedMainButton.value = 'take_orders';
    developer.log('Take Orders selected', name: 'Restaurant');
  }

  void handleReadyOrders() {
    selectedMainButton.value = 'ready_orders';
    developer.log('Ready Orders selected', name: 'Restaurant');
  }

  // Manual reset method (can be called from dashboard)
  void resetToDefault() {
    selectedSidebarItem.value = 'RESTAURANT';
    selectedMainButton.value = 'take_orders';
    developer.log('Reset to default selection', name: 'Restaurant');
  }

  // Additional utility methods
  void refreshData() {
    isLoading.value = true;
    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      _initializeData();
      isLoading.value = false;
      Get.snackbar('Success', 'Data refreshed successfully');
    });
  }

  void showError(String message) {
    errorMessage.value = message;
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }
}
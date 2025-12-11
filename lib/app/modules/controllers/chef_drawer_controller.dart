import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../route/app_routes.dart';
import '../auth/login_view_controller.dart';

class ChefDrawerController extends GetxController {
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
  final selectedMainButton = 'take_orders'.obs;
  final selectedSidebarItem = 'RESTAURANT'.obs; // 'RESTAURANT', 'NOTIFICATION', 'HISTORY'

  @override
  void onInit() {
    super.onInit();
    developer.log('ChefDrawerController initialized', name: 'Chef');
    _initializeData();
    _setupRouteListener();
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('ChefDrawerController ready', name: 'Chef');
  }

  @override
  void onClose() {
    super.onClose();
    developer.log('ChefDrawerController disposed', name: 'Chef');
  }

  void _initializeData() {
    restaurantData.value = {
      'name': hotelName.value,
      'address': hotelAddress.value,
      'phone': phoneNumber.value,
    };
    developer.log('Chef data initialized', name: 'Chef');
  }

  // Setup route listener to auto-update selection based on current route
  void _setupRouteListener() {
    // Listen to route changes
    ever(Get.currentRoute.obs, (route) {
      _updateSelectionBasedOnRoute(route);
    });
  }

  void _updateSelectionBasedOnRoute(String route) {
    developer.log('Route changed to: $route', name: 'Chef');

    if (route == AppRoutes.chefDashboard || route == '/chefDashboard') {
      if (selectedSidebarItem.value != 'RESTAURANT') {
        selectedSidebarItem.value = 'RESTAURANT';
        developer.log('Selection reset to RESTAURANT', name: 'Chef');
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
    developer.log('Drawer toggled: ${isDrawerOpen.value}', name: 'Chef');
  }

  void handleLogout() {
    developer.log('Logout button pressed', name: 'Chef');

    // Reset selection to default before logout
    selectedSidebarItem.value = 'RESTAURANT';

    final loginController = Get.find<LoginViewController>();
    loginController.logout();
  }

  // Sidebar navigation with automatic reset on return
  void handleNotification() {
    selectedSidebarItem.value = 'NOTIFICATION';
    developer.log('Notification menu pressed', name: 'Chef');

    Get.snackbar('Info', 'Notifications feature will be implemented');
    // Note: ChefNotificationView route needs to be added to AppRoutes
    NavigationService.pushToWaiterNotification();
  }

  void handleHistory() {
    selectedSidebarItem.value = 'HISTORY';
    developer.log('History menu pressed', name: 'Chef');

    NavigationService.pushToChefHistory();
  }

  void handleSettings() {
    selectedSidebarItem.value = 'SETTINGS';
    developer.log('Settings menu pressed', name: 'Chef');
    Get.snackbar('Info', 'Settings feature will be implemented');
  }

  void handleRestaurant() {
    selectedSidebarItem.value = 'RESTAURANT';
    developer.log('Restaurant menu pressed', name: 'Chef');

    // Navigate back to dashboard if not already there
    if (Get.currentRoute != AppRoutes.chefDashboard) {
      NavigationService.goToChefDashboard();
    }
  }

  // Main action buttons
  void handleTakeOrders() {
    selectedMainButton.value = 'take_orders';
    developer.log('Pending Orders selected', name: 'Chef');
  }

  void handleReadyOrders() {
    selectedMainButton.value = 'ready_orders';
    developer.log('Preparing Orders selected', name: 'Chef');
  }

  // Manual reset method (can be called from dashboard)
  void resetToDefault() {
    selectedSidebarItem.value = 'RESTAURANT';
    selectedMainButton.value = 'take_orders';
    developer.log('Reset to default selection', name: 'Chef');
  }

  // Additional utility methods
  void refreshData() {
    isLoading.value = true;
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
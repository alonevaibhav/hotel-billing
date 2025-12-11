//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:developer' as developer;
// import '../core/services/notification_storage_service.dart';
// import '../data/models/ResponseModel/table_model.dart';
// import '../modules/auth/login_view.dart';
// import '../modules/view/ChefPanel/dashboard.dart';
// import '../modules/view/ChefPanel/sidebar/chef_history/chef_history.dart';
// import '../modules/view/WaiterPanel/home_page.dart';
// import '../modules/view/WaiterPanel/TakeOrder/AddItems/add_items_view.dart';
// import '../modules/view/WaiterPanel/TakeOrder/OrderView/order_view_main.dart';
// import '../modules/view/WaiterPanel/sidebar/waiter_history/order_history_view.dart';
// import '../modules/view/WaiterPanel/sidebar/waiter_notification.dart';
// import 'app_bindings.dart';
//
// class AppRoutes {
//   // Route names
//   static const login = '/login';
//   static const forgotPassword = '/forgotPassword';
//
//   // Waiter Routes
//   static const waiterDashboard = '/restaurant';
//   static const selectItem = '/restaurant/selectItem';
//   static const addItems = '/restaurant/selectItem/addItems';
//   static const waiterHistoryView = '/restaurant/orderView';
//   static const waiterNotificationView = '/restaurant/NotificationView';
//
//   // Chef Routes
//   static const chefDashboard = '/chefDashboard';
//   static const chefHistoryView = '/chefDashboard/orderView';
//
//
//   // Initialize bindings once at app start
//   static void initializeBindings() {
//     AppBindings().dependencies();
//   }
//
//   // Create router based on authentication data
//   static GoRouter getRouter({
//     required Map<String, dynamic> authData,
//     String? currentLocation, // Add this parameter
//   }) {
//     final isAuthenticated = authData['isAuthenticated'] ?? false;
//     final userRole = authData['userRole'] as String?;
//     final userName = authData['userName'] as String?;
//
//     // Use currentLocation if provided (hot reload case), otherwise determine from auth
//     String initialLocation = currentLocation ?? login;
//
//     if (currentLocation == null && isAuthenticated && userRole != null) {
//       initialLocation = _getInitialLocationByRole(userRole);
//     }
//
//     developer.log('Router setup - Initial: $initialLocation, Auth: $isAuthenticated, Role: $userRole, User: $userName', name: 'AppRoutes');
//
//     return GoRouter(
//       initialLocation: initialLocation,
//       routes: [
//         // Auth Routes
//         GoRoute(
//           path: login,
//           builder: (context, state) => const LoginView(),
//         ),
//         GoRoute(
//           path: forgotPassword,
//           builder: (context, state) => const Placeholder(),
//         ),
//
//         // Waiter Routes
//         GoRoute(
//           path: waiterDashboard,
//           builder: (context, state) => const WaiterDashboardView(),
//         ),
//         GoRoute(
//           path: selectItem,
//           builder: (context, state) {
//             final tableInfo = state.extra as TableInfo?;
//             return OrderManagementView(tableInfo: tableInfo);
//           },
//         ),
//         GoRoute(
//           path: addItems,
//           builder: (context, state) {
//             final table = state.extra as Map<String, dynamic>?;
//             return AddItemsView(table: table);
//           },
//         ),
//         GoRoute(
//           path: waiterHistoryView,
//           builder: (context, state) => const WaiterOrderHistoryView(),
//         ),
//         GoRoute(
//           path: waiterNotificationView,
//           builder: (context, state) {
//             final controller = Get.find<NotificationStorageController>();
//
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               controller.refreshNotifications();
//             });
//
//             return WaiterNotificationPage();
//           },
//         ),
//
//
//         // Chef Routes
//         GoRoute(
//           path: chefDashboard,
//           builder: (context, state) => const ChefDashboard(),
//         ),
//         GoRoute(
//           path: chefHistoryView,
//           builder: (context, state) => const ChefOrderHistoryView(),
//         ),
//       ],
//     );
//   }
//
//   // Helper method to get initial location by role
//   static String _getInitialLocationByRole(String role) {
//     switch (role.toLowerCase()) {
//       case 'waiter':
//         return waiterDashboard;
//       case 'chef':
//         return chefDashboard;
//       default:
//         developer.log('Unknown role: $role, defaulting to login', name: 'AppRoutes');
//         return login;
//     }
//   }
// }
//
// // Clean Navigation Service
// class NavigationService {
//   static GoRouter? _router;
//
//   // Initialize the router
//   static void initialize(GoRouter router) {
//     _router = router;
//     developer.log('NavigationService initialized', name: 'NavigationService');
//   }
//
//   // Get the router instance
//   static GoRouter get router {
//     if (_router == null) {
//       throw Exception('NavigationService not initialized. Call NavigationService.initialize() first.');
//     }
//     return _router!;
//   }
//
//   // Get current location
//   static String? get currentLocation {
//     return _router?.routerDelegate.currentConfiguration.uri.toString();
//   }
//
//   // Navigation methods
//   static void goToLogin() {
//     router.go(AppRoutes.login);
//   }
//
//   static void goToWaiterDashboard() {
//     router.go(AppRoutes.waiterDashboard);
//   }
//
//   static void goToChefDashboard() {
//     router.go(AppRoutes.chefDashboard);
//   }
//
//   static void selectItem(TableInfo tableInfo) {
//     router.push(AppRoutes.selectItem, extra: tableInfo);
//   }
//
//   static void addItems(Map<String, dynamic>? table) {
//     router.push(AppRoutes.addItems, extra: table);
//   }
//
//   static void pushToWaiterHistory() {
//     router.push(AppRoutes.waiterHistoryView);
//   }
//   static void pushToWaiterNotification() {
//     router.push(AppRoutes.waiterNotificationView);
//   }
//
//
//   static void pushToChefHistory() {
//     router.push(AppRoutes.chefHistoryView);
//   }
//
//   static void goBack() {
//     if (router.canPop()) {
//       developer.log('Navigating back', name: 'NavigationService');
//       router.pop();
//     } else {
//       developer.log('Cannot navigate back - no routes in stack', name: 'NavigationService');
//     }
//   }
//
//   static bool canGoBack() => router.canPop();
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../core/services/notification_storage_service.dart';
import '../data/models/ResponseModel/table_model.dart';
import '../modules/auth/login_view.dart';
import '../modules/view/ChefPanel/dashboard.dart';
import '../modules/view/ChefPanel/sidebar/chef_history/chef_history.dart';
import '../modules/view/WaiterPanel/home_page.dart';
import '../modules/view/WaiterPanel/TakeOrder/AddItems/add_items_view.dart';
import '../modules/view/WaiterPanel/TakeOrder/OrderView/order_view_main.dart';
import '../modules/view/WaiterPanel/sidebar/waiter_history/order_history_view.dart';
import '../modules/view/WaiterPanel/sidebar/waiter_notification.dart';
import '../modules/controllers/drawer_controller.dart';
import '../modules/controllers/chef_drawer_controller.dart';
import 'app_bindings.dart';

class AppRoutes {
  // Route names
  static const login = '/login';
  static const forgotPassword = '/forgotPassword';

  // Waiter Routes
  static const waiterDashboard = '/restaurant';
  static const selectItem = '/restaurant/selectItem';
  static const addItems = '/restaurant/selectItem/addItems';
  static const waiterHistoryView = '/restaurant/orderView';
  static const waiterNotificationView = '/restaurant/NotificationView';

  // Chef Routes
  static const chefDashboard = '/chefDashboard';
  static const chefHistoryView = '/chefDashboard/orderView';

  // Initialize bindings once at app start
  static void initializeBindings() {
    AppBindings().dependencies();

    // Initialize WaiterDrawerController as permanent
    if (!Get.isRegistered<WaiterDrawerController>()) {
      Get.put(WaiterDrawerController(), permanent: true);
      developer.log('WaiterDrawerController registered permanently', name: 'AppRoutes');
    }

    // Initialize ChefDrawerController as permanent
    if (!Get.isRegistered<ChefDrawerController>()) {
      Get.put(ChefDrawerController(), permanent: true);
      developer.log('ChefDrawerController registered permanently', name: 'AppRoutes');
    }
  }

  // Create router based on authentication data
  static GoRouter getRouter({
    required Map<String, dynamic> authData,
    String? currentLocation,
  }) {
    final isAuthenticated = authData['isAuthenticated'] ?? false;
    final userRole = authData['userRole'] as String?;
    final userName = authData['userName'] as String?;

    // Use currentLocation if provided (hot reload case), otherwise determine from auth
    String initialLocation = currentLocation ?? login;

    if (currentLocation == null && isAuthenticated && userRole != null) {
      initialLocation = _getInitialLocationByRole(userRole);
    }

    developer.log(
      'Router setup - Initial: $initialLocation, Auth: $isAuthenticated, Role: $userRole, User: $userName',
      name: 'AppRoutes',
    );

    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        // Auth Routes
        GoRoute(
          path: login,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const Placeholder(),
        ),

        // Waiter Routes
        GoRoute(
          path: waiterDashboard,
          builder: (context, state) {
            // Reset drawer selection when returning to dashboard
            _resetDrawerSelection();
            return const WaiterDashboardView();
          },
        ),
        GoRoute(
          path: selectItem,
          builder: (context, state) {
            final tableInfo = state.extra as TableInfo?;
            return OrderManagementView(tableInfo: tableInfo);
          },
        ),
        GoRoute(
          path: addItems,
          builder: (context, state) {
            final table = state.extra as Map<String, dynamic>?;
            return AddItemsView(table: table);
          },
        ),
        GoRoute(
          path: waiterHistoryView,
          builder: (context, state) {
            return const WaiterOrderHistoryView();
          },
        ),
        GoRoute(
          path: waiterNotificationView,
          builder: (context, state) {
            final controller = Get.find<NotificationStorageController>();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.refreshNotifications();
            });

            return WaiterNotificationPage();
          },
        ),

        // Chef Routes
        GoRoute(
          path: chefDashboard,
          builder: (context, state) {
            // Reset drawer selection when returning to dashboard
            _resetChefDrawerSelection();
            return const ChefDashboard();
          },
        ),
        GoRoute(
          path: chefHistoryView,
          builder: (context, state) => const ChefOrderHistoryView(),
        ),
      ],
    );

    // Add route listener to track navigation and update drawer selection
    router.routerDelegate.addListener(() {
      _handleRouteChange(router.routerDelegate.currentConfiguration.uri.toString());
    });

    return router;
  }

  // Helper method to get initial location by role
  static String _getInitialLocationByRole(String role) {
    switch (role.toLowerCase()) {
      case 'waiter':
        return waiterDashboard;
      case 'chef':
        return chefDashboard;
      default:
        developer.log('Unknown role: $role, defaulting to login', name: 'AppRoutes');
        return login;
    }
  }

  // Reset drawer selection to default
  static void _resetDrawerSelection() {
    if (Get.isRegistered<WaiterDrawerController>()) {
      final controller = Get.find<WaiterDrawerController>();
      controller.resetToDefault();
      developer.log('Drawer selection reset to default', name: 'AppRoutes');
    }
  }

  // Reset chef drawer selection to default
  static void _resetChefDrawerSelection() {
    if (Get.isRegistered<ChefDrawerController>()) {
      final controller = Get.find<ChefDrawerController>();
      controller.resetToDefault();
      developer.log('Chef drawer selection reset to default', name: 'AppRoutes');
    }
  }

  // Handle route changes
  static void _handleRouteChange(String route) {
    developer.log('Route changed: $route', name: 'AppRoutes');

    // Handle Waiter routes
    if (Get.isRegistered<WaiterDrawerController>()) {
      final waiterController = Get.find<WaiterDrawerController>();

      if (route == waiterDashboard || route == '/restaurant') {
        waiterController.selectedSidebarItem.value = 'RESTAURANT';
      } else if (route.contains('NotificationView') && route.contains('restaurant')) {
        waiterController.selectedSidebarItem.value = 'NOTIFICATION';
      } else if (route.contains('orderView') && route.contains('restaurant')) {
        waiterController.selectedSidebarItem.value = 'HISTORY';
      }
    }

    // Handle Chef routes
    if (Get.isRegistered<ChefDrawerController>()) {
      final chefController = Get.find<ChefDrawerController>();

      if (route == chefDashboard || route == '/chefDashboard') {
        chefController.selectedSidebarItem.value = 'RESTAURANT';
      } else if (route.contains('NotificationView') && route.contains('chef')) {
        chefController.selectedSidebarItem.value = 'NOTIFICATION';
      } else if (route.contains('orderView') && route.contains('chef')) {
        chefController.selectedSidebarItem.value = 'HISTORY';
      }
    }
  }
}

// Clean Navigation Service
class NavigationService {
  static GoRouter? _router;

  // Initialize the router
  static void initialize(GoRouter router) {
    _router = router;
    developer.log('NavigationService initialized', name: 'NavigationService');
  }

  // Get the router instance
  static GoRouter get router {
    if (_router == null) {
      throw Exception(
        'NavigationService not initialized. Call NavigationService.initialize() first.',
      );
    }
    return _router!;
  }

  // Get current location
  static String? get currentLocation {
    return _router?.routerDelegate.currentConfiguration.uri.toString();
  }

  // Navigation methods
  static void goToLogin() {
    router.go(AppRoutes.login);
  }

  static void goToWaiterDashboard() {
    router.go(AppRoutes.waiterDashboard);
  }

  static void goToChefDashboard() {
    router.go(AppRoutes.chefDashboard);
  }

  static void selectItem(TableInfo tableInfo) {
    router.push(AppRoutes.selectItem, extra: tableInfo);
  }

  static void addItems(Map<String, dynamic>? table) {
    router.push(AppRoutes.addItems, extra: table);
  }

  static void pushToWaiterHistory() {
    router.push(AppRoutes.waiterHistoryView);
  }

  static void pushToWaiterNotification() {
    router.push(AppRoutes.waiterNotificationView);
  }

  static void pushToChefHistory() {
    router.push(AppRoutes.chefHistoryView);
  }

  static void goBack() {
    if (router.canPop()) {
      developer.log('Navigating back', name: 'NavigationService');
      router.pop();
    } else {
      developer.log('Cannot navigate back - no routes in stack', name: 'NavigationService');
    }
  }

  static bool canGoBack() => router.canPop();
}
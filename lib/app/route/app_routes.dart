// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../modules/auth/login_view.dart';
// import '../modules/view/ChefPanel/dashboard.dart';
// import '../modules/view/WaiterPanel/home_page.dart';
// import '../modules/view/WaiterPanel/TakeOrder/components/add_items_view.dart';
// import '../modules/view/WaiterPanel/TakeOrder/components/select_item.dart';
// import 'app_bindings.dart';
//
// class AppRoutes {
//   // Route names - keep same naming convention
//   static const login = '/login';
//   static const forgotPassword = '/forgotPassword';
//
//   //Waiter Route
//   static const waiterDashboard = '/restaurant';
//   static const selectItem = '/restaurant/selectItem';
//   static const addItems = '/restaurant/selectItem/addItems';
//
//
//   //Chef Route
//   static const chefDashboard = '/chefDashboard';
//
//
//
//   // Initialize bindings once at app start
//   static void initializeBindings() {
//     AppBindings().dependencies();
//   }
//
//   // Simple Go Router configuration for mobile
//   static final GoRouter router = GoRouter(
//     initialLocation: login,
//     routes: [
//       GoRoute(
//         path: login,
//         builder: (context, state) => const LoginView(),
//       ),
//       GoRoute(
//         path: forgotPassword,
//         builder: (context, state) => const Placeholder(),
//       ),
//
//       //Waiter Route
//       GoRoute(
//         path: waiterDashboard,
//         builder: (context, state) => const WaiterDashboardView(),
//       ),
//       GoRoute(
//         path: selectItem,
//         builder: (context, state) {
//           final table =
//           state.extra as Map<String, dynamic>?; // Retrieve extra here
//           return OrderManagementView(table: table); // Pass to widget
//         },
//       ),
//       GoRoute(
//         path: addItems,
//         builder: (context, state) {
//           final table = state.extra as Map<String, dynamic>?; // Retrieve extra here
//           return AddItemsView(table: table); // Pass to widget
//         },
//       ),
//
//       //Chef Route
//
//       GoRoute(
//         path: chefDashboard,
//         builder: (context, state) => const ChefDashboard(),
//       ),
//
//
//     ],
//   );
// }
//
// // navigation_service.dart - Simple navigation helpers
// class NavigationService {
//   static final GoRouter _router = AppRoutes.router;
//
//   // Simple navigation methods
//   static void goToLogin() {
//     _router.go(AppRoutes.login);
//   }
//
//   //Waiter Route
//   static void goToWaiterDashboard() {
//     _router.push(AppRoutes.waiterDashboard);
//   }
//
//   static void selectItem(Map<String, dynamic> table) {
//     _router.push(AppRoutes.selectItem, extra: table);
//   }
//
//   static void addItems(Map<String, dynamic>? table) {
//     _router.push(AppRoutes.addItems, extra: table);
//   }
//
//   //Chef Route
//
//   static void goToChefDashboard() {
//     _router.push(AppRoutes.chefDashboard);
//   }
//
//
//
//
//   static void goBack() {
//     if (_router.canPop()) {
//       _router.pop();
//     }
//   }
//
//   static bool canGoBack() => _router.canPop();
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../modules/auth/login_view.dart';
import '../modules/view/ChefPanel/dashboard.dart';
import '../modules/view/WaiterPanel/home_page.dart';
import '../modules/view/WaiterPanel/TakeOrder/components/add_items_view.dart';
import '../modules/view/WaiterPanel/TakeOrder/components/select_item.dart';
import 'app_bindings.dart';

class AppRoutes {
  // Route names
  static const login = '/login';
  static const forgotPassword = '/forgotPassword';

  // Waiter Routes
  static const waiterDashboard = '/restaurant';
  static const selectItem = '/restaurant/selectItem';
  static const addItems = '/restaurant/selectItem/addItems';

  // Chef Routes
  static const chefDashboard = '/chefDashboard';

  // Initialize bindings once at app start
  static void initializeBindings() {
    AppBindings().dependencies();
  }

  // Create router based on authentication data
  static GoRouter getRouter({required Map<String, dynamic> authData}) {
    final isAuthenticated = authData['isAuthenticated'] ?? false;
    final userRole = authData['userRole'] as String?;
    final userName = authData['userName'] as String?;

    // Determine initial location based on authentication and role
    String initialLocation = login; // Default to login

    if (isAuthenticated && userRole != null) {
      initialLocation = _getInitialLocationByRole(userRole);
    }

    developer.log('Router setup - Initial: $initialLocation, Auth: $isAuthenticated, Role: $userRole, User: $userName', name: 'AppRoutes');

    return GoRouter(
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
          builder: (context, state) => const WaiterDashboardView(),
        ),
        GoRoute(
          path: selectItem,
          builder: (context, state) {
            final table = state.extra as Map<String, dynamic>?;
            return OrderManagementView(table: table);
          },
        ),
        GoRoute(
          path: addItems,
          builder: (context, state) {
            final table = state.extra as Map<String, dynamic>?;
            return AddItemsView(table: table);
          },
        ),

        // Chef Routes
        GoRoute(
          path: chefDashboard,
          builder: (context, state) => const ChefDashboard(),
        ),
      ],
    );
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
      throw Exception('NavigationService not initialized. Call NavigationService.initialize() first.');
    }
    return _router!;
  }

  // Navigation methods
  static void goToLogin() {
    developer.log('Navigating to login', name: 'NavigationService');
    router.go(AppRoutes.login);
  }

  static void goToWaiterDashboard() {
    developer.log('Navigating to waiter dashboard', name: 'NavigationService');
    router.go(AppRoutes.waiterDashboard); // Changed from push to go
  }

  static void goToChefDashboard() {
    developer.log('Navigating to chef dashboard', name: 'NavigationService');
    router.go(AppRoutes.chefDashboard); // Changed from push to go
  }

  static void selectItem(Map<String, dynamic> table) {
    developer.log('Navigating to select item', name: 'NavigationService');
    router.push(AppRoutes.selectItem, extra: table);
  }

  static void addItems(Map<String, dynamic>? table) {
    developer.log('Navigating to add items', name: 'NavigationService');
    router.push(AppRoutes.addItems, extra: table);
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
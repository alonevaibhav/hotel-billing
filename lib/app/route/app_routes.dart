import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/auth/login_view.dart';
import '../modules/view/TakeOrder/components/add_items_view.dart';
import '../modules/view/TakeOrder/components/select_item.dart';
import '../modules/view/homepage/home_page.dart';
import 'app_bindings.dart';

class AppRoutes {
  // Route names - keep same naming convention
  static const login = '/login';
  static const forgotPassword = '/forgotPassword';
  static const mainDashboard = '/restaurant';

  static const selectItem = '/restaurant/selectItem';
  static const addItems = '/restaurant/selectItem/addItems';

  static const selectDish = '/restaurant/selectDish';



  // Initialize bindings once at app start
  static void initializeBindings() {
    AppBindings().dependencies();
  }

  // Simple Go Router configuration for mobile
  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginView(),
      ),

      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const Placeholder(),
      ),

      GoRoute(
        path: mainDashboard,
        builder: (context, state) => const WaiterDashboardView(),
      ),
      GoRoute(
        path: selectItem,
        builder: (context, state) {
          final table = state.extra as Map<String, dynamic>?; // Retrieve extra here
          return OrderManagementView(table: table); // Pass to widget
        },
      ),

      GoRoute(
        path: addItems,
        builder: (context, state) {
          final table = state.extra as Map<String, dynamic>?; // Retrieve extra here
          return AddItemsView(table: table); // Pass to widget
        },
      ),


    ],
  );
}

// navigation_service.dart - Simple navigation helpers
class NavigationService {
  static final GoRouter _router = AppRoutes.router;

  // Simple navigation methods
  static void goToLogin() {
    _router.go(AppRoutes.login);
  }

  static void goToMainDashboard() {
    _router.push(AppRoutes.mainDashboard);
  }

  static void selectItem(Map<String, dynamic> table) {
    _router.push(AppRoutes.selectItem, extra: table);
  }

  static void addItems(Map<String, dynamic>? table) {
    _router.push(AppRoutes.addItems, extra: table);
  }

  // NEW: Go back to OrderManagement (selectItem) with fresh navigation
  static void goBackToOrderManagement(Map<String, dynamic>? table) {
    try {
      // Use go() instead of push() to clear navigation stack and prevent setState issues
      _router.pushReplacement(AppRoutes.selectItem, extra: table);
    } catch (e) {
      // Fallback to regular back navigation
      goBack();
    }
  }



  static void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  static bool canGoBack() => _router.canPop();
}

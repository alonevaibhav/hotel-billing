import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/auth/login_view.dart';
import '../modules/view/TakeOrder/take_order.dart';
import '../modules/view/homepage/home_page.dart';
import '../modules/view/ready_order/ready_order.dart';
import 'app_bindings.dart';

class AppRoutes {
  // Route names - keep same naming convention
  static const login = '/login';
  static const forgotPassword = '/forgotPassword';
  static const mainDashboard = '/restaurant';

  static const takeOrders = '/restaurant/take-orders';
  static const readyOrders = '/restaurant/ready-orders';

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
        builder: (context, state) => const RestaurantView(),
      ),

      // Take Orders route (to be implemented later)
      // GoRoute(
      //   path: takeOrders,
      //   builder: (context, state)  => const TakeOrder(),
      // ),

      // Ready Orders route (to be implemented later)
      GoRoute(
        path: readyOrders,
        builder: (context, state)  => const ReadyOrder(),
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

  static void goToTakeOrders() {
    _router.push(AppRoutes.takeOrders);
  }

  static void goToReadyOrders() {
    _router.push(AppRoutes.readyOrders);
  }

  static void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  static bool canGoBack() => _router.canPop();
}

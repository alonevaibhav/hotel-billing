// import 'package:get/get.dart';
// import '../modules/auth/login_view.dart';
// import 'app_bindings.dart';
//
// class AppRoutes {
//   // Route names
//   static const login = '/login';
//
//   static const mainDashboard = '/mainDashboard';
//
//
//   static final routes = <GetPage>[
//     GetPage(
//       name: login,
//       page: () => const LoginView(),
//       binding: AppBindings(),
//     ),
//   ];
// }

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/auth/login_view.dart';
import 'app_bindings.dart';

class AppRoutes {
  // Route names - keep same naming convention
  static const login = '/login';
  static const forgotPassword = '/forgotPassword';
  static const mainDashboard = '/mainDashboard';

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
        builder: (context, state) => const Placeholder(),
      ),

      // Add more routes as needed
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
    _router.go(AppRoutes.mainDashboard);
  }

  static void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  static bool canGoBack() => _router.canPop();
}

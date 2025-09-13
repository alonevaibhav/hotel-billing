
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import 'app/core/services/api_service.dart';
import 'app/core/services/session_manager_service.dart';
import 'app/route/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  await ApiService.init();

  // Check authentication status with role using enhanced TokenManager
  final authData = await TokenManager.checkAuthenticationWithRole();
  developer.log('Startup auth check - Authenticated: ${authData['isAuthenticated']}, Role: ${authData['userRole']}, User: ${authData['userName']}', name: 'Main');

  // Initialize bindings for Go Router
  AppRoutes.initializeBindings();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MyApp(authData: authData));
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> authData;

  const MyApp({
    super.key,
    required this.authData,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Create router with authentication data
        final router = AppRoutes.getRouter(authData: authData);
        NavigationService.initialize(router);

        return MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          debugShowCheckedModeBanner: false,
          title: 'Hotel-Billing',
        );
      },
    );
  }
}
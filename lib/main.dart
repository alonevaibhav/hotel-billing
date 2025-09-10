// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import 'app/core/services/api_service.dart';
// import 'app/route/app_bindings.dart';
// import 'app/route/app_routes.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize API Service
//   await ApiService.init();
//
//   // Set system UI overlay style
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.white,
//       statusBarIconBrightness: Brightness.dark,
//       systemNavigationBarColor: Colors.white,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: Size(360, 690),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return GetMaterialApp(
//           theme: ThemeData(
//             scaffoldBackgroundColor: Colors.white,
//             appBarTheme: const AppBarTheme(
//               backgroundColor: Colors.white,
//               elevation: 0,
//               iconTheme: IconThemeData(color: Colors.black),
//             ),
//             textTheme: GoogleFonts.interTextTheme(
//               Theme.of(context).textTheme,
//             ),
//           ),
//           debugShowCheckedModeBanner: false,
//           title: 'Hotel-Billing',
//           initialRoute: AppRoutes.login,
//           getPages: AppRoutes.routes,
//           initialBinding: AppBindings(),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/core/services/api_service.dart';
import 'app/route/app_routes.dart';
import 'demo/Service/table_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  await ApiService.init();


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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          // Use Go Router
          routerConfig: AppRoutes.router,

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

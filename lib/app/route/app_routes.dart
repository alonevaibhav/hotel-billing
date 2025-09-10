import 'package:get/get.dart';
import '../modules/auth/login_view.dart';
import 'app_bindings.dart';

class AppRoutes {
  // Route names
  static const login = '/login';

  static const mainDashboard = '/mainDashboard';


  static final routes = <GetPage>[
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AppBindings(),
    ),
  ];
}

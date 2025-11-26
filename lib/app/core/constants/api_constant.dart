class ApiConstants {
  // Base URL
  static const String baseUrl = "https://api-dev.squrepos.com";
  // static const String baseUrl = "https://api.squrepos.com";

  // Auth
  static const String hostelBillingLogin = "/api/owner/employee/login";

  // Waiter Panel
  static const String waiterGetTable = "/api/owner/employee/tables";

  static String waiterGetTableOrder(int orderId) => "/api/owner/employee/orders/$orderId";

  static const String waiterGetMenuCategory = "/api/owner/employee/get/categories/list";

  static String getCleanerMenuSubcategory(int id) => "/api/owner/employee/menu/category/$id/items";

  static const String waiterPostCreateOrder = "/api/owner/employee/orders/create";



  // Dynamic URLs
  static String getCleanerPlantsInfoUrl(int inspectorId) => "/api/plant/cleaner/$inspectorId";
}

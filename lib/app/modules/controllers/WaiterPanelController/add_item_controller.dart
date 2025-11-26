import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hotelbilling/app/modules/controllers/WaiterPanelController/select_item_controller.dart';
import 'dart:developer' as developer;
import '../../../core/constants/api_constant.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/ResponseModel/category_model.dart';
import '../../../data/models/ResponseModel/subcategory_model.dart';
import '../../../route/app_routes.dart';

class AddItemsController extends GetxController {
  // Search functionality
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Categories and filtering
  final categories = <String>[].obs;
  final categoryObjects = <Category>[].obs;
  final selectedCategory = 'All'.obs;
  final selectedCategoryId = Rxn<int>();
  final activeFilters = <String>[].obs;

  // Menu data
  final filteredItems = <Map<String, dynamic>>[].obs;
  final allItems = <Map<String, dynamic>>[].obs;
  final selectedItems = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isLoadingItems = false.obs;

  // Table context
  final currentTable = Rxn<Map<String, dynamic>>();
  final currentTableId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    loadCategoriesFromAPI();
    developer.log('AddItemsController initialized');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void setTableContext(Map<String, dynamic>? table) {
    currentTable.value = table;
    currentTableId.value = table?['id'] ?? 0;
    developer.log('Table context set: ${table?['tableNumber']}');
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterItems();
    });
  }

  // Load categories from API
  Future<void> loadCategoriesFromAPI() async {
    try {
      isLoading.value = true;
      developer.log('Fetching categories from API...');

      final apiResponse = await ApiService.get<CategoryResponse>(
        endpoint: ApiConstants.waiterGetMenuCategory,
        fromJson: (json) => CategoryResponse.fromJson(json),
        includeToken: true,
      );

      if (apiResponse?.data?.success == true &&
          apiResponse!.data!.data.isNotEmpty) {
        categoryObjects.value =
            apiResponse.data!.data.where((cat) => cat.isActive == 1).toList();

        // Build category names list
        categories.value = [
          'All',
          ...categoryObjects.map((cat) => cat.categoryName).toList()..sort()
        ];

        developer.log('Categories loaded: ${categories.length}');

        // Load all items initially
        await _loadAllItems();
      } else {
        _showErrorAndUseFallback('Failed to load categories');
      }
    } catch (e) {
      developer.log('Error loading categories: $e');
      _showErrorAndUseFallback('Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorAndUseFallback(String message) {
    SnackBarUtil.showError(
      Get.context!,
      message,
      title: 'Error',
      duration: const Duration(seconds: 2),
    );
    categories.value = ['All'];
  }

  // Load all items across all categories
  Future<void> _loadAllItems() async {
    try {
      allItems.clear();

      for (var category in categoryObjects) {
        await _loadItemsForCategory(category.id, category.categoryName);
      }

      _sortAndFilterItems();
      developer.log('All items loaded: ${allItems.length}');
    } catch (e) {
      developer.log('Error loading all items: $e');
    }
  }

  // Load items for specific category (called when category is clicked)
  Future<void> selectCategory(String categoryName) async {
    if (selectedCategory.value == categoryName) return;

    selectedCategory.value = categoryName;
    developer.log('Category selected: $categoryName');

    if (categoryName == 'All') {
      selectedCategoryId.value = null;
      _filterItems();
      return;
    }

    // Find category object
    final category = categoryObjects
        .firstWhereOrNull((cat) => cat.categoryName == categoryName);

    if (category == null) {
      developer.log('Category not found: $categoryName');
      return;
    }

    selectedCategoryId.value = category.id;

    // Check if items for this category are already loaded
    final hasItems =
        allItems.any((item) => item['menu_category_id'] == category.id);

    if (!hasItems) {
      // Load items from API
      await _loadItemsForCategory(category.id, categoryName);
    }

    _filterItems();
  }

  // Fetch items for a specific category
  Future<void> _loadItemsForCategory(
      int categoryId, String categoryName) async {
    try {
      isLoadingItems.value = true;
      developer
          .log('Fetching items for category: $categoryName (ID: $categoryId)');

      final apiResponse = await ApiService.get<MenuItemResponse>(
        endpoint: ApiConstants.getCleanerMenuSubcategory(categoryId),
        fromJson: (json) => MenuItemResponse.fromJson(json),
        includeToken: true,
      );

      if (apiResponse?.data?.success == true &&
          apiResponse!.data!.data.isNotEmpty) {
        // Remove old items from this category
        allItems.removeWhere((item) => item['menu_category_id'] == categoryId);

        // Process and add new items
        for (var item in apiResponse.data!.data) {
          if (item.isActive == 1 && item.isAvailable == 1) {
            final processedItem = _processMenuItem(item, categoryName);
            allItems.add(processedItem);
          }
        }

        developer.log(
            'Loaded ${apiResponse.data!.data.length} items for $categoryName');
      } else {
        developer.log('No items found for category: $categoryName');
      }
    } catch (e) {
      developer.log('Error loading items for category $categoryName: $e');
      SnackBarUtil.showError(
        Get.context!,
        'Failed to load items for $categoryName',
        title: 'Error',
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoadingItems.value = false;
    }
  }

  // Process menu item from API response
  Map<String, dynamic> _processMenuItem(MenuItem item, String categoryName) {
    return {
      'id': item.id,
      'hotel_owner_id': item.hotelOwnerId,
      'item_name': item.itemName,
      'description': item.description,
      'category_display': categoryName,
      'menu_category_id': item.menuCategoryId,
      'image_url': item.imageUrl,
      'price': item.price,
      'preparation_time': item.preparationTime,
      'is_active': item.isActive,
      'is_featured': item.isFeatured,
      'is_vegetarian': item.isVegetarian,
      'display_order': item.displayOrder,
      'menu_code': item.menuCode,
      'is_available': item.isAvailable,
      'spice_level': item.spiceLevel,
      'quantity': 0, // Initialize quantity
    };
  }

  void _sortAndFilterItems() {
    allItems.sort((a, b) =>
        (a['item_name'] as String).compareTo(b['item_name'] as String));
    _filterItems();
  }

  void _filterItems() {
    if (allItems.isEmpty) {
      filteredItems.value = [];
      return;
    }

    var filtered = allItems.where((item) {
      // Category filter
      bool matchesCategory = selectedCategory.value == 'All' ||
          item['category_display'] == selectedCategory.value;

      // Search filter
      bool matchesSearch = searchQuery.value.isEmpty ||
          (item['item_name'] as String)
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      // Active filters
      bool matchesFilters = true;
      if (activeFilters.contains('Vegetarian')) {
        matchesFilters = matchesFilters && (item['is_vegetarian'] == 1);
      }
      if (activeFilters.contains('Featured')) {
        matchesFilters = matchesFilters && (item['is_featured'] == 1);
      }

      return matchesCategory && matchesSearch && matchesFilters;
    }).toList();

    // Sort filtered items
    filtered.sort((a, b) =>
        (a['item_name'] as String).compareTo(b['item_name'] as String));

    filteredItems.value = filtered;
    developer.log('Filtered: ${filtered.length}/${allItems.length} items');
  }

  void toggleFilter(String filter) {
    if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
    _filterItems();
    developer.log('Filter toggled: $filter');
  }

  void incrementItemQuantity(Map<String, dynamic> item) {
    final index = allItems.indexWhere((el) => el['id'] == item['id']);
    if (index != -1) {
      allItems[index]['quantity'] = (allItems[index]['quantity'] as int) + 1;
      _updateSelectedItems();
      _filterItems();
      developer.log('Incremented ${item['item_name']}');
    }
  }

  void decrementItemQuantity(Map<String, dynamic> item) {
    final index = allItems.indexWhere((el) => el['id'] == item['id']);
    if (index != -1) {
      final currentQty = allItems[index]['quantity'] as int;
      if (currentQty > 0) {
        allItems[index]['quantity'] = currentQty - 1;
        _updateSelectedItems();
        _filterItems();
        developer.log('Decremented ${item['item_name']}');
      }
    }
  }

  void _updateSelectedItems() {
    selectedItems.value =
        allItems.where((item) => (item['quantity'] as int) > 0).toList();
  }

  void addSelectedItemsToTable(BuildContext context) {
    if (selectedItems.isEmpty) {
      SnackBarUtil.showWarning(
        context,
        'Please select at least one item',
        title: 'No Items Selected',
        duration: const Duration(seconds: 1),
      );
      return;
    }

    try {
      final tableId = currentTableId.value;
      final orderController = Get.find<OrderManagementController>();
      final tableState = orderController.getTableState(tableId);

      // ✅ LOG: Check selected items before processing
      developer.log('=== ADDING ITEMS ===');
      developer.log('Total selected items: ${selectedItems.length}');
      developer.log('Selected items: $selectedItems');

      for (var item in selectedItems) {
        final id = item['id'];
        final quantity = item['quantity'] as int;
        final price = double.parse(item['price'].toString());

        // ✅ VALIDATION: Check if id and quantity are valid
        developer.log('Processing item:');
        developer.log('  ID: $id (Type: ${id.runtimeType})');
        developer.log('  Quantity: $quantity (Type: ${quantity.runtimeType})');
        developer.log('  Price: $price');
        developer.log('  Item Name: ${item['item_name']}');

        final orderItem = {
          'id': id,
          'item_name': item['item_name'],
          'price': price,
          'quantity': quantity,
          'category': item['category_display'],
          'description': item['description'] ?? '',
          'preparation_time': item['preparation_time'] ?? 0,
          'is_vegetarian': item['is_vegetarian'] ?? 0,
          'is_featured': item['is_featured'] ?? 0,
          'total_price': price * quantity,
          'added_at': DateTime.now().toIso8601String(),
        };

        developer.log('✅ Order item created: $orderItem');
        tableState.orderItems.add(orderItem);
      }

      _updateTableTotal(tableState);

      final tableNumber = currentTable.value?['tableNumber'] ?? tableId;
      final totalItems = selectedItems.fold<int>(
          0, (sum, item) => sum + (item['quantity'] as int));

      developer.log('✅ SUCCESS: Added $totalItems items to table $tableId');
      developer.log('=== END ADD ITEMS ===');

      SnackBarUtil.showSuccess(
        context,
        '$totalItems items added to Table $tableNumber',
        title: 'Items Added',
        duration: const Duration(seconds: 1),
      );

      clearAllSelections();
      NavigationService.goBack();
    } catch (e) {
      developer.log('❌ ERROR: $e');
      SnackBarUtil.showError(
        context,
        'Failed to add items to order: $e',
        title: 'Error',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _updateTableTotal(TableOrderState tableState) {
    double total = 0.0;
    for (var item in tableState.orderItems) {
      total += item['total_price'] as double;
    }
    tableState.finalCheckoutTotal.value = total;
  }

  int get totalSelectedItems {
    return selectedItems.fold<int>(
        0, (sum, item) => sum + (item['quantity'] as int));
  }

  double get totalSelectedPrice {
    return selectedItems.fold<double>(0.0, (sum, item) {
      final price = double.parse(item['price'].toString());
      final quantity = item['quantity'] as int;
      return sum + (price * quantity);
    });
  }

  void clearAllSelections() {
    for (var item in allItems) {
      item['quantity'] = 0;
    }
    selectedItems.clear();
    _filterItems();
    developer.log('All selections cleared');
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterItems();
  }

  Future<void> refreshCategories() async {
    await loadCategoriesFromAPI();
  }
}



import 'dart:developer' as develeoper;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hotelbilling/app/modules/controllers/select_item_controller.dart';
import 'dart:developer' as developer;
import '../../core/utils/snakbar_utils.dart';
import '../../route/app_routes.dart';

class AddItemsController extends GetxController {
  // Search functionality
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Categories and filtering
  final categories = <String>[].obs;
  final selectedCategory = 'All'.obs;
  final activeFilters = <String>[].obs;

  // Menu data
  final menuData = Rxn<Map<String, dynamic>>();
  final filteredItems = <Map<String, dynamic>>[].obs;
  final allItems = <Map<String, dynamic>>[].obs;

  // Cart/Selected items for current session
  final selectedItems = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isSearching = false.obs;

  // Table context
  final currentTable = Rxn<Map<String, dynamic>>();
  final currentTableId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMenuData();
    _setupSearchListener();
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

  void _loadMenuData() {
    try {
      isLoading.value = true;

      // Enhanced dummy data with more variety
      final mockMenuData = {
        "message": "Menu retrieved successfully",
        "success": true,
        "data": {
          "categories": [
            {
              "category_id": 1,
              "category_name": "Main Course",
              "category_description": "Hearty main dishes",
              "items": [
                {
                  "id": 1,
                  "hotel_owner_id": 1,
                  "item_name": "Chicken Biryani",
                  "description": "Aromatic basmati rice with spiced chicken",
                  "category": "Main Course",
                  "menu_category_id": 1,
                  "image_url": "https://example.com/images/chicken-biryani.jpg",
                  "price": "299.00",
                  "preparation_time": 25,
                  "is_active": 1,
                  "is_featured": 1,
                  "is_vegetarian": 0,
                  "display_order": 1,
                  "created_at": "2025-08-20T08:48:39.000Z",
                  "updated_at": "2025-08-21T11:57:43.000Z"
                },
                {
                  "id": 2,
                  "hotel_owner_id": 1,
                  "item_name": "Butter Chicken",
                  "description": "Creamy tomato-based chicken curry",
                  "category": "Main Course",
                  "menu_category_id": 1,
                  "image_url": "https://example.com/images/butter-chicken.jpg",
                  "price": "319.99",
                  "preparation_time": 18,
                  "is_active": 1,
                  "is_featured": 0,
                  "is_vegetarian": 0,
                  "display_order": 2,
                  "created_at": "2025-08-22T06:29:24.000Z",
                  "updated_at": "2025-08-22T06:38:08.000Z"
                },
                {
                  "id": 3,
                  "hotel_owner_id": 1,
                  "item_name": "Paneer Makhani",
                  "description": "Cottage cheese in rich tomato gravy",
                  "category": "Main Course",
                  "menu_category_id": 1,
                  "image_url": "https://example.com/images/paneer-makhani.jpg",
                  "price": "249.00",
                  "preparation_time": 15,
                  "is_active": 1,
                  "is_featured": 1,
                  "is_vegetarian": 1,
                  "display_order": 3,
                  "created_at": "2025-08-20T08:48:39.000Z",
                  "updated_at": "2025-08-21T11:57:43.000Z"
                }
              ]
            },
            {
              "category_id": 2,
              "category_name": "Beverages",
              "category_description": "Refreshing drinks",
              "items": [
                {
                  "id": 4,
                  "hotel_owner_id": 1,
                  "item_name": "Fresh Lime Soda",
                  "description": "Refreshing lime soda with mint",
                  "category": "Beverages",
                  "menu_category_id": 2,
                  "image_url": "https://example.com/images/lime-soda.jpg",
                  "price": "89.00",
                  "preparation_time": 5,
                  "is_active": 1,
                  "is_featured": 0,
                  "is_vegetarian": 1,
                  "display_order": 1,
                  "created_at": "2025-08-20T08:48:39.000Z",
                  "updated_at": "2025-08-21T11:57:43.000Z"
                },
                {
                  "id": 5,
                  "hotel_owner_id": 1,
                  "item_name": "Masala Chai",
                  "description": "Traditional spiced tea",
                  "category": "Beverages",
                  "menu_category_id": 2,
                  "image_url": "https://example.com/images/masala-chai.jpg",
                  "price": "45.00",
                  "preparation_time": 8,
                  "is_active": 1,
                  "is_featured": 1,
                  "is_vegetarian": 1,
                  "display_order": 2,
                  "created_at": "2025-08-20T08:48:39.000Z",
                  "updated_at": "2025-08-21T11:57:43.000Z"
                }
              ]
            },
            {
              "category_id": 3,
              "category_name": "Appetizers",
              "category_description": "Start your meal right",
              "items": [
                {
                  "id": 6,
                  "hotel_owner_id": 1,
                  "item_name": "Chicken Wings",
                  "description": "Spicy chicken wings with ranch dip",
                  "category": "Appetizers",
                  "menu_category_id": 3,
                  "image_url": "https://example.com/images/chicken-wings.jpg",
                  "price": "189.00",
                  "preparation_time": 12,
                  "is_active": 1,
                  "is_featured": 0,
                  "is_vegetarian": 0,
                  "display_order": 1,
                  "created_at": "2025-08-20T08:48:39.000Z",
                  "updated_at": "2025-08-21T11:57:43.000Z"
                },
                {
                  "id": 7,
                  "hotel_owner_id": 1,
                  "item_name": "Vegetable Samosa",
                  "description": "Crispy pastry filled with spiced vegetables",
                  "category": "Appetizers",
                  "menu_category_id": 3,
                  "image_url": "https://example.com/images/samosa.jpg",
                  "price": "59.00",
                  "preparation_time": 10,
                  "is_active": 1,
                  "is_featured": 1,
                  "is_vegetarian": 1,
                  "display_order": 2,
                  "created_at": "2025-08-20T08:48:39.000Z",
                  "updated_at": "2025-08-21T11:57:43.000Z"
                }
              ]
            }
          ],
          "restaurant_info": {
            "id": 1,
            "organization_name": "Grand Hotel & Restaurant",
            "organization_type": "both",
            "address": "123 Main Street, City, State, 12345",
            "restaurant_address": "123 Main Street, Restaurant Block, City"
          }
        },
        "errors": []
      };

      menuData.value = mockMenuData;
      _processMenuData();

      developer.log('Menu data loaded successfully');
    } catch (e) {
      developer.log('Error loading menu data: $e');
      SnackBarUtil.showError(
        Get.context!,
        'Failed to load menu items',
        title: 'Error',
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _processMenuData() {
    if (menuData.value == null) return;

    final data = menuData.value!['data'] as Map<String, dynamic>;
    final categoriesData = data['categories'] as List<dynamic>;

    // Extract categories - Always start with "All"
    final categorySet = <String>['All'];
    final itemsList = <Map<String, dynamic>>[];

    for (var categoryData in categoriesData) {
      final categoryName = categoryData['category_name'] as String;
      categorySet.add(categoryName);

      final items = categoryData['items'] as List<dynamic>;
      for (var item in items) {
        final processedItem = Map<String, dynamic>.from(item);
        processedItem['category_display'] = categoryName;
        processedItem['quantity'] = 0; // Initialize quantity
        itemsList.add(processedItem);
      }
    }

    // Sort categories alphabetically (except "All" which stays first)
    final otherCategories = categorySet.skip(1).toList();
    otherCategories.sort();
    categories.value = ['All', ...otherCategories];

    // Sort items alphabetically when showing "All"
    itemsList.sort((a, b) =>
        (a['item_name'] as String).compareTo(b['item_name'] as String));

    allItems.value = itemsList;

    // Set initial filtered items
    _filterItems();

    developer.log(
        'Processed ${itemsList.length} items in ${categories.length} categories');
  }

  void _filterItems() {
    if (allItems.isEmpty) return;

    var filtered = allItems.where((item) {
      // Category filter
      bool matchesCategory = selectedCategory.value == 'All' ||
          item['category_display'] == selectedCategory.value;

      // Search filter
      bool matchesSearch = searchQuery.value.isEmpty ||
          (item['item_name'] as String)
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      // Active filters (vegetarian, featured, etc.)
      bool matchesFilters = true;
      if (activeFilters.contains('Vegetarian')) {
        matchesFilters = matchesFilters && (item['is_vegetarian'] == 1);
      }
      if (activeFilters.contains('Featured')) {
        matchesFilters = matchesFilters && (item['is_featured'] == 1);
      }

      return matchesCategory && matchesSearch && matchesFilters;
    }).toList();

    // Sort filtered items alphabetically by name
    filtered.sort((a, b) =>
        (a['item_name'] as String).compareTo(b['item_name'] as String));

    filteredItems.value = filtered;

    developer
        .log('Filtered items: ${filtered.length} out of ${allItems.length}');
  }

  void selectCategory(String category) {
    if (selectedCategory.value != category) {
      selectedCategory.value = category;
      _filterItems();
      developer.log('Category selected: $category');
    }
  }

  void toggleFilter(String filter) {
    if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
    _filterItems();
    developer.log('Filter toggled: $filter, Active filters: $activeFilters');
  }

  void incrementItemQuantity(Map<String, dynamic> item) {
    final index = allItems.indexWhere((element) => element['id'] == item['id']);
    if (index != -1) {
      allItems[index]['quantity'] = (allItems[index]['quantity'] as int) + 1;
      _updateSelectedItems();
      _filterItems(); // Refresh filtered list
      developer.log(
          'Incremented ${item['item_name']} to ${allItems[index]['quantity']}');
    }
  }

  void decrementItemQuantity(Map<String, dynamic> item) {
    final index = allItems.indexWhere((element) => element['id'] == item['id']);
    if (index != -1) {
      final currentQty = allItems[index]['quantity'] as int;
      if (currentQty > 0) {
        allItems[index]['quantity'] = currentQty - 1;
        _updateSelectedItems();
        _filterItems(); // Refresh filtered list
        developer.log(
            'Decremented ${item['item_name']} to ${allItems[index]['quantity']}');
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

      // Get the OrderManagementController instance
      final orderController = Get.find<OrderManagementController>();
      final tableState = orderController.getTableState(tableId);

      developer.log('Adding items to table $tableId');

      // Add selected items to the order management controller
      for (var item in selectedItems) {
        final quantity = item['quantity'] as int;

        // Create order item structure
        final orderItem = {
          'id': item['id'],
          'item_name': item['item_name'],
          'price': double.parse(item['price'].toString()),
          'quantity': quantity,
          'category': item['category_display'],
          'description': item['description'] ?? '',
          'preparation_time': item['preparation_time'] ?? 0,
          'is_vegetarian': item['is_vegetarian'] ?? 0,
          'is_featured': item['is_featured'] ?? 0,
          'total_price': double.parse(item['price'].toString()) * quantity,
          'added_at': DateTime.now().toIso8601String(),
        };

        // Add to table's order items
        tableState.orderItems.add(orderItem);

        developer.log('Added item: ${orderItem['item_name']} x ${orderItem['quantity']} to table $tableId');
      }

      // Update total price
      _updateTableTotal(tableState);

      final tableNumber = currentTable.value?['tableNumber'] ?? tableId;
      final totalItems = selectedItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

      SnackBarUtil.showSuccess(
        context,
        '$totalItems items added to Table $tableNumber',
        title: 'Items Added',
        duration: const Duration(seconds: 1),
      );

      // Clear selections after adding
      clearAllSelections();

      // Navigate back to order management
      NavigationService.goBack();

      developer.log('Successfully added $totalItems items to table $tableId');
    } catch (e) {
      developer.log('Error adding items to table: $e');
      SnackBarUtil.showError(
        context,
        'Failed to add items to order',
        title: 'Error',
        duration: const Duration(seconds: 2),
      );
    }
  }

// Helper method to update table total
  void _updateTableTotal(TableOrderState tableState) {
    double total = 0.0;
    for (var item in tableState.orderItems) {
      total += item['total_price'] as double;
    }
    tableState.finalCheckoutTotal.value = total;
    developer.log('Updated table total: ₹${total.toStringAsFixed(2)}');
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
}

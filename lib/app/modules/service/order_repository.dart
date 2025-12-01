// lib/app/data/repositories/order_repository.dart

import 'dart:developer' as developer;
import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../../data/models/RequestModel/create_order_request.dart';
import '../../data/models/ResponseModel/order_model.dart';


class OrderRepository {
  /// Fetch order details by order ID
  Future<OrderResponseModel> getOrderById(int orderId) async {
    try {
      developer.log(
        'Fetching order with ID: $orderId',
        name: 'ORDER_REPOSITORY',
      );

      final response = await ApiService.get<OrderResponseModel>(
        endpoint: ApiConstants.waiterGetTableOrder(orderId),
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.errorMessage ?? 'Failed to fetch order');
      }

      return response.data!;
    } catch (e) {
      developer.log('Error fetching order: $e', name: 'ORDER_REPOSITORY');
      rethrow;
    }
  }

  /// Create a new order
  Future<OrderResponseModel> createOrder(CreateOrderRequest request) async {
    try {
      developer.log(
        'Creating new order: ${request.toJson()}',
        name: 'ORDER_REPOSITORY',
      );

      final response = await ApiService.post<OrderResponseModel>(
        endpoint: ApiConstants.waiterPostCreateOrder,
        body: request.toJson(),
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.errorMessage ?? 'Failed to create order');
      }

      return response.data!;
    } catch (e) {
      developer.log('Error creating order: $e', name: 'ORDER_REPOSITORY');
      rethrow;
    }
  }

  /// Add items to existing order (Reorder)
  Future<OrderResponseModel> addItemsToOrder(
      int orderId,
      List<Map<String, dynamic>> items,
      ) async {
    try {
      final requestBody = {
        "items": items.map((item) {
          final reorderItem = {
            "menu_item_id": item['id'] as int,
            "quantity": item['quantity'] as int,
          };

          if (item['special_instructions'] != null &&
              item['special_instructions'].toString().trim().isNotEmpty) {
            reorderItem['special_instructions'] =
            item['special_instructions'] as int;
          }

          return reorderItem;
        }).toList(),
      };

      developer.log(
        'Adding items to order $orderId: $requestBody',
        name: 'ORDER_REPOSITORY',
      );

      final response = await ApiService.post<OrderResponseModel>(
        endpoint: ApiConstants.waiterPostReorder(orderId),
        body: requestBody,
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.errorMessage ?? 'Failed to add items to order');
      }

      return response.data!;
    } catch (e) {
      developer.log('Error adding items to order: $e', name: 'ORDER_REPOSITORY');
      rethrow;
    }
  }
}
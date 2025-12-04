// lib/app/data/repositories/ready_order_repository.dart

import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../models/ResponseModel/ready_order_model.dart';

class ReadyOrderRepository {

  /// Fetch ready to serve orders
  Future<ApiResponse<ReadyOrderResponse>> getReadyToServeOrders() async {
    try {
      final response = await ApiService.get<ReadyOrderResponse>(
        endpoint: ApiConstants.waiterGetReadyToServe,
        fromJson: (json) => ReadyOrderResponse.fromJson(json),
        includeToken: true,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to fetch ready orders: ${e.toString()}');
    }
  }


}
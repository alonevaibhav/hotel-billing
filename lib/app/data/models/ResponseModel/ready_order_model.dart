// // lib/app/data/models/ready_order_model.dart
//
// class ReadyOrderResponse {
//   final String message;
//   final bool success;
//   final ReadyOrderData data;
//   final List<dynamic> errors;
//
//   ReadyOrderResponse({
//     required this.message,
//     required this.success,
//     required this.data,
//     required this.errors,
//   });
//
//   factory ReadyOrderResponse.fromJson(Map<String, dynamic> json) {
//     return ReadyOrderResponse(
//       message: json['message'] ?? '',
//       success: json['success'] ?? false,
//       data: ReadyOrderData.fromJson(json['data'] ?? {}),
//       errors: json['errors'] ?? [],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'message': message,
//       'success': success,
//       'data': data.toJson(),
//       'errors': errors,
//     };
//   }
// }
//
// class ReadyOrderData {
//   final List<OrderDetail> orders;
//   final int count;
//
//   ReadyOrderData({
//     required this.orders,
//     required this.count,
//   });
//
//   factory ReadyOrderData.fromJson(Map<String, dynamic> json) {
//     return ReadyOrderData(
//       orders: (json['orders'] as List?)
//           ?.map((order) => OrderDetail.fromJson(order))
//           .toList() ??
//           [],
//       count: json['count'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'orders': orders.map((order) => order.toJson()).toList(),
//       'count': count,
//     };
//   }
// }
//
// class OrderDetail {
//   final Order order;
//   final List<OrderItem> items;
//   final String subtotal;
//   final String taxAmount;
//   final String finalAmount;
//
//   OrderDetail({
//     required this.order,
//     required this.items,
//     required this.subtotal,
//     required this.taxAmount,
//     required this.finalAmount,
//   });
//
//   factory OrderDetail.fromJson(Map<String, dynamic> json) {
//     return OrderDetail(
//       order: Order.fromJson(json['order'] ?? {}),
//       items: (json['items'] as List?)
//           ?.map((item) => OrderItem.fromJson(item))
//           .toList() ??
//           [],
//       subtotal: json['subtotal']?.toString() ?? '0.00',
//       taxAmount: json['tax_amount']?.toString() ?? '0.00',
//       finalAmount: json['final_amount']?.toString() ?? '0.00',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'order': order.toJson(),
//       'items': items.map((item) => item.toJson()).toList(),
//       'subtotal': subtotal,
//       'tax_amount': taxAmount,
//       'final_amount': finalAmount,
//     };
//   }
// }
//
// class Order {
//   final int id;
//   final int hotelOwnerId;
//   final int hotelTableId;
//   final int counterBilling;
//   final String customerName;
//   final String customerPhone;
//   final String paymentMethod;
//   final String? upiId;
//   final String? displayName;
//   final String status;
//   final String? specialInstructions;
//   final String totalAmount;
//   final String taxAmount;
//   final String discount;
//   final String finalAmount;
//   final String createdAt;
//   final String updatedAt;
//   final String billNumber;
//   final int includeGst;
//   final String gstPercentage;
//   final String cgstPercentage;
//   final String sgstPercentage;
//   final String cgstAmount;
//   final String sgstAmount;
//   final String? gstBreakdown;
//   final String tableNumber;
//   final String tableType;
//   final int capacity;
//   final String? tableLocation;
//
//   Order({
//     required this.id,
//     required this.hotelOwnerId,
//     required this.hotelTableId,
//     required this.counterBilling,
//     required this.customerName,
//     required this.customerPhone,
//     required this.paymentMethod,
//     this.upiId,
//     this.displayName,
//     required this.status,
//     this.specialInstructions,
//     required this.totalAmount,
//     required this.taxAmount,
//     required this.discount,
//     required this.finalAmount,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.billNumber,
//     required this.includeGst,
//     required this.gstPercentage,
//     required this.cgstPercentage,
//     required this.sgstPercentage,
//     required this.cgstAmount,
//     required this.sgstAmount,
//     this.gstBreakdown,
//     required this.tableNumber,
//     required this.tableType,
//     required this.capacity,
//     this.tableLocation,
//   });
//
//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       id: json['id'] ?? 0,
//       hotelOwnerId: json['hotel_owner_id'] ?? 0,
//       hotelTableId: json['hotel_table_id'] ?? 0,
//       counterBilling: json['counter_billing'] ?? 0,
//       customerName: json['customer_name'] ?? '',
//       customerPhone: json['customer_phone'] ?? '',
//       paymentMethod: json['payment_method'] ?? '',
//       upiId: json['upi_id'],
//       displayName: json['display_name'],
//       status: json['status'] ?? '',
//       specialInstructions: json['special_instructions'],
//       totalAmount: json['total_amount']?.toString() ?? '0.00',
//       taxAmount: json['tax_amount']?.toString() ?? '0.00',
//       discount: json['discount']?.toString() ?? '0.00',
//       finalAmount: json['final_amount']?.toString() ?? '0.00',
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       billNumber: json['bill_number'] ?? '',
//       includeGst: json['include_gst'] ?? 0,
//       gstPercentage: json['gst_percentage']?.toString() ?? '0.00',
//       cgstPercentage: json['cgst_percentage']?.toString() ?? '0.00',
//       sgstPercentage: json['sgst_percentage']?.toString() ?? '0.00',
//       cgstAmount: json['cgst_amount']?.toString() ?? '0.00',
//       sgstAmount: json['sgst_amount']?.toString() ?? '0.00',
//       gstBreakdown: json['gst_breakdown'],
//       tableNumber: json['table_number']?.toString() ?? '',
//       tableType: json['table_type'] ?? '',
//       capacity: json['capacity'] ?? 0,
//       tableLocation: json['table_location'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'hotel_owner_id': hotelOwnerId,
//       'hotel_table_id': hotelTableId,
//       'counter_billing': counterBilling,
//       'customer_name': customerName,
//       'customer_phone': customerPhone,
//       'payment_method': paymentMethod,
//       'upi_id': upiId,
//       'display_name': displayName,
//       'status': status,
//       'special_instructions': specialInstructions,
//       'total_amount': totalAmount,
//       'tax_amount': taxAmount,
//       'discount': discount,
//       'final_amount': finalAmount,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'bill_number': billNumber,
//       'include_gst': includeGst,
//       'gst_percentage': gstPercentage,
//       'cgst_percentage': cgstPercentage,
//       'sgst_percentage': sgstPercentage,
//       'cgst_amount': cgstAmount,
//       'sgst_amount': sgstAmount,
//       'gst_breakdown': gstBreakdown,
//       'table_number': tableNumber,
//       'table_type': tableType,
//       'capacity': capacity,
//       'table_location': tableLocation,
//     };
//   }
// }
//
// class OrderItem {
//   final int id;
//   final int orderId;
//   final int menuItemId;
//   final int hotelOwnerId;
//   final String itemName;
//   final int quantity;
//   final String unitPrice;
//   final String totalPrice;
//   final String? specialInstructions;
//   final String createdAt;
//   final int isCustomItem;
//
//   OrderItem({
//     required this.id,
//     required this.orderId,
//     required this.menuItemId,
//     required this.hotelOwnerId,
//     required this.itemName,
//     required this.quantity,
//     required this.unitPrice,
//     required this.totalPrice,
//     this.specialInstructions,
//     required this.createdAt,
//     required this.isCustomItem,
//   });
//
//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       id: json['id'] ?? 0,
//       orderId: json['order_id'] ?? 0,
//       menuItemId: json['menu_item_id'] ?? 0,
//       hotelOwnerId: json['hotel_owner_id'] ?? 0,
//       itemName: json['item_name'] ?? '',
//       quantity: json['quantity'] ?? 0,
//       unitPrice: json['unit_price']?.toString() ?? '0.00',
//       totalPrice: json['total_price']?.toString() ?? '0.00',
//       specialInstructions: json['special_instructions'],
//       createdAt: json['created_at'] ?? '',
//       isCustomItem: json['is_custom_item'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'order_id': orderId,
//       'menu_item_id': menuItemId,
//       'hotel_owner_id': hotelOwnerId,
//       'item_name': itemName,
//       'quantity': quantity,
//       'unit_price': unitPrice,
//       'total_price': totalPrice,
//       'special_instructions': specialInstructions,
//       'created_at': createdAt,
//       'is_custom_item': isCustomItem,
//     };
//   }
// }

// lib/app/data/models/ready_order_model.dart

class ReadyOrderResponse {
  final String message;
  final bool success;
  final ReadyOrderData data;
  final List<dynamic> errors;

  ReadyOrderResponse({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory ReadyOrderResponse.fromJson(Map<String, dynamic> json) {
    return ReadyOrderResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: ReadyOrderData.fromJson(json['data'] ?? {}),
      errors: json['errors'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data.toJson(),
      'errors': errors,
    };
  }
}

class ReadyOrderData {
  final List<ReadyOrderItem> items;
  final int total;
  final int pages;

  ReadyOrderData({
    required this.items,
    required this.total,
    required this.pages,
  });

  factory ReadyOrderData.fromJson(Map<String, dynamic> json) {
    return ReadyOrderData(
      items: (json['items'] as List?)
          ?.map((item) => ReadyOrderItem.fromJson(item))
          .toList() ??
          [],
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'pages': pages,
    };
  }
}

class ReadyOrderItem {
  final int id;
  final int orderId;
  final int menuItemId;
  final int hotelOwnerId;
  final String itemName;
  final int quantity;
  final String unitPrice;
  final String totalPrice;
  final String? specialInstructions;
  final String itemStatus;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final int isCustomItem;
  final String customerName;
  final String customerPhone;
  final String tableNumber;
  final int counterBilling;
  final String orderStatus;
  final String orderCreatedAt;

  ReadyOrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.hotelOwnerId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    required this.itemStatus,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isCustomItem,
    required this.customerName,
    required this.customerPhone,
    required this.tableNumber,
    required this.counterBilling,
    required this.orderStatus,
    required this.orderCreatedAt,
  });

  factory ReadyOrderItem.fromJson(Map<String, dynamic> json) {
    return ReadyOrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      menuItemId: json['menu_item_id'] ?? 0,
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      totalPrice: json['total_price']?.toString() ?? '0.00',
      specialInstructions: json['special_instructions'],
      itemStatus: json['item_status'] ?? '',
      createdBy: json['created_by'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isCustomItem: json['is_custom_item'] ?? 0,
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      tableNumber: json['table_number']?.toString() ?? '',
      counterBilling: json['counter_billing'] ?? 0,
      orderStatus: json['order_status'] ?? '',
      orderCreatedAt: json['order_created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'hotel_owner_id': hotelOwnerId,
      'item_name': itemName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'special_instructions': specialInstructions,
      'item_status': itemStatus,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_custom_item': isCustomItem,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'table_number': tableNumber,
      'counter_billing': counterBilling,
      'order_status': orderStatus,
      'order_created_at': orderCreatedAt,
    };
  }
}

// Helper class to group items by order for display purposes
class GroupedOrder {
  final int orderId;
  final String tableNumber;
  final String customerName;
  final String customerPhone;
  final String orderStatus;
  final String orderCreatedAt;
  final int counterBilling;
  final List<ReadyOrderItem> items;

  GroupedOrder({
    required this.orderId,
    required this.tableNumber,
    required this.customerName,
    required this.customerPhone,
    required this.orderStatus,
    required this.orderCreatedAt,
    required this.counterBilling,
    required this.items,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (double.tryParse(item.totalPrice) ?? 0.0));
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  String get billNumber {
    // Generate bill number from order ID or use a placeholder
    return 'ORD-$orderId';
  }
}
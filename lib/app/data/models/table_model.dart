// 1. Model Classes
class TableModel {
  final int id;
  final int hotelOwnerId;
  final String tableNumber;
  final String tableType;
  final int capacity;
  final String status;
  final String description;
  final String location;
  final String createdAt;
  final String updatedAt;

  TableModel({
    required this.id,
    required this.hotelOwnerId,
    required this.tableNumber,
    required this.tableType,
    required this.capacity,
    required this.status,
    required this.description,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      hotelOwnerId: json['hotel_owner_id'],
      tableNumber: json['table_number'],
      tableType: json['table_type'],
      capacity: json['capacity'],
      status: json['status'],
      description: json['description'],
      location: json['location'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class CurrentOrderModel {
  final int orderId;
  final String customerName;
  final String status;
  final String createdAt;

  CurrentOrderModel({
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.createdAt,
  });

  factory CurrentOrderModel.fromJson(Map<String, dynamic> json) {
    return CurrentOrderModel(
      orderId: json['order_id'],
      customerName: json['customer_name'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}

class TableWithOrderModel {
  final TableModel table;
  final CurrentOrderModel? currentOrder;

  TableWithOrderModel({
    required this.table,
    required this.currentOrder,
  });

  factory TableWithOrderModel.fromJson(Map<String, dynamic> json) {
    return TableWithOrderModel(
      table: TableModel.fromJson(json['table']),
      currentOrder: json['current_order'] != null
          ? CurrentOrderModel.fromJson(json['current_order'])
          : null, // ✅ Check if it exists before parsing
    );
  }
}

class TablesResponse {
  final String message;
  final bool success;
  final List<TableWithOrderModel> tables;
  final int total;
  final int pages;
  final List<String> errors;

  TablesResponse({
    required this.message,
    required this.success,
    required this.tables,
    required this.total,
    required this.pages,
    required this.errors,
  });

  factory TablesResponse.fromJson(Map<String, dynamic> json) {
    return TablesResponse(
      message: json['message'],
      success: json['success'],
      tables: (json['data']['tables'] as List)
          .map((table) => TableWithOrderModel.fromJson(table))
          .toList(),
      total: json['data']['total'],
      pages: json['data']['pages'],
      errors: List<String>.from(json['errors']),
    );
  }
}
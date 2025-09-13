// models/login_response_model.dart
class LoginResponseModel {
  final String message;
  final bool success;
  final LoginData data;
  final List<dynamic> errors;

  LoginResponseModel({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: LoginData.fromJson(json['data'] ?? {}),
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

class LoginData {
  final Employee employee;
  final String token;

  LoginData({
    required this.employee,
    required this.token,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      employee: Employee.fromJson(json['employee'] ?? {}),
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee.toJson(),
      'token': token,
    };
  }
}

class Employee {
  final int id;
  final String employeeID;
  final String employeeName;
  final String designation;
  final int roleId;
  final String contact;
  final String email;
  final String address;
  final double salary;
  final String dateOfJoining;
  final String dateOfBirth;
  final String gender;
  final String? profilePicture;
  final String status;
  final int isDeleted;
  final String addedBy;
  final int addedById;
  final String createdAt;
  final String updatedAt;
  final String hotelOwnerName;
  final String organizationName;

  Employee({
    required this.id,
    required this.employeeID,
    required this.employeeName,
    required this.designation,
    required this.roleId,
    required this.contact,
    required this.email,
    required this.address,
    required this.salary,
    required this.dateOfJoining,
    required this.dateOfBirth,
    required this.gender,
    this.profilePicture,
    required this.status,
    required this.isDeleted,
    required this.addedBy,
    required this.addedById,
    required this.createdAt,
    required this.updatedAt,
    required this.hotelOwnerName,
    required this.organizationName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      employeeID: json['employeeID'] ?? '',
      employeeName: json['employeeName'] ?? '',
      designation: json['designation'] ?? '',
      roleId: json['role_id'] ?? 0,
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
      dateOfJoining: json['dateOfJoining'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      profilePicture: json['profilePicture'],
      status: json['status'] ?? '',
      isDeleted: json['is_deleted'] ?? 0,
      addedBy: json['added_by'] ?? '',
      addedById: json['added_by_id'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      hotelOwnerName: json['hotel_owner_name'] ?? '',
      organizationName: json['organization_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeID': employeeID,
      'employeeName': employeeName,
      'designation': designation,
      'role_id': roleId,
      'contact': contact,
      'email': email,
      'address': address,
      'salary': salary,
      'dateOfJoining': dateOfJoining,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'profilePicture': profilePicture,
      'status': status,
      'is_deleted': isDeleted,
      'added_by': addedBy,
      'added_by_id': addedById,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'hotel_owner_name': hotelOwnerName,
      'organization_name': organizationName,
    };
  }

  // Helper methods
  String get fullName => employeeName;
  String get role => designation;
  bool get isActive => status.toLowerCase() == 'active';
  bool get isChef => designation.toLowerCase() == 'chef';
  bool get isWaiter => designation.toLowerCase() == 'waiter';
}


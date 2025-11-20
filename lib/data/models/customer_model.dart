import 'package:posventa/domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    super.id,
    required super.code,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.email,
    super.address,
    super.taxId,
    super.businessName,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      code: json['code'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      taxId: json['tax_id'],
      businessName: json['business_name'],
      isActive: json['is_active'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'tax_id': taxId,
      'business_name': businessName,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      code: customer.code,
      firstName: customer.firstName,
      lastName: customer.lastName,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      taxId: customer.taxId,
      businessName: customer.businessName,
      isActive: customer.isActive,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }
}

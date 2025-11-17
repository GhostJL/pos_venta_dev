import 'package:posventa/domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  SupplierModel({
    super.id,
    required super.name,
    required super.code,
    super.contactPerson,
    super.phone,
    super.email,
    super.address,
    super.taxId,
    super.creditDays,
    super.isActive,
    super.createdAt,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      contactPerson: map['contact_person'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      taxId: map['tax_id'],
      creditDays: map['credit_days'] ?? 0,
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'tax_id': taxId,
      'credit_days': creditDays,
      'is_active': isActive ? 1 : 0,
    };
  }
}

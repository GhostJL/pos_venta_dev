import 'package:posventa/domain/entities/store.dart';

class StoreModel extends Store {
  const StoreModel({
    super.id,
    required super.name,
    super.businessName,
    super.taxId,
    super.address,
    super.phone,
    super.email,
    super.website,
    super.logoPath,
    super.receiptFooter,
    super.currency,
    super.timezone,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'],
      businessName: json['business_name'],
      taxId: json['tax_id'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      logoPath: json['logo_path'],
      receiptFooter: json['receipt_footer'],
      currency: json['currency'],
      timezone: json['timezone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'tax_id': taxId,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'logo_path': logoPath,
      'receipt_footer': receiptFooter,
      'currency': currency,
      'timezone': timezone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StoreModel.fromEntity(Store store) {
    return StoreModel(
      id: store.id,
      name: store.name,
      businessName: store.businessName,
      taxId: store.taxId,
      address: store.address,
      phone: store.phone,
      email: store.email,
      website: store.website,
      logoPath: store.logoPath,
      receiptFooter: store.receiptFooter,
      currency: store.currency,
      timezone: store.timezone,
      createdAt: store.createdAt,
      updatedAt: store.updatedAt,
    );
  }
}

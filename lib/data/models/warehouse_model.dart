
import 'package:posventa/domain/entities/warehouse.dart';

class WarehouseModel extends Warehouse {
  WarehouseModel({
    super.id,
    required super.name,
    required super.code,
    super.address,
    super.phone,
    super.isMain,
    super.isActive,
  });

  factory WarehouseModel.fromMap(Map<String, dynamic> map) {
    return WarehouseModel(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      address: map['address'],
      phone: map['phone'],
      isMain: map['is_main'] == 1,
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'phone': phone,
      'is_main': isMain ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }
}

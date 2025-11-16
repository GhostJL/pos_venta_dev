import 'package:myapp/domain/entities/brand.dart';

class BrandModel extends Brand {
  BrandModel({
    super.id,
    required super.name,
    required super.code,
    super.isActive,
  });

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive ? 1 : 0,
    };
  }
}

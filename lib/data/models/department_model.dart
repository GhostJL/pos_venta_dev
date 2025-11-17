import 'package:posventa/domain/entities/department.dart';

class DepartmentModel extends Department {
  DepartmentModel({
    super.id,
    required super.name,
    required super.code,
    super.description,
    super.displayOrder,
    super.isActive,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      description: map['description'],
      displayOrder: map['display_order'],
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'display_order': displayOrder,
      'is_active': isActive ? 1 : 0,
    };
  }
}

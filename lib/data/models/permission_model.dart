
import 'package:myapp/domain/entities/permission.dart';

class PermissionModel extends Permission {
  PermissionModel({
    super.id,
    required super.name,
    required super.code,
    super.description,
    required super.module,
    super.isActive,
  });

  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      description: map['description'],
      module: map['module'],
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'module': module,
      'is_active': isActive ? 1 : 0,
    };
  }
}

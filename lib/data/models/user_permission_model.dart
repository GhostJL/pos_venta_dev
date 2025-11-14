
import 'package:myapp/domain/entities/user_permission.dart';

class UserPermissionModel extends UserPermission {
  UserPermissionModel({
    required super.userId,
    required super.permissionId,
    required super.grantedAt,
    super.grantedBy,
  });

  factory UserPermissionModel.fromMap(Map<String, dynamic> map) {
    return UserPermissionModel(
      userId: map['user_id'],
      permissionId: map['permission_id'],
      grantedAt: DateTime.parse(map['granted_at']),
      grantedBy: map['granted_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'permission_id': permissionId,
      'granted_at': grantedAt.toIso8601String(),
      'granted_by': grantedBy,
    };
  }
}

import 'package:myapp/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    super.id,
    required super.username,
    required super.email,
    required super.passwordHash,
    required super.firstName,
    required super.lastName,
    super.role,
    super.phone,
    super.isActive,
    super.lastLoginAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['password_hash'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      role: UserRole.values.byName(map['role']),
      phone: map['phone'],
      isActive: map['is_active'] == 1,
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'first_name': firstName,
      'last_name': lastName,
      'role': role.name,
      'phone': phone,
      'is_active': isActive ? 1 : 0,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id == null) {
      map.remove('id');
    }
    return map;
  }
}

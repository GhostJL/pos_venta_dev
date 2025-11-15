import 'package:myapp/domain/entities/user.dart';

extension UserRoleExtension on UserRole {
  String toShortString() {
    return name;
  }
}

class UserModel {
  final int? id;
  final String username;
  final String? email;
  final String? passwordHash;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool isActive;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
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
      isActive: map['is_active'] == 1,
      onboardingCompleted: map['onboarding_completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      passwordHash: entity.passwordHash,
      firstName: entity.firstName,
      lastName: entity.lastName,
      role: entity.role,
      isActive: entity.isActive,
      onboardingCompleted: entity.onboardingCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'first_name': firstName,
      'last_name': lastName,
      'role': role.name,
      'is_active': isActive ? 1 : 0,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      passwordHash: passwordHash,
      firstName: firstName,
      lastName: lastName,
      role: role,
      isActive: isActive,
      onboardingCompleted: onboardingCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? phone,
    bool? isActive,
    bool? onboardingCompleted,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

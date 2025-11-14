enum UserRole { admin, manager, cashier, viewer }

class User {
  final int? id;
  final String username;
  final String email;
  final String? passwordHash;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? phone;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.role = UserRole.cashier,
    this.phone,
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? phone,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

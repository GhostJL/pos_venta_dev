enum UserRole { admin, manager, cashier, viewer }

class User {
  final int? id;
  final String username;
  final String? email;
  final String? passwordHash; // This is for reading, not for writing directly.
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? phone;
  final bool isActive;
  final bool onboardingCompleted;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.username,
    this.email,
    this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.role = UserRole.cashier,
    this.phone,
    this.isActive = true,
    this.onboardingCompleted = false,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Method to convert a User object into a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash, // This might be null if not set yet
      'first_name': firstName,
      'last_name': lastName,
      'role': role.name, // Convert enum to string
      'phone': phone,
      'is_active': isActive ? 1 : 0, // Convert bool to integer
      'onboarding_completed': onboardingCompleted ? 1 : 0,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Factory constructor to create a User from a Map (e.g., from a database query).
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['password_hash'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
      ), // Convert string back to enum
      phone: map['phone'],
      isActive: map['is_active'] == 1, // Convert integer back to bool
      onboardingCompleted: map['onboarding_completed'] == 1,
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

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
    bool? onboardingCompleted,
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
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

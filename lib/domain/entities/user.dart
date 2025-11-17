enum UserRole { administrador, gerente, cajero, espectador }

class User {
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

  User({
    this.id,
    required this.username,
    this.email,
    this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.role = UserRole.cajero,
    this.isActive = true,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['password_hash'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      isActive: map['is_active'] == 1,
      onboardingCompleted: map['onboarding_completed'] == 1,
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
      isActive: isActive ?? this.isActive,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

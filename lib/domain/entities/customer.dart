class Customer {
  final int? id;
  final String code;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final String? businessName;
  final double? creditLimit;
  final double creditUsed;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    this.id,
    required this.code,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.businessName,
    this.creditLimit,
    this.creditUsed = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  Customer copyWith({
    int? id,
    String? code,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? taxId,
    String? businessName,
    double? creditLimit,
    double? creditUsed,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      code: code ?? this.code,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      businessName: businessName ?? this.businessName,
      creditLimit: creditLimit ?? this.creditLimit,
      creditUsed: creditUsed ?? this.creditUsed,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

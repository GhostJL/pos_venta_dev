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
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
}

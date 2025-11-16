class Supplier {
  final int? id;
  final String name;
  final String code;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final int creditDays;
  final bool isActive;
  final DateTime? createdAt;

  Supplier({
    this.id,
    required this.name,
    required this.code,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.creditDays = 0,
    this.isActive = true,
    this.createdAt,
  });

  //copyWith method
  Supplier copyWith({
    int? id,
    String? name,
    String? code,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? taxId,
    int? creditDays,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      creditDays: creditDays ?? this.creditDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

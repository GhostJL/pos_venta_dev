class Store {
  final int? id;
  final String name;
  final String? businessName;
  final String? taxId;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoPath;
  final String? receiptFooter;
  final String? currency;
  final String? timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Store({
    this.id,
    required this.name,
    this.businessName,
    this.taxId,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoPath,
    this.receiptFooter,
    this.currency = 'MXN',
    this.timezone = 'America/Mexico_City',
    required this.createdAt,
    required this.updatedAt,
  });

  Store copyWith({
    int? id,
    String? name,
    String? businessName,
    String? taxId,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoPath,
    String? receiptFooter,
    String? currency,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      taxId: taxId ?? this.taxId,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoPath: logoPath ?? this.logoPath,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

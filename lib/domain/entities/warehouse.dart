class Warehouse {
  final int? id;
  final String name;
  final String code;
  final String? address;
  final String? phone;
  final bool isMain;
  final bool isActive;

  Warehouse({
    this.id,
    required this.name,
    required this.code,
    this.address,
    this.phone,
    this.isMain = false,
    this.isActive = true,
  });

  Warehouse copyWith({
    int? id,
    String? name,
    String? code,
    String? address,
    String? phone,
    bool? isMain,
    bool? isActive,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isMain: isMain ?? this.isMain,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, code: $code, address: $address, phone: $phone, isMain: $isMain, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Warehouse &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.address == address &&
        other.phone == phone &&
        other.isMain == isMain &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        code.hashCode ^
        address.hashCode ^
        phone.hashCode ^
        isMain.hashCode ^
        isActive.hashCode;
  }
}

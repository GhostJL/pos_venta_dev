class TaxRate {
  final int? id;
  final String name;
  final String code;
  final double rate;
  final bool isDefault;
  final bool isActive;
  final bool isEditable;
  final bool isOptional;

  TaxRate({
    this.id,
    required this.name,
    required this.code,
    required this.rate,
    this.isDefault = false,
    this.isActive = true,
    this.isEditable = false,
    this.isOptional = false,
  });

  TaxRate copyWith({
    int? id,
    String? name,
    String? code,
    double? rate,
    bool? isDefault,
    bool? isActive,
    bool? isEditable,
    bool? isOptional,
  }) {
    return TaxRate(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      rate: rate ?? this.rate,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      isEditable: isEditable ?? this.isEditable,
      isOptional: isOptional ?? this.isOptional,
    );
  }
}

import '../../domain/entities/tax_rate.dart';

class TaxRateModel extends TaxRate {
  TaxRateModel({
    super.id,
    required super.name,
    required super.code,
    required super.rate,
    required super.isDefault,
    super.isActive,
  });

  factory TaxRateModel.fromJson(Map<String, dynamic> json) {
    return TaxRateModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      rate: (json['rate'] as num).toDouble(),
      isDefault: json['is_default'] == 1,
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'rate': rate,
      'is_default': isDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory TaxRateModel.fromEntity(TaxRate entity) {
    return TaxRateModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      rate: entity.rate,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
    );
  }

  TaxRate toEntity() {
    return TaxRate(
      id: id,
      name: name,
      code: code,
      rate: rate,
      isDefault: isDefault,
      isActive: isActive,
    );
  }
}

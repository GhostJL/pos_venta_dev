import 'package:posventa/domain/entities/discount.dart';

class DiscountModel extends Discount {
  const DiscountModel({
    required super.id,
    required super.name,
    required super.type,
    required super.value,
    super.startDate,
    super.endDate,
    required super.isActive,
    required super.createdAt,
  });

  factory DiscountModel.fromEntity(Discount discount) {
    return DiscountModel(
      id: discount.id,
      name: discount.name,
      type: discount.type,
      value: discount.value,
      startDate: discount.startDate,
      endDate: discount.endDate,
      isActive: discount.isActive,
      createdAt: discount.createdAt,
    );
  }

  // Map from Drift Row (Discount in AppDatabase is actually generated as 'Discount')
  // But wait, generated class is 'Discount'. My Entity is 'Discount'.
  // This is a conflict.
  // I will assume the generated class is aliased on import in the Datasource,
  // or I use 'd.Discount' where 'd' is database import.
  // Here I don't need to depend on Drift class if I map in Datasource.
  // But usually Models have `fromTable` or similar.
  // I'll keep it simple: generic factory or just use constructor in Datasource.
}

import 'package:equatable/equatable.dart';

enum DiscountType { percentage, amount }

class Discount extends Equatable {
  final int id;
  final String name;
  final DiscountType type;
  final int value; // cents or basis points (e.g. 1000 = 10.00%)
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  const Discount({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    value,
    startDate,
    endDate,
    isActive,
    createdAt,
  ];

  double get valueAsDouble {
    if (type == DiscountType.percentage) {
      return value / 10000.0; // 1000 -> 0.10
    } else {
      return value / 100.0; // 1000 -> 10.00
    }
  }
}

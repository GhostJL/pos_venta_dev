import 'package:flutter/foundation.dart';

@immutable
class UnitOfMeasure {
  final int? id;
  final String code;
  final String name;

  const UnitOfMeasure({this.id, required this.code, required this.name});

  UnitOfMeasure copyWith({int? id, String? code, String? name}) {
    return UnitOfMeasure(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }
}

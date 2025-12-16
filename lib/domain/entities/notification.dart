import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final int? id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'low_stock', 'out_of_stock'
  final int? relatedProductId;
  final int? relatedVariantId;

  const AppNotification({
    this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.relatedProductId,
    this.relatedVariantId,
  });

  AppNotification copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    int? relatedProductId,
    int? relatedVariantId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      relatedProductId: relatedProductId ?? this.relatedProductId,
      relatedVariantId: relatedVariantId ?? this.relatedVariantId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    timestamp,
    isRead,
    type,
    relatedProductId,
    relatedVariantId,
  ];
}

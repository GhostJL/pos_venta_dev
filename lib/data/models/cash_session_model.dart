import 'package:posventa/domain/entities/cash_session.dart';

class CashSessionModel extends CashSession {
  CashSessionModel({
    super.id,
    required super.warehouseId,
    required super.userId,
    required super.openingBalanceCents,
    super.closingBalanceCents,
    super.expectedBalanceCents,
    super.differenceCents,
    required super.status,
    required super.openedAt,
    super.closedAt,
    super.notes,
    super.userName,
  });

  factory CashSessionModel.fromMap(Map<String, dynamic> map) {
    return CashSessionModel(
      id: map['id'],
      warehouseId: map['warehouse_id'],
      userId: map['user_id'],
      openingBalanceCents: map['opening_balance_cents'],
      closingBalanceCents: map['closing_balance_cents'],
      expectedBalanceCents: map['expected_balance_cents'],
      differenceCents: map['difference_cents'],
      status: map['status'],
      openedAt: DateTime.parse(map['opened_at']),
      closedAt: map['closed_at'] != null
          ? DateTime.parse(map['closed_at'])
          : null,
      notes: map['notes'],
      userName: _buildUserName(map),
    );
  }

  static String? _buildUserName(Map<String, dynamic> map) {
    final firstName = map['first_name'] as String?;
    final lastName = map['last_name'] as String?;
    final username = map['username'] as String?;

    if (firstName != null && firstName.isNotEmpty) {
      if (lastName != null && lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName;
    }
    return username;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'warehouse_id': warehouseId,
      'user_id': userId,
      'opening_balance_cents': openingBalanceCents,
      'closing_balance_cents': closingBalanceCents,
      'expected_balance_cents': expectedBalanceCents,
      'difference_cents': differenceCents,
      'status': status,
      'opened_at': openedAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

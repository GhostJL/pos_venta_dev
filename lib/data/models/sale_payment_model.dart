import 'package:posventa/domain/entities/sale_payment.dart';

class SalePaymentModel extends SalePayment {
  const SalePaymentModel({
    super.id,
    super.saleId,
    required super.paymentMethod,
    required super.amountCents,
    super.referenceNumber,
    required super.paymentDate,
    required super.receivedBy,
  });

  factory SalePaymentModel.fromJson(Map<String, dynamic> json) {
    return SalePaymentModel(
      id: json['id'],
      saleId: json['sale_id'],
      paymentMethod: json['payment_method'],
      amountCents: json['amount_cents'],
      referenceNumber: json['reference_number'],
      paymentDate: DateTime.parse(json['payment_date']),
      receivedBy: json['received_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'payment_method': paymentMethod,
      'amount_cents': amountCents,
      'reference_number': referenceNumber,
      'payment_date': paymentDate.toIso8601String(),
      'received_by': receivedBy,
    };
  }

  factory SalePaymentModel.fromEntity(SalePayment payment) {
    return SalePaymentModel(
      id: payment.id,
      saleId: payment.saleId,
      paymentMethod: payment.paymentMethod,
      amountCents: payment.amountCents,
      referenceNumber: payment.referenceNumber,
      paymentDate: payment.paymentDate,
      receivedBy: payment.receivedBy,
    );
  }
}

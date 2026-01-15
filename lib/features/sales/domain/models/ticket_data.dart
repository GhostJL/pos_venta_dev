import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';

class TicketData {
  final Sale sale;
  final List<SaleItem> items;
  final String storeName;
  final String? storeBusinessName;
  final String storeAddress;
  final String storePhone;
  final String? storeTaxId;
  final String? storeEmail;
  final String? storeWebsite;
  final String? storeLogoPath;
  final String? footerMessage;
  final String? cashierName;

  // Calculated fields
  double get total => sale.totalCents / 100.0;
  double get subtotal => sale.subtotalCents / 100.0;
  double get tax => sale.taxCents / 100.0;
  double get discount =>
      0.0; // Assuming discount not tracked separately in Sale object yet

  double get amountReceived {
    if (sale.payments.isEmpty) return 0.0;
    return sale.payments.fold(0.0, (sum, p) => sum + p.amount);
  }

  double get change {
    if (sale.payments.isEmpty) return 0.0;
    final received = amountReceived;
    return received > total ? received - total : 0.0;
  }

  String get paymentMethod {
    if (sale.payments.isEmpty) return 'No registrado';
    return sale.payments.map((p) => p.paymentMethod).toSet().join(', ');
  }

  const TicketData({
    required this.sale,
    required this.items,
    this.storeName = 'Mi Tienda POS',
    this.storeBusinessName,
    this.storeAddress = 'Dirección Desconocida',
    this.storePhone = '',
    this.storeTaxId,
    this.storeEmail,
    this.storeWebsite,
    this.storeLogoPath,
    this.footerMessage = '¡Gracias por su compra!',
    this.cashierName,
  });
}

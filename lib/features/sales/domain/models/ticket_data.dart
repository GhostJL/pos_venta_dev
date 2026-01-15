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

  // Calculated fields
  double get total => sale.totalCents / 100.0;
  double get subtotal => sale.subtotalCents / 100.0;
  double get tax => sale.taxCents / 100.0;
  double get discount => 0.0;

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
  });
}

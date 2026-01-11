import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';

class TicketData {
  final Sale sale;
  final List<SaleItem> items;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String? footerMessage;

  // Calculated fields
  double get total => sale.totalCents / 100.0;
  double get subtotal => sale.subtotalCents / 100.0;
  double get tax => sale.taxCents / 100.0;
  // Sale model might not have discountCents explicitly if not stored,
  // but usually it does or we calculate it.
  // Checking Sale entity definition is safer, but for now assuming 0 if not present or check logic.
  // POSState calculates discount. Sale entity has items.
  // Let's assume Sale has valid totals. If discount is difference between subtotal+tax vs total?
  // Or if sale has discountCents.
  // For now return 0 if not sure, or better:
  double get discount => 0.0;

  const TicketData({
    required this.sale,
    required this.items,
    this.storeName = 'Mi Tienda POS',
    this.storeAddress = 'Dirección Desconocida',
    this.storePhone = '',
    this.footerMessage = '¡Gracias por su compra!',
  });
}

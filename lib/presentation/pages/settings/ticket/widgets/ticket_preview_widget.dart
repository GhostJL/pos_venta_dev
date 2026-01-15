import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/store.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketPreviewWidget extends StatelessWidget {
  final Store store;

  const TicketPreviewWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    // 80mm roll is roughly 300-320 pixel width simulation
    const double receiptWidth = 300.0;

    // Base style for the receipt
    final TextStyle receiptStyle = GoogleFonts.courierPrime(
      fontSize: 10, // Small, like a real receipt
      color: Colors.black,
      height: 1.1,
    );

    final TextStyle headerStyle = GoogleFonts.courierPrime(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    final TextStyle boldStyle = GoogleFonts.courierPrime(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Center(
      child: Container(
        width: receiptWidth,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- TOP PAPER TEAR ---
            SizedBox(
              height: 12,
              child: CustomPaint(
                painter: const _ZigZagPainter(
                  color: Colors.white,
                  invert: true,
                ),
                size: const Size(receiptWidth, 12),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER ---
                  const SizedBox(height: 8),
                  if (store.logoPath != null && store.logoPath!.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.saturation,
                        ),
                        child: Image.file(
                          File(store.logoPath!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.store_rounded,
                      size: 40,
                      color: Colors.black87,
                    ),

                  const SizedBox(height: 8),
                  Text(
                    store.name.toUpperCase(),
                    style: headerStyle,
                    textAlign: TextAlign.center,
                  ),

                  if (store.businessName != null &&
                      store.businessName!.isNotEmpty)
                    Text(
                      store.businessName!,
                      style: receiptStyle,
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 4),
                  if (store.address != null && store.address!.isNotEmpty)
                    Text(
                      store.address!,
                      style: receiptStyle,
                      textAlign: TextAlign.center,
                    ),

                  if (store.phone != null && store.phone!.isNotEmpty)
                    Text(
                      'Tel: ${store.phone}',
                      style: receiptStyle,
                      textAlign: TextAlign.center,
                    ),

                  if (store.taxId != null && store.taxId!.isNotEmpty)
                    Text(
                      'RFC: ${store.taxId}',
                      style: receiptStyle,
                      textAlign: TextAlign.center,
                    ),

                  if (store.email != null && store.email!.isNotEmpty)
                    Text(
                      store.email!,
                      style: receiptStyle,
                      textAlign: TextAlign.center,
                    ),

                  if (store.website != null && store.website!.isNotEmpty)
                    Text(
                      store.website!,
                      style: receiptStyle,
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 8),
                  const _DashedDivider(),
                  const SizedBox(height: 8),

                  // --- METADATA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fecha:', style: receiptStyle),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                        style: receiptStyle,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ticket:', style: receiptStyle),
                      Text('A-000123', style: boldStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cajero:', style: receiptStyle),
                      Text('Administrador', style: receiptStyle),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const _DashedDivider(),
                  const SizedBox(height: 4),

                  // --- ITEMS HEADER ---
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text('CANT', style: boldStyle),
                      ),
                      Expanded(child: Text('DESCRIPCION', style: boldStyle)),
                      SizedBox(
                        width: 60,
                        child: Text(
                          'IMPORTE',
                          style: boldStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const _DashedDivider(),
                  const SizedBox(height: 4),

                  // --- ITEMS MOCK ---
                  _buildMockItem(
                    qty: '1.00',
                    desc: 'COCA COLA 600ML NUEVA FORMULA',
                    price: '18.00',
                    total: '18.00',
                    style: receiptStyle,
                  ),
                  _buildMockItem(
                    qty: '2.00',
                    desc: 'SABRITAS ORIGINAL 45G',
                    price: '16.00',
                    total: '32.00',
                    style: receiptStyle,
                  ),
                  _buildMockItem(
                    qty: '0.50',
                    desc: 'JAMON PAVO A GRANEL (KG)',
                    price: '120.00',
                    total: '60.00',
                    style: receiptStyle,
                  ),
                  _buildMockItem(
                    qty: '1.00',
                    desc: 'GALLETAS MARIAS PAQUETE',
                    price: '15.50',
                    total: '15.50',
                    style: receiptStyle,
                  ),

                  const SizedBox(height: 8),
                  const _DashedDivider(),
                  const SizedBox(height: 8),

                  // --- TOTALS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SUBTOTAL:', style: receiptStyle),
                      Text('\$125.50', style: receiptStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('IVA:', style: receiptStyle),
                      Text('\$0.00', style: receiptStyle),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL:',
                        style: GoogleFonts.courierPrime(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '\$125.50',
                        style: GoogleFonts.courierPrime(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Su Pago:', style: receiptStyle),
                      Text('\$200.00', style: receiptStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cambio:', style: receiptStyle),
                      Text('\$74.50', style: receiptStyle),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const _DashedDivider(),
                  const SizedBox(height: 16),

                  // --- FOOTER ---
                  if (store.receiptFooter != null &&
                      store.receiptFooter!.isNotEmpty)
                    Text(
                      store.receiptFooter!,
                      style: receiptStyle.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      '¡GRACIAS POR SU COMPRA!',
                      style: receiptStyle,
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      height: 50,
                      width: 150,
                      color: Colors.black, // Mock barcode
                      alignment: Alignment.center,
                      child: Text(
                        'BARCODE 128',
                        style: GoogleFonts.courierPrime(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A-000123456789',
                    style: receiptStyle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // --- BOTTOM PAPER TEAR ---
            SizedBox(
              height: 12,
              child: CustomPaint(
                painter: const _ZigZagPainter(
                  color: Colors.white,
                  invert: false,
                ),
                size: const Size(receiptWidth, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockItem({
    required String qty,
    required String desc,
    required String price,
    required String total,
    required TextStyle style,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(desc, style: style),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$qty x \$$price', style: style),
              Text('\$$total', style: style),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider(); // const constructor

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black54),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ZigZagPainter extends CustomPainter {
  final Color color;
  final bool invert;

  const _ZigZagPainter({required this.color, this.invert = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // Zigzag dimensions
    const step = 10.0;
    final steps = (size.width / step).ceil();

    if (invert) {
      // Top edge zigzag
      path.moveTo(0, size.height);
      for (int i = 0; i < steps; i++) {
        double x = i * step;
        path.lineTo(x + step / 2, 0);
        path.lineTo(x + step, size.height);
      }
      path.close();
    } else {
      // Bottom edge zigzag
      path.moveTo(0, 0);
      for (int i = 0; i < steps; i++) {
        double x = i * step;
        path.lineTo(x + step / 2, size.height);
        path.lineTo(x + step, 0);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

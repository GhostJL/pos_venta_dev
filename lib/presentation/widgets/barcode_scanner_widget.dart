import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posventa/app/theme.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(BuildContext context, String barcode) onBarcodeScanned;
  final String? title;
  final String? hint;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeScanned,
    this.title,
    this.hint,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.code128],
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    // Vibrar para feedback
    // HapticFeedback.mediumImpact();

    widget.onBarcodeScanned(context, barcode.rawValue!);

    // Pequeño delay para evitar escaneos duplicados
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title ?? 'Escanear Código de Barras'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
            tooltip: 'Flash',
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
            tooltip: 'Cambiar cámara',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(controller: cameraController, onDetect: _handleBarcode),

          // Overlay con área de escaneo
          CustomPaint(painter: ScannerOverlayPainter(), child: Container()),

          // Instrucciones
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isProcessing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Código detectado',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.hint ??
                              'Coloca el código de barras dentro del marco',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'EAN-13, EAN-8, Code 128',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaWidth = size.width * 0.8;
    final double scanAreaHeight = size.height * 0.3;
    final double left = (size.width - scanAreaWidth) / 2;
    final double top = (size.height - scanAreaHeight) / 2;

    // Fondo oscuro
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaRect = Rect.fromLTWH(
      left,
      top,
      scanAreaWidth,
      scanAreaHeight,
    );

    // Dibujar fondo con agujero
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(12)),
        ),
      ),
      backgroundPaint,
    );

    // Esquinas del marco
    final cornerPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;

    // Esquina superior izquierda
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      cornerPaint,
    );

    // Esquina superior derecha
    canvas.drawLine(
      Offset(left + scanAreaWidth, top),
      Offset(left + scanAreaWidth - cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top),
      Offset(left + scanAreaWidth, top + cornerLength),
      cornerPaint,
    );

    // Esquina inferior izquierda
    canvas.drawLine(
      Offset(left, top + scanAreaHeight),
      Offset(left + cornerLength, top + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaHeight),
      Offset(left, top + scanAreaHeight - cornerLength),
      cornerPaint,
    );

    // Esquina inferior derecha
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + scanAreaHeight),
      Offset(left + scanAreaWidth - cornerLength, top + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + scanAreaHeight),
      Offset(left + scanAreaWidth, top + scanAreaHeight - cornerLength),
      cornerPaint,
    );

    // Línea de escaneo animada (opcional, se puede animar con AnimationController)
    final scanLinePaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(left, top + scanAreaHeight / 2 - 1, scanAreaWidth, 2),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

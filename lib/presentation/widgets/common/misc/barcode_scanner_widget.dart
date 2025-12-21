import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posventa/presentation/widgets/common/misc/scanner_arguments.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(BuildContext context, String barcode) onBarcodeScanned;
  final String? title;
  final String? hint;
  final ScannerArguments? args;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeScanned,
    this.title,
    this.hint,
    this.args,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.code128],
  );

  late AudioPlayer _audioPlayer;

  bool _isProcessing = false;
  int _scannedCount = 0;
  Timer? _inactivityTimer;
  String? _lastScannedMessage;
  bool _lastScanSuccess = true;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    cameraController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    // Solo activar timer si estamos en modo batch (callback provided)
    if (widget.args?.onScan != null) {
      _inactivityTimer = Timer(const Duration(seconds: 30), () {
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  Future<void> _playSound(bool success) async {
    try {
      if (success) {
        await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
      } else {
        // Optional: Error sound
        // await _audioPlayer.play(AssetSource('sounds/error.mp3'));
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _handleBarcode(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    final String code = barcode.rawValue!;

    // Manual Debounce Logic for same code
    if (code == _lastScannedCode &&
        _lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) <
            const Duration(seconds: 1)) {
      return;
    }

    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    _resetInactivityTimer();

    // Update debounce info
    _lastScannedCode = code;
    _lastScanTime = DateTime.now();

    // Batch Mode
    if (widget.args?.onScan != null) {
      final (success, message) = await widget.args!.onScan!(context, code);

      if (mounted) {
        if (success) _playSound(true);

        setState(() {
          _lastScanSuccess = success;
          if (success) {
            _scannedCount++;
          } else {
            _isProcessing = false; // Allow retrying immediately if needed
          }
          _lastScannedMessage = message;

          // Show message for 400ms but allow next scan if different code
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _isProcessing = false;
                _lastScannedMessage = null;
              });
            }
          });
        });

        // IMPORTANT: Allow scanning different code immediately
      }
    } else {
      // Single Mode (Default)
      if (!mounted) return;
      _playSound(true);
      widget.onBarcodeScanned(context, code);

      // Delay handled by caller or router pop generally, but here for safety
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.args?.titleOverride ?? widget.title ?? 'Escanear Código',
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
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

          // Feedback & Instrucciones
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
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Batch Mode Counter & Status
                  if (widget.args?.onScan != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _lastScannedMessage != null
                            ? (_lastScanSuccess
                                  ? Colors.green.withValues(alpha: 0.8)
                                  : Colors.red.withValues(alpha: 0.8))
                            : Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _lastScannedMessage != null
                                ? (_lastScanSuccess
                                      ? Icons.check_circle
                                      : Icons.error)
                                : Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _lastScannedMessage ??
                                  'Productos escaneados: $_scannedCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Finalizar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Single Mode Feedback
                    if (_isProcessing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Código detectado',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        widget.hint ?? 'Coloca el código dentro del marco',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
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
      ..color = Colors.black.withValues(alpha: 0.5)
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
      ..color = Colors.white.withValues(alpha: 0.2)
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

    // Línea de escaneo (visual only)
    final scanLinePaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(left, top + scanAreaHeight / 2 - 1, scanAreaWidth, 2),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

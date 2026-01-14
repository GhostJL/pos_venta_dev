import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:posventa/presentation/providers/di/printer_di.dart';

/// A widget that displays the current printer connection status.
/// Shows different states: not configured, connected, or disconnected.
class PrinterStatusIndicator extends ConsumerWidget {
  final bool showLabel;

  const PrinterStatusIndicator({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) {
        final printerName = settings.printerName;

        if (printerName == null || printerName.isEmpty) {
          return _buildStatusChip(
            context,
            icon: Icons.print_disabled,
            label: 'Impresora no configurada',
            color: Colors.grey,
          );
        }

        // On Android, we can check Bluetooth connection
        // On Desktop, check if printer is actually available
        if (Platform.isAndroid) {
          return FutureBuilder(
            future: _checkPrinterConnection(ref, printerName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildStatusChip(
                  context,
                  icon: Icons.sync,
                  label: 'Verificando...',
                  color: Colors.orange,
                );
              }

              final isConnected = snapshot.data ?? false;
              return _buildStatusChip(
                context,
                icon: isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                label: isConnected ? 'Conectado: $printerName' : 'Desconectado',
                color: isConnected ? Colors.green : Colors.red,
              );
            },
          );
        } else {
          // Desktop - check if printer is actually available and not a PDF virtual printer
          return FutureBuilder(
            future: _checkDesktopPrinterStatus(ref, printerName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildStatusChip(
                  context,
                  icon: Icons.sync,
                  label: 'Verificando...',
                  color: Colors.orange,
                );
              }

              final status = snapshot.data ?? _PrinterStatus.notFound;

              switch (status) {
                case _PrinterStatus.connected:
                  return _buildStatusChip(
                    context,
                    icon: Icons.print,
                    label: 'Conectado: $printerName',
                    color: Colors.green,
                  );
                case _PrinterStatus.configured:
                  return _buildStatusChip(
                    context,
                    icon: Icons.print,
                    label: 'Configurada: $printerName',
                    color: Colors.blue,
                  );
                case _PrinterStatus.disconnected:
                  return _buildStatusChip(
                    context,
                    icon: Icons.print_disabled,
                    label: 'Desconectado: $printerName',
                    color: Colors.red,
                  );
                case _PrinterStatus.pdfVirtual:
                  return _buildStatusChip(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: 'Impresora virtual (PDF)',
                    color: Colors.orange,
                  );
                case _PrinterStatus.notFound:
                  return _buildStatusChip(
                    context,
                    icon: Icons.error_outline,
                    label: 'No encontrada: $printerName',
                    color: Colors.red,
                  );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    if (!showLabel) {
      return Icon(icon, color: color, size: 20);
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  Future<bool> _checkPrinterConnection(
    WidgetRef ref,
    String printerName,
  ) async {
    try {
      final printerService = ref.read(printerServiceProvider);
      final printers = await printerService.getPrinters();
      return printers.any((p) => p.name == printerName);
    } catch (e) {
      return false;
    }
  }

  Future<_PrinterStatus> _checkDesktopPrinterStatus(
    WidgetRef ref,
    String printerName,
  ) async {
    try {
      final printerService = ref.read(printerServiceProvider);
      final printers = await printerService.getPrinters();

      final printer = printers.where((p) => p.name == printerName).firstOrNull;

      if (printer == null) {
        return _PrinterStatus.notFound;
      }

      // Check if it's a PDF virtual printer
      final lowerName = printer.name.toLowerCase();
      final isPdfPrinter =
          lowerName.contains('pdf') ||
          lowerName.contains('microsoft print to pdf') ||
          lowerName.contains('adobe pdf') ||
          lowerName.contains('foxit') ||
          lowerName.contains('cutepdf') ||
          lowerName.contains('novapdf');

      if (isPdfPrinter) {
        return _PrinterStatus.pdfVirtual;
      }

      // For physical printers on Windows/Desktop:
      // We can only verify if the printer is INSTALLED in the system
      // We CANNOT verify if it's actually powered on or connected
      // So we return 'configured' status instead of 'connected'
      return _PrinterStatus.configured;
    } catch (e) {
      return _PrinterStatus.notFound;
    }
  }
}

enum _PrinterStatus {
  connected, // Only used for Android Bluetooth (can verify actual connection)
  configured, // Used for Desktop (printer installed but connection unknown)
  disconnected, // Not currently used
  pdfVirtual,
  notFound,
}

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
        // On Desktop, we assume it's available if configured
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
          // Desktop - assume available if configured
          return _buildStatusChip(
            context,
            icon: Icons.print,
            label: 'Configurado: $printerName',
            color: Colors.green,
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
}

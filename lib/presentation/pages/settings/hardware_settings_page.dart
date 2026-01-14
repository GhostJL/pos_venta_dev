import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:posventa/presentation/providers/di/printer_di.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

class HardwareSettingsPage extends ConsumerStatefulWidget {
  const HardwareSettingsPage({super.key});

  @override
  ConsumerState<HardwareSettingsPage> createState() =>
      _HardwareSettingsPageState();
}

class _HardwareSettingsPageState extends ConsumerState<HardwareSettingsPage> {
  List<Printer> _printers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  Future<void> _loadPrinters() async {
    try {
      final service = ref.read(printerServiceProvider);
      final printers = await service.getPrinters();
      if (mounted) {
        setState(() {
          _printers = printers;
          _isLoading = false;
        });
      }
    } on MissingPluginException {
      // Catch specific plugin error (usually happens during dev if not rebuilt)
      // We treat this as "no printers found" but with a gentle warning or silent fail
      // rather than a crash/scary error.
      if (mounted) {
        setState(() {
          _printers = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo acceder al servicio de impresión.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando impresoras: $e')),
        );
      }
      debugPrint('Error loading printers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    // Filter validation for paper width
    final paperWidths = [58, 80];

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Hardware')),
      body: settingsAsync.when(
        data: (settings) {
          final currentPrinter = settings.printerName;
          final currentWidth = settings.paperWidthMm;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeader(
                      theme,
                      Platform.isAndroid
                          ? 'Impresoras Bluetooth'
                          : 'Impresora de Tickets',
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : _loadPrinters,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualizar lista',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_printers.isEmpty)
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.print_disabled,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No se encontraron impresoras.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Asegúrese de que la impresora esté encendida, conectada y configurada en los ajustes del sistema de su dispositivo.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          if (Platform.isAndroid)
                            const Text(
                              'En Android, asegúrese de que el Bluetooth esté encendido y la impresora esté emparejada en los ajustes del sistema.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Seleccionar Impresora'),
                          subtitle: Text(
                            currentPrinter ?? 'Ninguna seleccionada',
                          ),
                          trailing: const Icon(Icons.print),
                        ),
                        const Divider(),
                        RadioGroup<String?>(
                          groupValue: currentPrinter,
                          onChanged: (value) async {
                            if (value != null) {
                              final selectedPrinter = _printers.firstWhere(
                                (p) => p.name == value,
                                orElse: () => Printer(url: '', name: value),
                              );

                              await ref
                                  .read(settingsProvider.notifier)
                                  .updateSettings(
                                    settings.copyWith(
                                      printerName: selectedPrinter.name,
                                      printerAddress: selectedPrinter.url,
                                    ),
                                  );
                            }
                          },
                          child: Column(
                            children: _printers.map((printer) {
                              return RadioListTile<String?>(
                                title: Text(printer.name),
                                subtitle: Text(printer.url),
                                value: printer.name,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildHeader(theme, 'Ancho del Papel'),
                  const SizedBox(height: 16),
                  Card(
                    child: RadioGroup<int>(
                      groupValue: currentWidth,
                      onChanged: (value) async {
                        if (value != null) {
                          await ref
                              .read(settingsProvider.notifier)
                              .updateSettings(
                                settings.copyWith(paperWidthMm: value),
                              );
                        }
                      },
                      child: Column(
                        children: paperWidths.map((width) {
                          return RadioListTile<int>(
                            title: Text('$width mm'),
                            value: width,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final service = ref.read(printerServiceProvider);
                        // Ideally we would pass the selected printer here, but the service mainly uses defaults or searches.
                        // For testing, we might want to ensure we target the selected one.
                        // We rely on the service implementation to handle direct printing if passed.
                        // For now, let's just trigger a test print.
                        // We need to find the Printer object that matches the name.
                        final printerObj = _printers.firstWhere(
                          (p) => p.name == currentPrinter,
                          orElse: () => const Printer(url: 'default'),
                        );

                        if (currentPrinter == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Seleccione una impresora primero'),
                            ),
                          );
                          return;
                        }

                        try {
                          await service.testPrint(printer: printerObj);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prueba de impresión enviada'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al imprimir: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Probar Impresión'),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildHeader(theme, 'Escáneres y Lectores'),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prueba de Escáner USB / Teclado',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Escanea un código aquí...',
                              suffixIcon: Icon(Icons.qr_code_scanner),
                            ),
                            onSubmitted: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Código escaneado (USB): $value',
                                  ),
                                ),
                              );
                            },
                          ),
                          if (Platform.isAndroid || Platform.isIOS) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Escáner de Cámara',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              onPressed: () async {
                                try {
                                  // Navigate to scanner page
                                  final result = await context.push('/scanner');
                                  if (result != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Código escaneado (Cámara): $result',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error al abrir el escáner: $e. Verifique los permisos de cámara.',
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Abrir Escáner de Cámara'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

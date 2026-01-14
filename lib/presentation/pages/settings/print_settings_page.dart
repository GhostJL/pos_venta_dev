import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/utils/file_manager_service.dart';
import 'package:posventa/presentation/pages/settings/widgets/settings_components.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

class PrintSettingsPage extends ConsumerStatefulWidget {
  const PrintSettingsPage({super.key});

  @override
  ConsumerState<PrintSettingsPage> createState() => _PrintSettingsPageState();
}

class _PrintSettingsPageState extends ConsumerState<PrintSettingsPage> {
  bool _isLoadingSpace = false;
  int? _availableSpace;

  @override
  void initState() {
    super.initState();
    _loadAvailableSpace();
  }

  Future<void> _loadAvailableSpace() async {
    setState(() => _isLoadingSpace = true);
    try {
      final settings = await ref.read(settingsProvider.future);
      final pdfPath =
          settings.pdfSavePath ??
          await FileManagerService.getDefaultPdfSavePath();
      final space = await FileManagerService.getAvailableSpace(pdfPath);
      if (mounted) {
        setState(() {
          _availableSpace = space;
          _isLoadingSpace = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSpace = false);
      }
    }
  }

  Future<void> _selectPdfSavePath() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Seleccionar carpeta para PDFs',
      );

      if (result != null) {
        // Validate path
        final isValid = await FileManagerService.validatePath(result);
        if (!isValid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'La ruta seleccionada no es válida o no tiene permisos de escritura',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Update settings
        final settings = await ref.read(settingsProvider.future);
        await ref
            .read(settingsProvider.notifier)
            .updateSettings(settings.copyWith(pdfSavePath: result));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ruta de PDFs actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAvailableSpace();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar ruta: $e')),
        );
      }
    }
  }

  Future<void> _resetPdfSavePath() async {
    try {
      final settings = await ref.read(settingsProvider.future);
      await ref
          .read(settingsProvider.notifier)
          .updateSettings(settings.copyWith(pdfSavePath: null));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ruta de PDFs restablecida a la predeterminada'),
          ),
        );
        _loadAvailableSpace();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al restablecer ruta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Impresión')),
      body: settingsAsync.when(
        data: (settings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Print Enable/Disable Section
                _buildHeader(theme, 'Control de Impresión'),
                const SizedBox(height: 8),
                const Text(
                  'Habilite o deshabilite la impresión automática de tickets y comprobantes. Cuando está deshabilitada, los documentos se guardarán como PDF.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SettingsSectionContainer(
                  children: [
                    SwitchListTile(
                      title: const Text('Imprimir Tickets de Venta'),
                      subtitle: const Text(
                        'Imprimir automáticamente al completar una venta',
                      ),
                      value: settings.enableSalesPrinting,
                      onChanged: (value) async {
                        await ref
                            .read(settingsProvider.notifier)
                            .updateSettings(
                              settings.copyWith(enableSalesPrinting: value),
                            );
                      },
                      secondary: const Icon(Icons.receipt_long),
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      title: const Text('Imprimir Comprobantes de Abono'),
                      subtitle: const Text(
                        'Imprimir automáticamente al registrar un pago',
                      ),
                      value: settings.enablePaymentPrinting,
                      onChanged: (value) async {
                        await ref
                            .read(settingsProvider.notifier)
                            .updateSettings(
                              settings.copyWith(enablePaymentPrinting: value),
                            );
                      },
                      secondary: const Icon(Icons.payment),
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      title: const Text('Guardar PDF Automáticamente'),
                      subtitle: const Text(
                        'Guardar PDF cuando la impresión está deshabilitada',
                      ),
                      value: settings.autoSavePdfWhenPrintDisabled,
                      onChanged: (value) async {
                        await ref
                            .read(settingsProvider.notifier)
                            .updateSettings(
                              settings.copyWith(
                                autoSavePdfWhenPrintDisabled: value,
                              ),
                            );
                      },
                      secondary: const Icon(Icons.save_alt),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // PDF Save Path Section
                _buildHeader(theme, 'Ubicación de PDFs Guardados'),
                const SizedBox(height: 16),
                SettingsSectionContainer(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.folder_outlined,
                        color: Colors.blue,
                      ),
                      title: const Text('Ruta Actual'),
                      subtitle: FutureBuilder<String>(
                        future: settings.pdfSavePath != null
                            ? Future.value(settings.pdfSavePath!)
                            : FileManagerService.getDefaultPdfSavePath(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (settings.pdfSavePath == null)
                                  const Text(
                                    '(Ruta predeterminada)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            );
                          }
                          return const Text('Cargando...');
                        },
                      ),
                    ),
                    if (_availableSpace != null) ...[
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.storage, color: Colors.green),
                        title: const Text('Espacio Disponible'),
                        subtitle: Text(
                          FileManagerService.formatBytes(_availableSpace!),
                        ),
                      ),
                    ],
                    if (_isLoadingSpace) ...[
                      const Divider(height: 1, indent: 56),
                      const ListTile(
                        leading: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        title: Text('Calculando espacio disponible...'),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectPdfSavePath,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Cambiar Ruta'),
                      ),
                    ),
                    if (settings.pdfSavePath != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _resetPdfSavePath,
                          icon: const Icon(Icons.restore),
                          label: const Text('Restablecer'),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // Info Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Los PDFs se organizan automáticamente en carpetas por año y mes para facilitar su gestión.',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:posventa/presentation/providers/bulk_import_provider.dart';

class BulkImportPage extends ConsumerWidget {
  const BulkImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bulkImportProvider);
    final notifier = ref.read(bulkImportProvider.notifier);
    final theme = Theme.of(context);

    // Effect for success/error
    ref.listen(bulkImportProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
      if (next.isSuccess && !previous!.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Productos importados exitosamente'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
        notifier.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Productos'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instructions Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Icon(
                      Icons.help_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'Instrucciones de Importación',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Guía para preparar tu archivo CSV',
                      style: theme.textTheme.bodySmall,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTip(
                              context,
                              'Departamentos y Categorías',
                              'Si ingresas un nombre que no existe, el sistema lo creará automáticamente. Usa nombres claros (Ej: "Bebidas", "Lácteos").',
                            ),
                            const SizedBox(height: 12),
                            _buildTip(
                              context,
                              'Venta por Peso (Booleanos)',
                              'Usa "1" para Sí (Verdadero) y "0" para No (Falso) en la columna "Se Vende Por Peso".',
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: state.isLoading
                                  ? null
                                  : () => _downloadTemplate(context, ref),
                              icon: const Icon(Icons.download_rounded),
                              label: const Text('Descargar Plantilla CSV'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // File Selection
                if (state.selectedFile == null)
                  Container(
                    height: 200, // Fixed height for the drop zone area visuals
                    alignment: Alignment.center,
                    child: FilledButton.icon(
                      onPressed: state.isLoading ? null : notifier.pickFile,
                      icon: state.isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.folder_open_rounded),
                      label: Text(
                        state.isLoading
                            ? 'Procesando...'
                            : 'Seleccionar Archivo CSV',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  )
                else ...[
                  // File Info
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(
                      state.selectedFile!.path
                          .split(Platform.pathSeparator)
                          .last,
                    ),
                    subtitle: Text(
                      '${state.validProducts.length} productos válidos detectados',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: notifier.clear,
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Validation List
                  if (state.errors.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.errorContainer,
                        ),
                      ),
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(12),
                        itemCount: state.errors.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 16,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errors[index],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 100), // Spacer replacement

                  const SizedBox(height: 16),

                  // Action Button
                  FilledButton(
                    onPressed:
                        (state.isUploading || state.validProducts.isEmpty)
                        ? null
                        : notifier.uploadProducts,
                    child: state.isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Importar ${state.validProducts.length} Productos',
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadTemplate(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final service = ref.read(bulkImportServiceProvider);
      final csvData = service.getTemplateCsv();

      // Convert to bytes for cross-platform support (esp. mobile)
      final List<int> bytes = utf8.encode(csvData);

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar Plantilla CSV',
        fileName: 'plantilla_productos.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: Uint8List.fromList(bytes), // Required on Android/iOS
      );

      if (outputFile != null) {
        // Ensure extension
        final path = outputFile.endsWith('.csv')
            ? outputFile
            : '$outputFile.csv';

        // on Android/iOS, saveFile with 'bytes' writes the file key.
        // On Desktop, it returns the path and we must write it.
        if (!Platform.isAndroid && !Platform.isIOS) {
          final file = File(path);
          await file.writeAsString(csvData);
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text('Plantilla guardada exitosamente en:\n$path'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Descarga cancelada por el usuario'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error downloading template: $e");
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTip(BuildContext context, String title, String description) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

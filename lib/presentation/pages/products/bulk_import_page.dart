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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Carga masiva de productos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sube un archivo CSV para importar productos a tu catálogo. Si no especificas departamento o categoría, se asignará "General" por defecto.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => _downloadTemplate(context, ref),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Descargar Plantilla CSV'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        foregroundColor: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // File Selection
            if (state.selectedFile == null)
              Expanded(
                child: Center(
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
                ),
              )
            else ...[
              // File Info
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(
                  state.selectedFile!.path.split(Platform.pathSeparator).last,
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
                Expanded(
                  child: Container(
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
                  ),
                )
              else
                const Spacer(),

              const SizedBox(height: 16),

              // Action Button
              FilledButton(
                onPressed: (state.isUploading || state.validProducts.isEmpty)
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
                    : Text('Importar ${state.validProducts.length} Productos'),
              ),
            ],
          ],
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
}

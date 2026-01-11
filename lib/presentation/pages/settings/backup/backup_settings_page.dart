import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/settings/backup/backup_controller.dart';
import 'package:posventa/presentation/pages/settings/widgets/settings_components.dart';

class BackupSettingsPage extends ConsumerWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to controller state for error handling or success messages
    ref.listen(backupControllerProvider, (previous, next) {
      next.when(
        data: (_) {
          // If we transition from loading to data, it might mean success
          if (previous?.isLoading == true && !next.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Operación completada con éxito')),
            );
          }
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${err.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        loading: () {},
      );
    });

    final state = ref.watch(backupControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Respaldo y Restauración')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestiona el respaldo de tu base de datos local. Es recomendable exportar periódicamente tus datos para evitar pérdidas.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            SettingsSectionContainer(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.upload_file_rounded,
                    color: Colors.blue,
                  ),
                  title: const Text('Exportar Base de Datos'),
                  subtitle: const Text(
                    'Guarda una copia de seguridad en tu dispositivo',
                  ),
                  trailing: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: isLoading
                      ? null
                      : () {
                          ref
                              .read(backupControllerProvider.notifier)
                              .exportDatabase();
                        },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    Icons.download_rounded,
                    color: Colors.orange,
                  ),
                  title: const Text('Restaurar Base de Datos'),
                  subtitle: const Text(
                    'Importa una copia de seguridad existente',
                  ),
                  trailing: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: isLoading ? null : () => _confirmRestore(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Advertencia: Restaurar una base de datos sobrescribirá TODOS los datos actuales. Asegúrate de respaldar tu información actual antes de restaurar.',
                      style: TextStyle(color: Colors.brown[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Base de Datos?'),
        content: const Text(
          'Esta acción REEMPLAZARÁ toda la información actual con la del archivo de respaldo. \n\nEsta acción no se puede deshacer.\n\n¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(backupControllerProvider.notifier).importDatabase();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Restaurar'),
          ),
        ],
      ),
    );
  }
}

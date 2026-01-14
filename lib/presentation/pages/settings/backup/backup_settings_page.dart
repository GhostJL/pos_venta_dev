import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/settings/backup/backup_controller.dart';
import 'package:posventa/presentation/pages/settings/widgets/settings_components.dart';
import 'package:posventa/presentation/providers/backup_state_provider.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

class BackupSettingsPage extends ConsumerWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar cambios de estado para feedback UI
    ref.listen<BackupState>(backupControllerProvider, (previous, next) {
      // 1. Manejar transición a Loading
      if (next.status == BackupStatus.loading) {
        if (previous?.status != BackupStatus.loading) {
          _showLoadingDialog(context, next.message ?? 'Procesando...');
        }
      }

      // 2. Manejar salida de Loading (Cerrar diálogo de carga)
      if (previous?.status == BackupStatus.loading &&
          next.status != BackupStatus.loading) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // 3. Manejar Éxito
      if (next.status == BackupStatus.success) {
        _showSuccessDialog(
          context,
          next.title ?? 'Operación Exitosa',
          next.message ?? 'Tarea completada correctamente.',
          onDismiss: () {
            // Si es restauración, reiniciar. Si es exportación, solo resetear estado.
            if (next.title?.toLowerCase().contains('restauración') ?? false) {
              ref.read(backupControllerProvider.notifier).restartApp();
            } else {
              ref.read(backupControllerProvider.notifier).resetState();
            }
          },
        );
      }

      // 4. Manejar Error
      if (next.status == BackupStatus.error) {
        _showErrorDialog(context, next.message ?? 'Error desconocido');
        ref.read(backupControllerProvider.notifier).resetState();
      }
    });

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
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _handleExport(context, ref),
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
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _confirmRestore(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Automatic Backup Configuration Section
            Text(
              'Configuración de Backups Automáticos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            SettingsSectionContainer(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final settingsAsync = ref.watch(settingsProvider);
                    return settingsAsync.when(
                      data: (settings) {
                        return Column(
                          children: [
                            SwitchListTile(
                              secondary: const Icon(
                                Icons.schedule,
                                color: Colors.blue,
                              ),
                              title: const Text('Backups Automáticos'),
                              subtitle: Text(
                                settings.autoBackupEnabled
                                    ? 'Activado - ${settings.autoBackupTimes.length} horarios configurados'
                                    : 'Desactivado',
                              ),
                              value: settings.autoBackupEnabled,
                              onChanged: (value) async {
                                await ref
                                    .read(settingsProvider.notifier)
                                    .updateSettings(
                                      settings.copyWith(
                                        autoBackupEnabled: value,
                                      ),
                                    );
                              },
                            ),
                            if (settings.autoBackupEnabled) ...[
                              const Divider(height: 1, indent: 56),
                              ListTile(
                                leading: const Icon(
                                  Icons.access_time,
                                  color: Colors.green,
                                ),
                                title: const Text('Horarios de Backup'),
                                subtitle: Text(
                                  settings.autoBackupTimes.isEmpty
                                      ? 'No hay horarios configurados'
                                      : settings.autoBackupTimes.join(', '),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () =>
                                    _showScheduleDialog(context, ref, settings),
                              ),
                            ],

                            const Divider(height: 1, indent: 56),
                            SwitchListTile(
                              secondary: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: const Text('Backup al Cerrar Sesión'),
                              subtitle: const Text(
                                'Preguntar si desea hacer backup al cerrar sesión',
                              ),
                              value: settings.backupOnLogout,
                              onChanged: (value) async {
                                await ref
                                    .read(settingsProvider.notifier)
                                    .updateSettings(
                                      settings.copyWith(backupOnLogout: value),
                                    );
                              },
                            ),
                            if (settings.lastBackupTime != null) ...[
                              const Divider(height: 1, indent: 56),
                              ListTile(
                                leading: const Icon(
                                  Icons.history,
                                  color: Colors.grey,
                                ),
                                title: const Text('Último Backup'),
                                subtitle: Text(
                                  _formatDateTime(settings.lastBackupTime!),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const ListTile(
                        title: Text('Error al cargar configuración'),
                      ),
                    );
                  },
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _showScheduleDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
  ) async {
    final times = List<String>.from(settings.autoBackupTimes);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Horarios de Backup'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (times.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay horarios configurados'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: times.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(times[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              times.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final timeString =
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  if (!times.contains(timeString)) {
                    setState(() {
                      times.add(timeString);
                      times.sort();
                    });
                  }
                }
              },
              child: const Text('Agregar Horario'),
            ),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(settingsProvider.notifier)
                    .updateSettings(settings.copyWith(autoBackupTimes: times));
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
    await ref.read(backupControllerProvider.notifier).executeExport();
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
            onPressed: () async {
              Navigator.pop(context); // Cierra diálogo de confirmación
              final path = await ref
                  .read(backupControllerProvider.notifier)
                  .pickImportPath();

              if (path == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Restauración cancelada'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                }
                return;
              }
              // Ejecuta importación, el listener manejará el loading/success
              ref.read(backupControllerProvider.notifier).executeImport(path);
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

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Procesando',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(title),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(); // Use root navigator explicitly
              Future.delayed(const Duration(milliseconds: 300), () {
                onDismiss?.call();
              });
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      useRootNavigator: true, // Also use root navigator for error
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('Error'),
        content: Text(
          'Ha ocurrido un error durante el proceso: \n\n$error',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

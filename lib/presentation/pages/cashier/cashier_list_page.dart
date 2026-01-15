import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/widgets/users/admin_change_password_dialog.dart';

class CashierListPage extends ConsumerWidget {
  const CashierListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashiersAsync = ref.watch(cashierListProvider);
    final authState = ref.watch(authProvider);

    if (authState.user?.role != UserRole.administrador) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Acceso denegado. Solo administradores.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Cajeros')),
      body: cashiersAsync.when(
        data: (cashiers) {
          if (cashiers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay cajeros registrados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cashiers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cashier = cashiers[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      cashier.firstName[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '${cashier.firstName} ${cashier.lastName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'change_password':
                          _showChangePasswordDialog(context, ref, cashier);
                          break;
                        case 'permissions':
                          context.push('/cashiers/permissions', extra: cashier);
                          break;
                        case 'edit':
                          context.push('/cashiers/form', extra: cashier);
                          break;
                        case 'delete':
                          _confirmDelete(context, ref, cashier);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'change_password',
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_reset_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text('Cambiar Contraseña'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'permissions',
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text('Permisos'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            const Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            const Text('Eliminar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/cashiers/form');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Cajero'),
      ),
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
    User cashier,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<bool>(
      context: context,
      builder: (context) => AdminChangePasswordDialog(user: cashier),
    ).then((result) {
      if (result == true) {
        // Refresh the cashier list
        ref.invalidate(cashierListProvider);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Contraseña actualizada para ${cashier.name}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            showCloseIcon: true,
          ),
        );
      }
    });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, User cashier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cajero'),
        content: Text(
          '¿Está seguro de eliminar al cajero ${cashier.username}?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              ref
                  .read(cashierControllerProvider.notifier)
                  .deleteCashier(cashier.id!);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cajero eliminado correctamente'),
                  backgroundColor: AppTheme.transactionSuccess,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

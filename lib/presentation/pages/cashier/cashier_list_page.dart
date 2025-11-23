import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

class CashierListPage extends ConsumerWidget {
  const CashierListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashiersAsync = ref.watch(cashierListProvider);
    final authState = ref.watch(authProvider);

    if (authState.user?.role != UserRole.administrador) {
      return const Scaffold(
        body: Center(child: Text('Acceso denegado. Solo administradores.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Cajeros')),
      body: cashiersAsync.when(
        data: (cashiers) {
          if (cashiers.isEmpty) {
            return const Center(child: Text('No hay cajeros registrados.'));
          }
          return ListView.builder(
            itemCount: cashiers.length,
            itemBuilder: (context, index) {
              final cashier = cashiers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(cashier.firstName[0].toUpperCase()),
                  ),
                  title: Text('${cashier.firstName} ${cashier.lastName}'),
                  subtitle: Text(cashier.username),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.security),
                        tooltip: 'Permisos',
                        onPressed: () {
                          context.push('/cashiers/permissions', extra: cashier);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        onPressed: () {
                          context.push('/cashiers/form', extra: cashier);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Eliminar',
                        onPressed: () => _confirmDelete(context, ref, cashier),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/cashiers/form');
        },
        child: const Icon(Icons.add),
      ),
    );
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
          TextButton(
            onPressed: () {
              ref
                  .read(cashierControllerProvider.notifier)
                  .deleteCashier(cashier.id!);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cajero eliminado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

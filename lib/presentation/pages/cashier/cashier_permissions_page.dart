import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';

class CashierPermissionsPage extends ConsumerStatefulWidget {
  final User cashier;

  const CashierPermissionsPage({super.key, required this.cashier});

  @override
  ConsumerState<CashierPermissionsPage> createState() =>
      _CashierPermissionsPageState();
}

class _CashierPermissionsPageState
    extends ConsumerState<CashierPermissionsPage> {
  final Set<int> _selectedPermissionIds = {};
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final allPermissionsAsync = ref.watch(allPermissionsProvider);
    final cashierPermissionsAsync = ref.watch(
      cashierPermissionsProvider(widget.cashier.id!),
    );
    final controllerState = ref.watch(cashierControllerProvider);

    ref.listen(cashierControllerProvider, (previous, next) {
      if (next is AsyncData && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Permisos actualizados')));
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Permisos de ${widget.cashier.username}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: controllerState.isLoading ? null : _savePermissions,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: allPermissionsAsync.when(
        data: (allPermissions) {
          return cashierPermissionsAsync.when(
            data: (cashierPermissions) {
              if (!_isInitialized) {
                _selectedPermissionIds.addAll(
                  cashierPermissions.map((p) => p.id!),
                );
                _isInitialized = true;
              }

              // Agrupar permisos por módulo
              final Map<String, List<Permission>> groupedPermissions = {};
              for (var perm in allPermissions) {
                groupedPermissions.putIfAbsent(perm.module, () => []);
                groupedPermissions[perm.module]!.add(perm);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: groupedPermissions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = groupedPermissions.entries.elementAt(index);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...entry.value.map((perm) {
                            final isSelected = _selectedPermissionIds.contains(
                              perm.id,
                            );
                            return CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                perm.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              subtitle: perm.description != null
                                  ? Text(
                                      perm.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  : null,
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedPermissionIds.add(perm.id!);
                                  } else {
                                    _selectedPermissionIds.remove(perm.id);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error cargando permisos: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error cargando permisos: $err')),
      ),
    );
  }

  void _savePermissions() {
    ref
        .read(cashierControllerProvider.notifier)
        .updatePermissions(widget.cashier.id!, _selectedPermissionIds.toList());
  }
}

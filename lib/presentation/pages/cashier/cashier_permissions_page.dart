import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: controllerState.isLoading ? null : _savePermissions,
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

              // Group permissions by module
              final Map<String, List<Permission>> groupedPermissions = {};
              for (var perm in allPermissions) {
                if (!groupedPermissions.containsKey(perm.module)) {
                  groupedPermissions[perm.module] = [];
                }
                groupedPermissions[perm.module]!.add(perm);
              }

              return ListView(
                children: groupedPermissions.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ...entry.value.map((perm) {
                        return CheckboxListTile(
                          title: Text(perm.name),
                          subtitle: Text(perm.description ?? ''),
                          value: _selectedPermissionIds.contains(perm.id),
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
                      const Divider(),
                    ],
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Error cargando permisos del usuario: $err'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error cargando permisos: $err')),
      ),
    );
  }

  void _savePermissions() {
    final authState = ref.read(authProvider);
    final currentUserId = authState.user?.id;

    ref
        .read(cashierControllerProvider.notifier)
        .updatePermissions(
          widget.cashier.id!,
          _selectedPermissionIds.toList(),
          currentUserId,
        );
  }
}

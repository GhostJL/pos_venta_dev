import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';

class PermissionSelectorWidget extends ConsumerStatefulWidget {
  final List<int> selectedPermissionIds;
  final ValueChanged<List<int>> onChanged;
  final List<String>? visiblePermissionCodes;

  const PermissionSelectorWidget({
    super.key,
    required this.selectedPermissionIds,
    required this.onChanged,
    this.visiblePermissionCodes,
  });

  @override
  ConsumerState<PermissionSelectorWidget> createState() =>
      _PermissionSelectorWidgetState();
}

class _PermissionSelectorWidgetState
    extends ConsumerState<PermissionSelectorWidget> {
  // We keep a local copy to update UI instantly, but sync with parent via onChanged
  late List<int> _currentSelectedIds;

  @override
  void initState() {
    super.initState();
    _currentSelectedIds = List.from(widget.selectedPermissionIds);
  }

  @override
  void didUpdateWidget(covariant PermissionSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPermissionIds != widget.selectedPermissionIds) {
      _currentSelectedIds = List.from(widget.selectedPermissionIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPermissionsAsync = ref.watch(allPermissionsProvider);

    return allPermissionsAsync.when(
      data: (allPermissions) {
        // Filter permissions if visiblePermissionCodes is provided
        final visiblePermissions = widget.visiblePermissionCodes == null
            ? allPermissions
            : allPermissions
                  .where((p) => widget.visiblePermissionCodes!.contains(p.code))
                  .toList();

        // Group permissions by module
        final Map<String, List<Permission>> groupedPermissions = {};
        for (var perm in visiblePermissions) {
          groupedPermissions.putIfAbsent(perm.module, () => []);
          groupedPermissions[perm.module]!.add(perm);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permisos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groupedPermissions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = groupedPermissions.entries.elementAt(index);
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map((perm) {
                          final isSelected = _currentSelectedIds.contains(
                            perm.id,
                          );
                          return CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              perm.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
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
                                  _currentSelectedIds.add(perm.id!);
                                } else {
                                  _currentSelectedIds.remove(perm.id);
                                }
                                widget.onChanged(_currentSelectedIds);
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error cargando permisos: $err',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:posventa/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.role == UserRole.administrador;
    final settingsAsync = ref.watch(settingsProvider);

    // Build the sections dynamically based on permissions/role if needed
    // For now, we follow the plan which focuses on Admin configuration mainly

    // Only admins should really be here based on the menu config plan,
    // but good to have safety checks or show limited options if needed.

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'), centerTitle: false),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout determination
          final isWide = constraints.maxWidth > 600;
          final crossAxisCount = isWide ? 2 : 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAdmin) ...[
                  _SettingsSection(
                    title: 'General',
                    children: [
                      _SettingsGrid(
                        crossAxisCount: crossAxisCount,
                        children: [
                          _SettingsCard(
                            icon: Icons.store_mall_directory_rounded,
                            title: 'Mi Tienda',
                            subtitle: 'Información del negocio',
                            onTap: () => context.push('/store'),
                          ),
                          _SettingsCard(
                            icon: Icons.warehouse_rounded,
                            title: 'Almacenes',
                            subtitle: 'Gestión de ubicaciones físicas',
                            onTap: () => context.push('/warehouses'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SettingsSection(
                    title: 'Preferencias del Sistema',
                    children: [
                      settingsAsync.when(
                        data: (settings) => Card(
                          elevation: 0,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text('Gestionar Inventario'),
                                subtitle: const Text(
                                  'Activa o desactiva el control de stock',
                                ),
                                value: settings.useInventory,
                                onChanged: (val) {
                                  if (!val) {
                                    _showConfirmationDialog(
                                      context,
                                      title: '¿Desactivar Inventario?',
                                      content:
                                          'Al desactivar el inventario, todo el stock actual se eliminará y pasará a 0. Esta acción no se puede deshacer.',
                                      confirmText:
                                          'Desactivar y Eliminar Stock',
                                      onConfirm: () {
                                        ref
                                            .read(settingsProvider.notifier)
                                            .toggleInventory(false);
                                      },
                                    );
                                  } else {
                                    ref
                                        .read(settingsProvider.notifier)
                                        .toggleInventory(true);
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                              SwitchListTile(
                                title: const Text('Gestionar Impuestos (IVA)'),
                                subtitle: const Text(
                                  'Habilita el cálculo y gestión de impuestos',
                                ),
                                value: settings.useTax,
                                onChanged: (val) {
                                  if (!val) {
                                    _showConfirmationDialog(
                                      context,
                                      title: '¿Desactivar Impuestos?',
                                      content:
                                          'Al desactivar los impuestos, todas las ventas futuras se procesarán como exentas (sin impuestos).',
                                      confirmText: 'Desactivar',
                                      onConfirm: () {
                                        ref
                                            .read(settingsProvider.notifier)
                                            .toggleTax(false);
                                      },
                                    );
                                  } else {
                                    ref
                                        .read(settingsProvider.notifier)
                                        .toggleTax(true);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error: $err'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SettingsSection(
                    title: 'Catálogo',
                    children: [
                      _SettingsGrid(
                        crossAxisCount: crossAxisCount,
                        children: [
                          _SettingsCard(
                            icon: Icons.category_rounded,
                            title: 'Categorías',
                            subtitle: 'Organización de productos',
                            onTap: () => context.push('/categories'),
                          ),
                          _SettingsCard(
                            icon: Icons.apartment_rounded,
                            title: 'Departamentos',
                            subtitle: 'Clasificación de alto nivel',
                            onTap: () => context.push('/departments'),
                          ),
                          _SettingsCard(
                            icon: Icons.label_rounded,
                            title: 'Marcas',
                            subtitle: 'Fabricantes y marcas',
                            onTap: () => context.push('/brands'),
                          ),
                          _SettingsCard(
                            icon: Icons.price_change_rounded,
                            title: 'Tasas de Impuesto',
                            subtitle: 'Configuración fiscal',
                            onTap: () => context.push('/tax-rates'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SettingsSection(
                    title: 'Usuarios y Seguridad',
                    children: [
                      _SettingsGrid(
                        crossAxisCount: crossAxisCount,
                        children: [
                          _SettingsCard(
                            icon: Icons.people_alt_rounded,
                            title: 'Usuarios',
                            subtitle: 'Gestión de personal y cajeros',
                            onTap: () => context.push('/cashiers'),
                          ),
                          // Add more user-related settings here if needed
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsGrid extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;

  const _SettingsGrid({required this.crossAxisCount, required this.children});

  @override
  Widget build(BuildContext context) {
    if (crossAxisCount == 1) {
      return Column(
        children: children
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: c,
              ),
            )
            .toList(),
      );
    }

    // Simple Grid implementation using Wrap or Row for basic responses
    // Or actual GridView if we wanted fixed heights, but Cards vary.
    // Let's use a Wrap for flexibility or Staggered approach manually.
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children.map((child) {
        return SizedBox(
          width:
              (MediaQuery.of(context).size.width - 48) /
              2, // approximate half width minus padding
          child: child,
        );
      }).toList(),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

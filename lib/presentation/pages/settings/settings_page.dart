import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/user.dart';

import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:posventa/presentation/pages/settings/widgets/settings_components.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.role == UserRole.administrador;
    final settingsAsync = ref.watch(settingsProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      appBar: AppBar(
        leading: isSmallScreen
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => MainLayout.of(context)?.openDrawer(),
              )
            : null,
        title: const Text('Configuración'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin) ...[
              const SettingsHeader(title: 'General'),
              SettingsSectionContainer(
                children: [
                  SettingsCategoryTile(
                    icon: Icons.store_mall_directory_rounded,
                    title: 'Mi Tienda',
                    subtitle: 'Información del negocio',
                    onTap: () => context.push('/store'),
                  ),
                  const Divider(height: 1, indent: 56),
                  // Ticket configuration
                  SettingsCategoryTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'Ticket',
                    subtitle: 'Mensaje de pie de página',
                    onTap: () => context.push('/settings/ticket'),
                  ),
                  const Divider(height: 1, indent: 56),
                  SettingsCategoryTile(
                    icon: Icons.warehouse_rounded,
                    title: 'Almacenes',
                    subtitle: 'Gestión de ubicaciones físicas',
                    onTap: () => context.push('/warehouses'),
                  ),
                ],
              ),

              const SettingsHeader(title: 'Sistema'),
              settingsAsync.when(
                data: (settings) => SettingsSectionContainer(
                  children: [
                    SettingsCategoryTile(
                      icon: Icons.save_alt_rounded,
                      title: 'Respaldo y Restauración',
                      subtitle: 'Exportar o importar base de datos',
                      onTap: () => context.push('/settings/backup'),
                    ),
                    const Divider(height: 1, indent: 56),
                    SettingsCategoryTile(
                      icon: Icons.print_rounded,
                      title: 'Hardware e Impresoras',
                      subtitle: 'Configurar impresoras y periféricos',
                      onTap: () => context.push('/settings/hardware'),
                    ),
                    const Divider(height: 1, indent: 56),
                    SettingsCategoryTile(
                      icon: Icons.print_outlined,
                      title: 'Configuración de Impresión',
                      subtitle: 'Control de impresión y guardado de PDFs',
                      onTap: () => context.push('/settings/print'),
                    ),
                    const Divider(height: 1, indent: 56),
                    SettingsToggleTile(
                      title: 'Gestionar Inventario',
                      subtitle: 'Activa o desactiva el control de stock',
                      value: settings.useInventory,
                      onChanged: (val) {
                        if (!val) {
                          _showConfirmationDialog(
                            context,
                            title: '¿Desactivar Inventario?',
                            content:
                                'Al desactivar el inventario, todo el stock actual se eliminará y pasará a 0. Esta acción no se puede deshacer.',
                            confirmText: 'Desactivar y Eliminar Stock',
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
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsToggleTile(
                      title: 'Gestionar Impuestos (IVA)',
                      subtitle: 'Habilita el cálculo y gestión de impuestos',
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
                          ref.read(settingsProvider.notifier).toggleTax(true);
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
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

              const SettingsHeader(title: 'Catálogo'),
              SettingsSectionContainer(
                children: [
                  SettingsCategoryTile(
                    icon: Icons.category_rounded,
                    title: 'Categorías',
                    subtitle: 'Organización de productos',
                    onTap: () => context.push('/categories'),
                  ),
                  const Divider(height: 1, indent: 56),
                  SettingsCategoryTile(
                    icon: Icons.apartment_rounded,
                    title: 'Departamentos',
                    subtitle: 'Clasificación de alto nivel',
                    onTap: () => context.push('/departments'),
                  ),
                  const Divider(height: 1, indent: 56),
                  SettingsCategoryTile(
                    icon: Icons.label_rounded,
                    title: 'Marcas',
                    subtitle: 'Fabricantes y marcas',
                    onTap: () => context.push('/brands'),
                  ),
                  const Divider(height: 1, indent: 56),
                  SettingsCategoryTile(
                    icon: Icons.price_change_rounded,
                    title: 'Tasas de Impuesto',
                    subtitle: 'Configuración fiscal',
                    onTap: () => context.push('/tax-rates'),
                  ),
                ],
              ),

              const SettingsHeader(title: 'Usuarios y Seguridad'),
              SettingsSectionContainer(
                children: [
                  SettingsCategoryTile(
                    icon: Icons.people_alt_rounded,
                    title: 'Usuarios',
                    subtitle: 'Gestión de personal y cajeros',
                    onTap: () => context.push('/cashiers'),
                  ),
                ],
              ),

              const SettingsHeader(title: 'Ayuda'),
              SettingsSectionContainer(
                children: [
                  SettingsCategoryTile(
                    icon: Icons.keyboard_alt_outlined,
                    title: 'Atajos de Teclado',
                    subtitle: 'Lista de accesos directos del sistema',
                    onTap: () => context.push('/settings/shortcuts'),
                  ),
                ],
              ),
            ],
          ],
        ),
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

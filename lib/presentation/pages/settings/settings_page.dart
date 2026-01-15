import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:posventa/presentation/pages/settings/widgets/settings_components.dart';
import 'package:posventa/presentation/pages/settings/widgets/settings_layout.dart';
import 'package:posventa/presentation/pages/settings/widgets/settings_navigation_rail.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: false,
        leading:
            MediaQuery.of(context).size.width < SettingsLayout.mobileBreakpoint
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => MainLayout.of(context)?.openDrawer(),
              )
            : null,
      ),
      body: SettingsLayout(
        mobileLayout: _buildMobileLayout(),
        desktopLayout: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGeneralSection(),
          _buildSystemSection(),
          _buildCatalogSection(),
          _buildUsersSection(),
          _buildHelpSection(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsNavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: Text('General'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings_system_daydream_outlined),
              selectedIcon: Icon(Icons.settings_system_daydream_rounded),
              label: Text('Sistema'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: Text('Catálogo'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people_rounded),
              label: Text('Usuarios'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.help_outline),
              selectedIcon: Icon(Icons.help_rounded),
              label: Text('Ayuda'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDesktopHeader(),
                const SizedBox(height: 16),
                _buildSelectedSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    String title = '';
    String subtitle = '';

    switch (_selectedIndex) {
      case 0:
        title = 'General';
        subtitle = 'Información básica y configuración del negocio';
        break;
      case 1:
        title = 'Sistema';
        subtitle = 'Opciones avanzadas, hardware y respaldo';
        break;
      case 2:
        title = 'Catálogo';
        subtitle = 'Gestión de productos, categorías y tasas';
        break;
      case 3:
        title = 'Usuarios y Seguridad';
        subtitle = 'Administración de cuentas y permisos';
        break;
      case 4:
        title = 'Ayuda';
        subtitle = 'Recursos y atajos de teclado';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSection() {
    switch (_selectedIndex) {
      case 0:
        return _buildGeneralContent();
      case 1:
        return _buildSystemContent();
      case 2:
        return _buildCatalogContent();
      case 3:
        return _buildUsersContent();
      case 4:
        return _buildHelpContent();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Section Builders (Shared logic wrappers) ---

  Widget _buildGeneralSection() {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.role == UserRole.administrador;

    if (!isAdmin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeader(title: 'General'),
        _buildGeneralContent(),
      ],
    );
  }

  Widget _buildGeneralContent() {
    return SettingsSectionContainer(
      children: [
        SettingsCategoryTile(
          icon: Icons.account_circle,
          title: 'Mi Cuenta',
          subtitle: 'Datos personales y contraseña',
          onTap: () => context.push('/settings/profile'),
        ),
        const Divider(height: 1, indent: 56),
        SettingsCategoryTile(
          icon: Icons.store_mall_directory_rounded,
          title: 'Datos del Negocio y Ticket',
          subtitle: 'Información de la tienda y diseño del ticket',
          onTap: () => context.push('/settings/business'),
        ),
        const Divider(height: 1, indent: 56),
        SettingsCategoryTile(
          icon: Icons.warehouse_rounded,
          title: 'Almacenes',
          subtitle: 'Gestión de ubicaciones físicas',
          onTap: () => context.push('/warehouses'),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == UserRole.administrador;
    if (!isAdmin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeader(title: 'Sistema'),
        _buildSystemContent(),
      ],
    );
  }

  Widget _buildSystemContent() {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
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
                    ref.read(settingsProvider.notifier).toggleInventory(false);
                  },
                );
              } else {
                ref.read(settingsProvider.notifier).toggleInventory(true);
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
                    ref.read(settingsProvider.notifier).toggleTax(false);
                  },
                );
              } else {
                ref.read(settingsProvider.notifier).toggleTax(true);
              }
            },
          ),
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
    );
  }

  Widget _buildCatalogSection() {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == UserRole.administrador;
    if (!isAdmin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeader(title: 'Catálogo'),
        _buildCatalogContent(),
      ],
    );
  }

  Widget _buildCatalogContent() {
    return SettingsSectionContainer(
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
    );
  }

  Widget _buildUsersSection() {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == UserRole.administrador;
    if (!isAdmin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeader(title: 'Usuarios y Seguridad'),
        _buildUsersContent(),
      ],
    );
  }

  Widget _buildUsersContent() {
    return SettingsSectionContainer(
      children: [
        SettingsCategoryTile(
          icon: Icons.badge_rounded,
          title: 'Gestión de Usuarios',
          subtitle: 'Administrar usuarios, roles y permisos',
          onTap: () => context.push('/users-permissions'),
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == UserRole.administrador;
    if (!isAdmin)
      return const SizedBox.shrink(); // Assuming help is also only for admin in this view? Or maybe help should be for everyone?
    // The original code wrapped everything in "if (isAdmin)". So keeping it that way for safety, although help usually is for everyone.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeader(title: 'Ayuda'),
        _buildHelpContent(),
      ],
    );
  }

  Widget _buildHelpContent() {
    return SettingsSectionContainer(
      children: [
        SettingsCategoryTile(
          icon: Icons.keyboard_alt_outlined,
          title: 'Atajos de Teclado',
          subtitle: 'Lista de accesos directos del sistema',
          onTap: () => context.push('/settings/shortcuts'),
        ),
      ],
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

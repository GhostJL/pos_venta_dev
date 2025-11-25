import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/dashboard_card.dart';
import 'package:posventa/presentation/widgets/dashboard/clock_widget.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_search_delegate.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        toolbarHeight: 80,
        title: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: InkWell(
            onTap: () async {
              final result = await showSearch(
                context: context,
                delegate: DashboardSearchDelegate(),
              );
              if (result != null && context.mounted) {
                context.go(result);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borders.withAlpha(50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Buscar (Ctrl + K)...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _confirmLogout(context, ref);
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.cardBackground,
              foregroundColor: AppTheme.error,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.borders.withAlpha(50)),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine column count based on width
          int crossAxisCount = 1;
          double childAspectRatio = 3.0;

          if (constraints.maxWidth >= 1100) {
            crossAxisCount = 3;
            childAspectRatio = 2.5;
          } else if (constraints.maxWidth >= 700) {
            crossAxisCount = 2;
            childAspectRatio = 2.2; // Slightly taller for tablets
          }

          return ListView(
            padding: const EdgeInsets.all(32.0),
            children: [
              // 1. Welcome Message
              _buildWelcomeMessage(context, user?.firstName),
              const SizedBox(height: 24),

              // 2. Cash Session Status & Clock (Redesigned)
              _buildStatusSection(context, ref),
              const SizedBox(height: 32),

              // 3. Operations Section
              _buildOperationsSection(
                context,
                crossAxisCount,
                childAspectRatio,
              ),
              const SizedBox(height: 32),

              // 4. Management Section
              _buildManagementSection(
                context,
                crossAxisCount,
                childAspectRatio,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context, String? firstName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola, ${firstName ?? 'Usuario'}!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenido a tu panel de control.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentCashSessionProvider);
    final user = ref.watch(authProvider).user;
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borders.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Flex(
        direction: isSmall ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isSmall
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          // Clock Section
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const ClockWidget(),
            ],
          ),

          if (isSmall) const SizedBox(height: 20),

          // Session Status Section
          sessionAsync.when(
            data: (session) {
              final isOpen = session != null;
              final statusColor = isOpen ? Colors.green : Colors.red;

              final roleName = user?.role.name ?? '';
              final displayRole = roleName.isNotEmpty
                  ? '${roleName[0].toUpperCase()}${roleName.substring(1)}'
                  : 'Usuario';

              final statusText = isOpen
                  ? 'Caja Abierta: $displayRole'
                  : 'Caja Cerrada';

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: statusColor.withAlpha(30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withAlpha(100),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final session = await ref.read(getCurrentCashSessionUseCaseProvider).call();

    if (session != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Caja Abierta'),
          content: const Text(
            'Tienes una sesión de caja abierta.\nDebes cerrarla antes de cerrar sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/cash-session-close?intent=logout');
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Ir a Cerrar Caja'),
            ),
          ],
        ),
      );
      return;
    }

    if (!context.mounted) return;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres salir del sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      ref.read(authProvider.notifier).logout();
      context.go('/login');
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsSection(
    BuildContext context,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    final actionCards = [
      DashboardCard(
        title: 'Punto de Venta',
        value: 'Iniciar Venta',
        icon: Icons.point_of_sale_rounded,
        iconColor: AppTheme.primary,
        onTap: () => context.go('/sales'),
      ),
      DashboardCard(
        title: 'Historial de Ventas',
        value: 'Ver Registros',
        icon: Icons.receipt_long_rounded,
        iconColor: Colors.blue.shade600,
        onTap: () => context.go('/sales-history'),
      ),
      DashboardCard(
        title: 'Cortes de Caja',
        value: 'Historial Sesiones',
        icon: Icons.history_edu_rounded,
        iconColor: Colors.orange.shade600,
        onTap: () => context.go('/cash-sessions-history'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          'Operaciones Diarias',
          Icons.storefront_rounded,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: actionCards.length,
          itemBuilder: (context, index) => actionCards[index],
        ),
      ],
    );
  }

  Widget _buildManagementSection(
    BuildContext context,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    final actionCards = [
      DashboardCard(
        title: 'Inventario',
        value: 'Productos y Stock',
        icon: Icons.inventory_2_rounded,
        iconColor: Colors.indigo.shade600,
        onTap: () => context.go('/inventory'),
      ),
      DashboardCard(
        title: 'Ajustes de Inventario',
        value: 'Correcciones y Ajustes',
        icon: Icons.tune_rounded,
        iconColor: Colors.amber.shade700,
        onTap: () => context.go('/inventory-adjustments-menu'),
      ),
      DashboardCard(
        title: 'Clientes',
        value: 'Base de Datos',
        icon: Icons.people_alt_rounded,
        iconColor: Colors.purple.shade600,
        onTap: () => context.go('/customers'),
      ),
      DashboardCard(
        title: 'Compras',
        value: 'Proveedores',
        icon: Icons.shopping_cart_rounded,
        iconColor: Colors.teal.shade600,
        onTap: () => context.go('/purchases'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          'Gestión y Administración',
          Icons.admin_panel_settings_rounded,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: actionCards.length,
          itemBuilder: (context, index) => actionCards[index],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/dashboard_card.dart';
import 'package:posventa/presentation/widgets/dashboard/clock_widget.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_search_delegate.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Welcome Message
          _buildWelcomeMessage(context, user?.firstName),
          const SizedBox(height: 32),
          //2.Cash Session Status
          _buildClockWidget(context, ref),
          const SizedBox(height: 24),

          // 3. Operations Section
          _buildOperationsSection(context, isSmallScreen),
          const SizedBox(height: 32),

          // 4. Management Section
          _buildManagementSection(context, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildClockWidget(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borders.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          _buildCashSessionStatus(context, ref),
          Spacer(),
          const ClockWidget(),
        ],
      ),
    );
  }

  Widget _buildCashSessionStatus(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentCashSessionProvider);
    final user = ref.watch(authProvider).user;

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return Align(
            alignment: Alignment.centerLeft,
            child: _buildStatusChip(
              context,
              cashStatus: 'Caja Cerrada',
              cashRole: 'Rol no disponible',
              color: Colors.red.shade50,
              textColor: Colors.red.shade700,
            ),
          );
        }

        final accountEmail = user != null
            ? (user.role == UserRole.administrador ? 'Administrador' : 'Cajero')
            : 'Rol no disponible';

        return Align(
          alignment: Alignment.centerLeft,
          child: _buildStatusChip(
            context,
            cashStatus: 'Caja Abierta',
            cashRole: 'Rol: $accountEmail',
            color: Colors.green.shade50,
            textColor: Colors.green.shade700,
          ),
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
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

  Widget _buildStatusChip(
    BuildContext context, {
    required String cashStatus,
    required String cashRole,
    required Color color,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        Text(
          cashStatus,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        Text(
          cashRole,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    // 1. Check for open cash session first
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsSection(BuildContext context, bool isSmallScreen) {
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
            crossAxisCount: isSmallScreen ? 1 : 3,
            childAspectRatio: isSmallScreen ? 3.5 : 2.5,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: actionCards.length,
          itemBuilder: (context, index) => actionCards[index],
        ),
      ],
    );
  }

  Widget _buildManagementSection(BuildContext context, bool isSmallScreen) {
    final actionCards = [
      DashboardCard(
        title: 'Inventario',
        value: 'Productos y Stock',
        icon: Icons.inventory_2_rounded,
        iconColor: Colors.indigo.shade600,
        onTap: () => context.go('/inventory'),
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
            crossAxisCount: isSmallScreen ? 1 : 3,
            childAspectRatio: isSmallScreen ? 3.5 : 2.5,
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

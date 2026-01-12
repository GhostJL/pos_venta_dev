import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 80,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      leading: MediaQuery.of(context).size.width < 1200
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                MainLayout.of(context)?.openDrawer();
              },
            )
          : null,
      title: Text(
        'Panel de Control',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _confirmLogout(context, ref);
          },
          icon: Icon(Icons.logout_rounded),
          tooltip: 'Cerrar Sesión',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.error,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(50),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
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
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.transactionPending,
              ),
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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
}

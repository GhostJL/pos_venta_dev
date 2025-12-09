import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/core/theme/theme.dart';

class SideMenuLogout extends ConsumerWidget {
  const SideMenuLogout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outline.withAlpha(100)),
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () async {
            if (Scaffold.of(context).isDrawerOpen) {
              Scaffold.of(context).closeDrawer();
            }

            final session = await ref
                .read(getCurrentCashSessionUseCaseProvider)
                .call();

            if (session != null && context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Caja Abierta'),
                  content: const Text(
                    'Tienes una sesión de caja abierta.\nDebe cerrarla antes de cerrar sesión.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        context.pop();
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
            } else {
              ref.read(authProvider.notifier).logout();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.error.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

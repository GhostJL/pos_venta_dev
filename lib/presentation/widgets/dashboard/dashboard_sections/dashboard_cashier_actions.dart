import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/widgets/cash_sessions/actions/cash_movement_dialog.dart';

class DashboardCashierActions extends ConsumerWidget {
  const DashboardCashierActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentCashSessionProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_applications_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Acciones de Caja',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          sessionAsync.when(
            data: (session) {
              if (session == null) return const Text('No hay sesión activa');

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.start,
                children: [
                  _ActionButton(
                    label: 'Ingreso de Dinero',
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => CashMovementDialog(
                          sessionId: session.id!,
                          movementType: 'entry',
                          userId: session.userId,
                        ),
                      );
                    },
                  ),
                  _ActionButton(
                    label: 'Retiro de Efectivo',
                    icon: Icons.remove_circle_outline,
                    color: Colors.orange,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => CashMovementDialog(
                          sessionId: session.id!,
                          movementType: 'withdrawal',
                          userId: session.userId,
                        ),
                      );
                    },
                  ),
                  _ActionButton(
                    label: 'Corte de Caja',
                    icon: Icons.lock_clock_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    isPrimary: true,
                    onTap: () {
                      context.push('/cash-session-close');
                    },
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? color : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          constraints: const BoxConstraints(minWidth: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.white : color),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

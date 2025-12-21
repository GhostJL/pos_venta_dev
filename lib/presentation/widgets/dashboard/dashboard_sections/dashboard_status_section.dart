import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/dashboard/clock_widget.dart';
import 'package:posventa/core/theme/theme.dart';

class DashboardStatusSection extends ConsumerWidget {
  const DashboardStatusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentCashSessionProvider);
    final user = ref.watch(authProvider).user;
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
        ),
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
              Icon(
                Icons.calendar_today_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              const ClockWidget(),
            ],
          ),

          if (isSmall) const SizedBox(height: 16),

          // Session Status Section
          sessionAsync.when(
            data: (session) {
              final isOpen = session != null;
              final statusColor = isOpen
                  ? AppTheme.transactionSuccess
                  : AppTheme.transactionFailed;

              final roleName = user?.role.name ?? '';
              final displayRole = roleName.isNotEmpty
                  ? '${roleName[0].toUpperCase()}${roleName.substring(1)}'
                  : 'Usuario';

              final statusText = isOpen
                  ? 'Caja Abierta • $displayRole'
                  : 'Caja Cerrada';

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: statusColor.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

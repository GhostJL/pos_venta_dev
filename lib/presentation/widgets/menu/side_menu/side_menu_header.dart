import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/widgets/menu/side_menu/side_menu_session_status.dart';

class SideMenuHeader extends ConsumerWidget {
  final User? user;

  const SideMenuHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final accountName = user?.firstName ?? 'Usuario';
    final accountLastName = user?.lastName ?? 'N.';
    final accountEmail = user != null
        ? (user!.role == UserRole.administrador ? 'Administrador' : 'Cajero')
        : 'Rol no disponible';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withAlpha(100)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withAlpha(50),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary.withAlpha(20),
                  child: Text(
                    accountName.isNotEmpty ? accountName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$accountName $accountLastName',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accountEmail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Cash session status indicator
          if (user?.role == UserRole.cajero) ...[
            const SizedBox(height: 16),
            const SideMenuSessionStatus(),
          ],
        ],
      ),
    );
  }
}

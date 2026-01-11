import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/cash/cash_session_open_page.dart';

import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/backup_state_provider.dart';
import 'package:posventa/domain/entities/user.dart';

/// Wrapper que valida si el usuario tiene una sesión de caja abierta
/// antes de permitir el acceso al contenido principal.
/// Solo aplica para usuarios con rol 'cashier' o 'admin'.
class CashSessionGuard extends ConsumerWidget {
  final Widget child;

  const CashSessionGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If a backup/restore is in progress, do not block access or show errors
    // just because the DB is closed. Keep the current UI mounted.
    final isBackup = ref.watch(isBackupInProgressProvider);
    if (isBackup) {
      return child;
    }

    final user = ref.watch(authProvider).user;

    // Solo validar sesión para cajeros y administradores
    if (user == null ||
        (user.role != UserRole.cajero && user.role != UserRole.administrador)) {
      return child;
    }

    final sessionAsync = ref.watch(currentCashSessionProvider);

    return sessionAsync.when(
      data: (session) {
        // Si no hay sesión abierta, mostrar pantalla de apertura
        if (session == null) {
          return const CashSessionOpenPage();
        }

        // Si hay sesión abierta, permitir acceso al contenido
        return child;
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al verificar sesión de caja',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/cash_session_open_page.dart';
import 'package:posventa/presentation/pages/main_layout.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/domain/entities/user.dart';

/// Wrapper que valida si el usuario tiene una sesión de caja abierta
/// antes de permitir el acceso al contenido principal.
/// Solo aplica para usuarios con rol 'cashier' o 'admin'.
class CashSessionGuard extends ConsumerWidget {
  final Widget child;

  const CashSessionGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Solo validar sesión para cajeros y administradores
    if (user == null ||
        (user.role != UserRole.cajero && user.role != UserRole.administrador)) {
      return MainLayout(child: child);
    }

    final sessionAsync = ref.watch(currentCashSessionProvider);

    return sessionAsync.when(
      data: (session) {
        // Si no hay sesión abierta, mostrar pantalla de apertura
        if (session == null) {
          return const CashSessionOpenPage();
        }

        // Si hay sesión abierta, permitir acceso al contenido
        return MainLayout(child: child);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al verificar sesión de caja',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

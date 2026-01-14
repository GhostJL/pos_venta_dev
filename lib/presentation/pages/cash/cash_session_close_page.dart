import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/di/backup_di.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/layouts/permission_denied_widget.dart';
import 'package:posventa/presentation/widgets/common/centered_form_card.dart';
import 'package:posventa/presentation/widgets/cash_sessions/close/cash_session_info_card.dart';
import 'package:posventa/presentation/widgets/cash_sessions/close/cash_session_close_form.dart';
import 'package:posventa/presentation/widgets/cash_sessions/close/cash_session_close_summary_dialog.dart';

class CashSessionClosePage extends ConsumerStatefulWidget {
  final bool isLogoutIntent;
  const CashSessionClosePage({super.key, this.isLogoutIntent = false});

  @override
  ConsumerState<CashSessionClosePage> createState() =>
      _CashSessionClosePageState();
}

class _CashSessionClosePageState extends ConsumerState<CashSessionClosePage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleCloseSession(double amount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cierre'),
        content: Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(
                text:
                    '¿Está seguro de cerrar la caja con un efectivo contado de ',
              ),
              TextSpan(
                text: '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar Cierre'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentSession = await ref
          .read(getCurrentCashSessionUseCaseProvider)
          .call();

      if (currentSession == null) {
        throw Exception('No hay una sesión de caja abierta');
      }

      final closingBalanceCents = (amount * 100).round();
      final closedSession = await ref
          .read(closeCashSessionUseCaseProvider)
          .call(currentSession.id!, closingBalanceCents);

      // Trigger automatic backup after successful session close
      try {
        final backupRepo = ref.read(backupRepositoryProvider);
        final backupFile = await backupRepo.createBackupFile();

        // Move backup to documents directory with timestamp
        final docsDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupPath = p.join(
          docsDir.path,
          'backups',
          'session_$timestamp.sqlite',
        );

        // Ensure backup directory exists
        final backupDir = Directory(p.dirname(backupPath));
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }

        await backupFile.copy(backupPath);
        await backupFile.delete(); // Clean up temp file
      } catch (backupError) {
        // Log backup error but don't fail session close
        debugPrint('Backup failed after session close: $backupError');
      }

      if (mounted) {
        // Mostrar resumen del cierre
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              CashSessionCloseSummaryDialog(session: closedSession),
        );

        // Invalidar sesión
        ref.invalidate(currentCashSessionProvider);

        if (widget.isLogoutIntent) {
          if (mounted) {
            ref.read(authProvider.notifier).logout();
          }
        } else {
          if (mounted) {
            // Si no es logout, redirigir a home (que mostrará la pantalla de apertura)
            context.go('/home');
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si el usuario está autenticado
    final user = ref.watch(authProvider).user;
    if (user == null) {
      // Si no hay usuario (logout en proceso), mostrar carga o nada
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final sessionAsync = ref.watch(currentCashSessionProvider);
    final hasClosePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.cashClose),
    );

    if (!hasClosePermission) {
      return PermissionDeniedWidget(
        message:
            'No tienes permiso para cerrar sesiones de caja.\n\nContacta a un administrador para obtener acceso.',
        icon: Icons.point_of_sale_outlined,
        backRoute: '/home',
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cierre de Caja'), centerTitle: true),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                'Error: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
        data: (session) {
          if (session == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  const Text('No hay una sesión de caja abierta'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final openingBalance = session.openingBalanceCents / 100;
          final openedAt = session.openedAt;
          final duration = DateTime.now().difference(openedAt);

          return CenteredFormCard(
            icon: Icons.lock_clock_outlined,
            title: 'Cierre de Turno',
            children: [
              // Información de la sesión
              CashSessionInfoCard(
                openingBalance: openingBalance,
                duration: duration,
              ),
              const SizedBox(height: 32),

              // Formulario de cierre
              CashSessionCloseForm(
                onCloseSession: _handleCloseSession,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
              ),
            ],
          );
        },
      ),
    );
  }
}

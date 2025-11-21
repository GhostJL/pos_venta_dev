import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';

class PermissionDeniedWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? backRoute;
  final VoidCallback? onBackPressed;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool showSecondaryButton;

  const PermissionDeniedWidget({
    super.key,
    required this.message,
    this.icon = Icons.lock_outline,
    this.backRoute,
    this.onBackPressed,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.showSecondaryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Denegado'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (onBackPressed != null) {
              onBackPressed!();
            } else if (backRoute != null) {
              context.go(backRoute!);
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 80, color: AppTheme.error),
              ),
              const SizedBox(height: 32),
              Text(
                'Acceso Denegado',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showSecondaryButton) ...[
                    OutlinedButton.icon(
                      onPressed:
                          onSecondaryPressed ??
                          () {
                            if (onBackPressed != null) {
                              onBackPressed!();
                            } else if (backRoute != null) {
                              context.go(backRoute!);
                            } else {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            }
                          },
                      icon: const Icon(Icons.arrow_back),
                      label: Text(secondaryButtonText ?? 'Volver'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: onPrimaryPressed ?? () => context.go('/home'),
                    icon: Icon(
                      onPrimaryPressed != null ? Icons.check : Icons.home,
                    ), // Dynamic icon
                    label: Text(primaryButtonText ?? 'Ir al Inicio'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

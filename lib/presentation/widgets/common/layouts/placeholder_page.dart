import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/core/theme/theme.dart';

/// Reusable placeholder page for modules under development
class PlaceholderPage extends StatelessWidget {
  final String moduleName;
  final String description;
  final IconData icon;
  final List<String> plannedFeatures;
  final Color? accentColor;
  final bool showMenuButton;

  const PlaceholderPage({
    super.key,
    required this.moduleName,
    required this.description,
    required this.icon,
    this.plannedFeatures = const [],
    this.accentColor,
    this.showMenuButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).colorScheme.primary;
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(moduleName),
        leading: (showMenuButton && isSmallScreen)
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => MainLayout.of(context)?.openDrawer(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 80, color: color),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                moduleName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Coming Soon Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.transactionPending.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.transactionPending.withAlpha(100),
                  ),
                ),
                child: const Text(
                  'PRÓXIMAMENTE',
                  style: TextStyle(
                    color: AppTheme.transactionPending,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Planned Features
              if (plannedFeatures.isNotEmpty) ...[
                const SizedBox(height: 40),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.checklist_rounded, color: color, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Funcionalidades Planeadas',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...plannedFeatures.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: color.withAlpha(150),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Back to Dashboard Button
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text('Volver al Dashboard'),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

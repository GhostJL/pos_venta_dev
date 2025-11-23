import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/pages/onboarding/onboarding_layout.dart';

class AddCashiersPage extends ConsumerWidget {
  const AddCashiersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final cashiers = onboardingState.cashiers;
    final canAddMore = cashiers.length < 10;
    final membersText = cashiers.length == 1 ? 'miembro' : 'miembros';

    return OnboardingLayout(
      title: 'Añadir Miembros del Equipo',
      subtitle: 'Has añadido ${cashiers.length} $membersText al equipo.',
      currentStep: 2,
      totalSteps: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: canAddMore
                    ? () => context.push('/add-cashier-form')
                    : null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Añadir Nuevo Miembro'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                    horizontal: isSmallScreen ? 16 : 24,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
              if (cashiers.isNotEmpty) ...[
                Text(
                  'Equipo Actual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 24),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: isSmallScreen ? 300 : 400,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cashiers.length,
                    itemBuilder: (context, index) {
                      final cashier = cashiers[index];
                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borders, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.textPrimary.withAlpha(10),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 4 : 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: AppTheme.primary,
                              size: isSmallScreen ? 20 : 24,
                            ),
                          ),
                          title: Text(
                            cashier.username,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          subtitle: Text(
                            '${cashier.firstName} ${cashier.lastName}',
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.error,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            tooltip: 'Eliminar a ${cashier.username}',
                            onPressed: () {
                              ref
                                  .read(onboardingProvider.notifier)
                                  .removeCashier(cashier);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
              ],
              ElevatedButton(
                onPressed: () => context.push('/set-access-key'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 14 : 16,
                  ),
                ),
                child: const Text('Continuar al Paso Final'),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              TextButton(
                onPressed: () => context.go('/setup-admin'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                ),
                child: const Text(
                  'Volver a la Configuración del Administrador',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';

class OnboardingLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final int currentStep;
  final int totalSteps;

  const OnboardingLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.currentStep = 1,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen =
                constraints.maxWidth >= 600 && constraints.maxWidth < 900;

            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isSmallScreen
                        ? double.infinity
                        : (isMediumScreen ? 600 : 700),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(isSmallScreen ? 0 : 24.0),
                    padding: EdgeInsets.all(isSmallScreen ? 24.0 : 40.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 0 : 24,
                      ),
                      boxShadow: isSmallScreen
                          ? []
                          : [
                              BoxShadow(
                                color: AppTheme.textPrimary.withAlpha(10),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 32 : 48),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 24 : 32,
            color: AppTheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 20 : 24),
        _buildStepIndicator(isSmallScreen),
      ],
    );
  }

  Widget _buildStepIndicator(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final bool isActive = index < currentStep;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 6),
          height: isSmallScreen ? 8 : 10,
          width: isSmallScreen ? 30 : 40,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.inputBackground,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

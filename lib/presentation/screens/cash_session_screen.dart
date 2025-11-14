import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';
import 'package:myapp/presentation/widgets/movements_list.dart';

class CashSessionScreen extends ConsumerWidget {
  const CashSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashSessionState = ref.watch(cashSessionProvider);

    return Scaffold(
      body: cashSessionState.when(
        data: (session) {
          if (session == null || session.closedAt != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No active session.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/open-session'),
                    child: const Text('Start New Session'),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              _buildSessionHeader(context, session, ref),
              const Divider(height: 1, color: AppTheme.borders),
              Expanded(
                child: MovementsList(
                  sessionId: session.id!,
                ), // Use the new widget
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: AppTheme.error),
          ),
        ),
      ),
      floatingActionButton: cashSessionState.when(
        data: (session) => session != null && session.closedAt == null
            ? FloatingActionButton(
                onPressed: () => context.push('/add-movement'),
                backgroundColor: AppTheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : const SizedBox.shrink(),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSessionHeader(BuildContext context, session, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${(session.currentBalanceCents / 100).toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: AppTheme.primary),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(
                context,
                label: 'Opening Balance',
                value:
                    '\$${(session.openingBalanceCents / 100).toStringAsFixed(2)}',
              ),
              ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog before closing
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Confirm Close Session'),
                      content: const Text(
                        'Are you sure you want to close this session?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed ?? false) {
                    ref
                        .read(cashSessionProvider.notifier)
                        .closeSession(session.id!, session.currentBalanceCents);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                ),
                child: const Text('Close Session'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

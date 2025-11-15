import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';

class AddCashiersPage extends ConsumerWidget {
  const AddCashiersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the onboarding state to get the list of cashiers
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final cashiers = onboardingState.cashiers;
    final canAddMore = cashiers.length < 10; // Allow up to 10 cashiers

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Team Members (Cashiers)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Navigate back to admin setup, allowing changes
          onPressed: () => context.go('/setup-admin'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You have added ${cashiers.length} team member(s).',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: canAddMore
                  ? () => context.push('/add-cashier-form')
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAddMore
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add New Member',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text('Current Team', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Expanded(
              child: cashiers.isEmpty
                  ? const Center(child: Text('No team members added yet.'))
                  : ListView.builder(
                      itemCount: cashiers.length,
                      itemBuilder: (context, index) {
                        final cashier = cashiers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(cashier.username),
                            subtitle: Text(
                              '${cashier.firstName} ${cashier.lastName}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Remove ${cashier.username}',
                              onPressed: () {
                                // Call the notifier to remove the cashier
                                ref
                                    .read(onboardingNotifierProvider.notifier)
                                    .removeCashier(cashier);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/set-pin'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue to Final Step'),
            ),
          ],
        ),
      ),
    );
  }
}

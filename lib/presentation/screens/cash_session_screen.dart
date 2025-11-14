
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';
import 'package:myapp/presentation/providers/cash_movement_provider.dart';
import 'package:myapp/presentation/screens/add_movement_screen.dart';

class CashSessionScreen extends ConsumerWidget {
  const CashSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashSessionState = ref.watch(cashSessionProvider);
    final cashMovementState = ref.watch(cashMovementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          )
        ],
      ),
      body: cashSessionState.when(
        data: (session) {
          if (session == null) {
            return const Center(child: Text('No active session.'));
          }
          // Fetch movements when session is available
          Future.microtask(() => ref.read(cashMovementProvider.notifier).getMovementsBySession(session.id!));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Session ID: ${session.id}'),
                Text('Opening Balance: ${session.openingBalanceCents / 100}'),
                if (session.closingBalanceCents != null)
                  Text('Closing Balance: ${session.closingBalanceCents! / 100}'),
                if (session.closedAt != null)
                  Text('Closed At: ${session.closedAt}'),
                const SizedBox(height: 20),
                if (session.closedAt == null)
                  ElevatedButton(
                    onPressed: () {
                      ref.read(cashSessionProvider.notifier).closeSession(session.id!, 100000); // 1000.00
                    },
                    child: const Text('Close Session'),
                  ),
                const SizedBox(height: 20),
                Expanded(
                  child: cashMovementState.when(
                    data: (movements) {
                      return ListView.builder(
                        itemCount: movements.length,
                        itemBuilder: (context, index) {
                          final movement = movements[index];
                          return ListTile(
                            title: Text(movement.reason),
                            subtitle: Text(movement.description ?? ''),
                            trailing: Text('${movement.amountCents / 100}'),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMovementScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

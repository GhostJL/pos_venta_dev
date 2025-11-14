import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/domain/entities/cash_movement.dart';
import 'package:myapp/presentation/providers/cash_movement_provider.dart';

class MovementsList extends ConsumerStatefulWidget {
  final int sessionId;
  const MovementsList({super.key, required this.sessionId});

  @override
  ConsumerState<MovementsList> createState() => _MovementsListState();
}

class _MovementsListState extends ConsumerState<MovementsList> {
  @override
  void initState() {
    super.initState();
    // Fetch movements once when the widget is initialized
    Future.microtask(
      () => ref
          .read(cashMovementProvider.notifier)
          .getMovementsBySession(widget.sessionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movementsAsync = ref.watch(cashMovementProvider);

    return movementsAsync.when(
      data: (movements) {
        if (movements.isEmpty) {
          return const Center(
            child: Text(
              'No movements yet.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          itemCount: movements.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: AppTheme.borders),
          itemBuilder: (context, index) {
            final movement = movements[index];
            return _buildMovementTile(movement, context);
          },
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
    );
  }

  Widget _buildMovementTile(CashMovement movement, BuildContext context) {
    final amountFormatted = NumberFormat.simpleCurrency(
      decimalDigits: 2,
    ).format(movement.amountCents / 100);
    final isCashIn = movement.movementType == 'in';
    final Color amountColor = isCashIn ? AppTheme.success : AppTheme.error;
    final IconData iconData = isCashIn
        ? Icons.arrow_downward
        : Icons.arrow_upward;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: amountColor.withAlpha(25),
        child: Icon(iconData, color: amountColor, size: 20),
      ),
      title: Text(
        movement.reason,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        movement.description ?? 'No description',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isCashIn ? '+' : '-'}$amountFormatted',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat.yMMMd().add_jm().format(movement.movementDate),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

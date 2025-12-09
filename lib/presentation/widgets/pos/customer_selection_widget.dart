import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/consumer_selection_dialog_widget.dart';

class CustomerSelectionWidget extends ConsumerWidget {
  const CustomerSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use selector to only rebuild when selectedCustomer changes
    final selectedCustomer = ref.watch(
      pOSProvider.select((state) => state.selectedCustomer),
    );

    final displayText = selectedCustomer != null
        ? '${selectedCustomer.firstName} ${selectedCustomer.lastName}'
        : 'Cliente General';

    return Container(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const CustomerSelectionDialogWidget(),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

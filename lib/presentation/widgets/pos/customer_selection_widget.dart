import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/pos/consumer_selection_dialog_widget.dart';

class CustomerSelectionWidget extends StatelessWidget {
  final String posState;

  const CustomerSelectionWidget({super.key, required this.posState});

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  posState,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}

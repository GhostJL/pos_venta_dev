import 'package:flutter/material.dart';

class AdditionalInfoSection extends StatelessWidget {
  final DateTime? expirationDate;
  final ValueChanged<DateTime?> onDateChanged;

  const AdditionalInfoSection({
    super.key,
    required this.expirationDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Adicional (Opcional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: expirationDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha de Vencimiento',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.event_busy),
            ),
            child: Text(
              expirationDate != null
                  ? '${expirationDate!.day}/${expirationDate!.month}/${expirationDate!.year}'
                  : 'Sin fecha de vencimiento',
              style: TextStyle(
                color: expirationDate != null
                    ? Colors.black
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

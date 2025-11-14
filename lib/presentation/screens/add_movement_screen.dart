
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/providers/cash_movement_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';

class AddMovementScreen extends ConsumerStatefulWidget {
  const AddMovementScreen({super.key});

  @override
  ConsumerState<AddMovementScreen> createState() => _AddMovementScreenState();
}

class _AddMovementScreenState extends ConsumerState<AddMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _movementType = 'in';

  @override
  Widget build(BuildContext context) {
    final cashMovementNotifier = ref.read(cashMovementProvider.notifier);
    final cashSession = ref.watch(cashSessionProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Cash Movement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _movementType,
                items: const [
                  DropdownMenuItem(value: 'in', child: Text('In')),
                  DropdownMenuItem(value: 'out', child: Text('Out')),
                ],
                onChanged: (value) {
                  setState(() {
                    _movementType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Movement Type'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && cashSession != null) {
                    final amount = int.parse(_amountController.text) * 100; // Convert to cents
                    cashMovementNotifier.createMovement(
                      cashSession.id!,
                      _movementType,
                      amount,
                      _reasonController.text,
                      description: _descriptionController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Movement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

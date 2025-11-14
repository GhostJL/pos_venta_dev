import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/cash_movement_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';

class AddMovementScreen extends ConsumerStatefulWidget {
  const AddMovementScreen({super.key});

  @override
  ConsumerState<AddMovementScreen> createState() => _AddMovementScreenState();
}

class _AddMovementScreenState extends ConsumerState<AddMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  String _movementType = 'in';
  String _reason = 'deposit';
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(cashSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Movement')),
      body: session.when(
        data: (sessionData) {
          if (sessionData == null) {
            return const Center(
              child: Text(
                'No active cash session.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMovementTypeSelector(),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be positive';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _reason,
                    decoration: const InputDecoration(labelText: 'Reason'),
                    onChanged: (value) => setState(() => _reason = value!),
                    items: const [
                      DropdownMenuItem(
                        value: 'deposit',
                        child: Text('Deposit'),
                      ),
                      DropdownMenuItem(
                        value: 'withdrawal',
                        child: Text('Withdrawal'),
                      ),
                      DropdownMenuItem(
                        value: 'payment',
                        child: Text('Payment'),
                      ),
                      DropdownMenuItem(value: 'refund', child: Text('Refund')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save Movement'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, s) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppTheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementTypeSelector() {
    return SegmentedButton<String>(
      style: SegmentedButton.styleFrom(
        backgroundColor: AppTheme.inputBackground,
        foregroundColor: AppTheme.textSecondary,
        selectedBackgroundColor: _movementType == 'in'
            ? AppTheme.success.withAlpha(51)
            : AppTheme.error.withAlpha(51),
        selectedForegroundColor:
            _movementType == 'in' ? AppTheme.success : AppTheme.error,
      ),
      segments: const <ButtonSegment<String>>[
        ButtonSegment(
          value: 'in',
          label: Text('Cash In'),
          icon: Icon(Icons.add),
        ),
        ButtonSegment(
          value: 'out',
          label: Text('Cash Out'),
          icon: Icon(Icons.remove),
        ),
      ],
      selected: {_movementType},
      onSelectionChanged: (newSelection) {
        setState(() => _movementType = newSelection.first);
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final amount = (double.parse(_amountController.text) * 100).toInt();
    final user = ref.read(authStateProvider);
    final session = ref.read(cashSessionProvider).asData?.value;

    if (user != null && session != null) {
      try {
        await ref.read(cashMovementProvider.notifier).createMovement(
              session.id!,
              _movementType,
              amount,
              _reason,
              description: _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
            );

        // Wait for the provider to update before popping
        await ref.read(cashSessionProvider.notifier).getCurrentSession(session.userId);

        if (mounted) {
          context.pop();
        }
      } catch (e) {
        // Handle error, e.g., show a SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save movement: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    } else {
      setState(() => _isSubmitting = false);
    }
  }
}

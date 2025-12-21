import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class WeightInputDialog extends StatefulWidget {
  final Product product;
  final ProductVariant? variant;

  const WeightInputDialog({super.key, required this.product, this.variant});

  @override
  State<WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends State<WeightInputDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text);
    if (value != null && value > 0) {
      Navigator.pop(context, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.scale_rounded,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ingresar Peso',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.name,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (widget.variant != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.variant!.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Cantidad en peso',
                hintText: '0.0',
                helperText:
                    'Ingresar peso en ${widget.product.unitName ?? 'kg'}',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                suffixStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
                suffixText: widget.product.unitName ?? 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Agregar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

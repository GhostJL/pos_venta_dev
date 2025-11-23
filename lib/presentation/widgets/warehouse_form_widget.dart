import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/core/constants/ui_constants.dart';

class WarehouseFormWidget extends ConsumerStatefulWidget {
  final Warehouse? warehouse;
  final VoidCallback? onSuccess;

  const WarehouseFormWidget({super.key, this.warehouse, this.onSuccess});

  @override
  ConsumerState<WarehouseFormWidget> createState() =>
      _WarehouseFormWidgetState();
}

class _WarehouseFormWidgetState extends ConsumerState<WarehouseFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  String? _address;
  String? _phone;
  late bool _isMain;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.warehouse?.name ?? '';
    _code = widget.warehouse?.code ?? '';
    _address = widget.warehouse?.address;
    _phone = widget.warehouse?.phone;
    _isMain = widget.warehouse?.isMain ?? false;
    _isActive = widget.warehouse?.isActive ?? true;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final newWarehouse = Warehouse(
          id: widget.warehouse?.id,
          name: _name,
          code: _code,
          address: _address,
          phone: _phone,
          isMain: _isMain,
          isActive: _isActive,
        );

        final notifier = ref.read(warehouseProvider.notifier);
        if (widget.warehouse == null) {
          await notifier.addWarehouse(newWarehouse);
        } else {
          await notifier.editWarehouse(newWarehouse);
        }

        if (mounted) {
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Almacén guardado correctamente'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar el almacén: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.warehouse == null;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
      ),
      elevation: 0,
      backgroundColor: AppTheme.background,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          isCreating ? 'Añadir Almacén' : 'Editar Almacén',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Almacén',
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo requerido'
                      : null,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: UIConstants.spacingMedium),
                TextFormField(
                  initialValue: _code,
                  decoration: const InputDecoration(labelText: 'Código Único'),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo requerido'
                      : null,
                  onSaved: (value) => _code = value!,
                ),
                const SizedBox(height: UIConstants.spacingMedium),
                TextFormField(
                  initialValue: _address,
                  decoration: const InputDecoration(
                    labelText: 'Dirección (Opcional)',
                  ),
                  onSaved: (value) => _address = value,
                ),
                const SizedBox(height: UIConstants.spacingMedium),
                TextFormField(
                  initialValue: _phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (Opcional)',
                  ),
                  onSaved: (value) => _phone = value,
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                _SwitchTile(
                  title: 'Almacén Principal',
                  subtitle: 'Define si este es el almacén por defecto.',
                  value: _isMain,
                  onChanged: (value) => setState(() => _isMain = value),
                ),
                const SizedBox(height: 16),
                _SwitchTile(
                  title: 'Almacén Activo',
                  subtitle:
                      'Los almacenes inactivos no se mostrarán en las operaciones.',
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isCreating ? 'Guardar' : 'Actualizar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';

class WarehouseForm extends ConsumerStatefulWidget {
  final Warehouse? warehouse;

  const WarehouseForm({super.key, this.warehouse});

  @override
  ConsumerState<WarehouseForm> createState() => _WarehouseFormState();
}

class _WarehouseFormState extends ConsumerState<WarehouseForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  String? _address;
  String? _phone;
  late bool _isMain;
  late bool _isActive;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _name = widget.warehouse?.name ?? '';
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
        final code =
            widget.warehouse?.code ??
            'ALM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

        final newWarehouse = Warehouse(
          id: widget.warehouse?.id,
          name: _name,
          code: code,
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
          Navigator.of(context).pop(true);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Almacén guardado correctamente'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar el almacén: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
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
    final title = widget.warehouse == null
        ? 'Añadir Almacén'
        : 'Editar Almacén';
    final submitText = widget.warehouse == null ? 'Guardar' : 'Actualizar';

    return GenericFormScaffold(
      title: title,
      isLoading: _isLoading,
      onSubmit: _submit,
      submitButtonText: submitText,
      formKey: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(
              labelText: 'Nombre del Almacén',
              prefixIcon: Icon(Icons.store_mall_directory_rounded),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Campo requerido' : null,
            onSaved: (value) => _name = value!,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _address,
            decoration: const InputDecoration(
              labelText: 'Dirección (Opcional)',
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
            onSaved: (value) => _address = value,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono (Opcional)',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
            onSaved: (value) => _phone = value,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _SwitchTile(
            title: 'Almacén Principal',
            subtitle: 'Define si este es el almacén por defecto.',
            value: _isMain,
            onChanged: (value) => setState(() => _isMain = value),
            icon: Icons.star_rounded,
          ),
          const SizedBox(height: 16),
          _SwitchTile(
            title: 'Almacén Activo',
            subtitle:
                'Los almacenes inactivos no se mostrarán en las operaciones.',
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

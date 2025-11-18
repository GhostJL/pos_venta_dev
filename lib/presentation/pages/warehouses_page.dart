import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';

class WarehousesPage extends ConsumerWidget {
  const WarehousesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehouseProvider);

    void showWarehouseForm([Warehouse? warehouse]) {
      showDialog(
        context: context,
        builder: (context) => WarehouseForm(warehouse: warehouse),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Almacenes'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: warehousesAsync.when(
          data: (warehouses) {
            return CustomDataTable<Warehouse>(
              itemCount: warehouses.length,
              onAddItem: () => showWarehouseForm(),
              emptyText: 'No hay almacenes registrados.',
              columns: const [
                DataColumn(label: Text('NOMBRE')),
                DataColumn(label: Text('CÓDIGO')),
                DataColumn(label: Text('PRINCIPAL')),
                DataColumn(label: Text('ESTADO')),
                DataColumn(label: Text('ACCIONES')),
              ],
              rows: warehouses.map((warehouse) {
                return DataRow(
                  cells: [
                    DataCell(Text(warehouse.name)),
                    DataCell(Text(warehouse.code)),
                    DataCell(
                      Chip(
                        label: Text(warehouse.isMain ? 'Sí' : 'No'),
                        backgroundColor: warehouse.isMain
                            ? AppTheme.primary.withAlpha(25)
                            : AppTheme.inputBackground,
                        labelStyle: TextStyle(
                          color: warehouse.isMain
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2),
                      ),
                    ),
                    DataCell(
                      Chip(
                        label: Text(warehouse.isActive ? 'Activo' : 'Inactivo'),
                        backgroundColor: warehouse.isActive
                            ? AppTheme.success.withAlpha(25)
                            : AppTheme.error.withAlpha(25),
                        labelStyle: TextStyle(
                            color: warehouse.isActive
                                ? AppTheme.success
                                : AppTheme.error,
                            fontWeight: FontWeight.w600),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: AppTheme.textSecondary,
                            onPressed: () => showWarehouseForm(warehouse),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppTheme.textSecondary,
                            onPressed: () {
                              ref
                                  .read(warehouseProvider.notifier)
                                  .removeWarehouse(warehouse.id!);
                            },
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class WarehouseForm extends ConsumerStatefulWidget {
  final Warehouse? warehouse;

  const WarehouseForm({super.key, this.warehouse});

  @override
  ConsumerState<WarehouseForm> createState() => _WarehouseFormState();
}

class _WarehouseFormState extends ConsumerState<WarehouseForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  String? _address;
  String? _phone;
  late bool _isMain;
  late bool _isActive;

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
        notifier.addWarehouse(newWarehouse);
      } else {
        notifier.editWarehouse(newWarehouse);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.warehouse == null;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del Almacén'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Campo requerido' : null,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _code,
                  decoration: const InputDecoration(labelText: 'Código Único'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Campo requerido' : null,
                  onSaved: (value) => _code = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _address,
                  decoration:
                      const InputDecoration(labelText: 'Dirección (Opcional)'),
                  onSaved: (value) => _address = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _phone,
                  decoration:
                      const InputDecoration(labelText: 'Teléfono (Opcional)'),
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
                  onPressed: _submit,
                  child: Text(isCreating ? 'Guardar' : 'Actualizar'),
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
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

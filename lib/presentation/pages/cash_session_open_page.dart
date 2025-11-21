import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/permission_denied_widget.dart';

class CashSessionOpenPage extends ConsumerStatefulWidget {
  const CashSessionOpenPage({super.key});

  @override
  ConsumerState<CashSessionOpenPage> createState() =>
      _CashSessionOpenPageState();
}

class _CashSessionOpenPageState extends ConsumerState<CashSessionOpenPage> {
  final TextEditingController _amountController = TextEditingController();
  int? _selectedWarehouseId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _openSession() async {
    if (_selectedWarehouseId == null) {
      setState(() {
        _errorMessage = 'Debe seleccionar una sucursal';
      });
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _errorMessage = 'Debe ingresar el fondo inicial';
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) {
      setState(() {
        _errorMessage = 'El monto debe ser un número válido y no negativo';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final openingBalanceCents = (amount * 100).round();
      await ref
          .read(openCashSessionUseCaseProvider)
          .call(_selectedWarehouseId!, openingBalanceCents);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Caja abierta exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Invalidar el provider para que el Guard detecte la nueva sesión
        ref.invalidate(currentCashSessionProvider);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehouseProvider);
    final user = ref.watch(authProvider).user;
    final hasOpenPermission = ref.watch(
      hasPermissionProvider(PermissionConstants.cashOpen),
    );

    if (!hasOpenPermission) {
      return PermissionDeniedWidget(
        message:
            'No tienes permiso para abrir sesiones de caja.\n\nContacta a un administrador para obtener acceso.',
        icon: Icons.point_of_sale_outlined,
        backRoute: '/home',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apertura de Caja'),
        centerTitle: true,
        automaticallyImplyLeading: false, // No permitir cerrar sin abrir caja
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icono y título
                    Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Apertura de Turno',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bienvenido, ${user?.firstName ?? 'Usuario'}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Selección de sucursal
                    const Text(
                      'Sucursal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    warehousesAsync.when(
                      data: (warehouses) {
                        if (warehouses.isEmpty) {
                          return const Text(
                            'No hay sucursales disponibles',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                        // Seleccionar automáticamente si solo hay una
                        if (_selectedWarehouseId == null &&
                            warehouses.length == 1) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _selectedWarehouseId = warehouses.first.id;
                            });
                          });
                        }
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedWarehouseId,
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              hint: const Text('Seleccione una sucursal'),
                              items: warehouses
                                  .map(
                                    (warehouse) => DropdownMenuItem(
                                      value: warehouse.id,
                                      child: Text(warehouse.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedWarehouseId = value;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Fondo inicial
                    const Text(
                      'Fondo Inicial de Caja',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingrese el monto en efectivo con el que inicia su turno',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Mensaje de error
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Botón de apertura
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _openSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'ABRIR CAJA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

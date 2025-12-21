import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/layouts/permission_denied_widget.dart';
import 'package:posventa/presentation/widgets/common/error_message_box.dart';
import 'package:posventa/presentation/widgets/common/money_input_field.dart';
import 'package:posventa/presentation/widgets/common/centered_form_card.dart';
import 'package:posventa/core/theme/theme.dart';

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
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            content: Text('Caja abierta exitosamente'),
            backgroundColor: AppTheme.transactionSuccess,
          ),
        );
        // Invalidar el provider para que el Guard detecte la nueva sesión
        ref.invalidate(currentCashSessionProvider);

        // Navigate to dashboard
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to warehouse provider to auto-select if there is only one
    ref.listen(warehouseProvider, (previous, next) {
      next.whenData((warehouses) {
        if (warehouses.length == 1 && _selectedWarehouseId == null) {
          setState(() {
            _selectedWarehouseId = warehouses.first.id;
          });
        }
      });
    });

    final warehousesAsync = ref.watch(warehouseProvider);
    final user = ref.watch(authProvider).user;
    final hasOpenPermission = ref.watch(
      hasPermissionProvider(PermissionConstants.cashOpen),
    );

    if (!hasOpenPermission) {
      return PermissionDeniedWidget(
        message:
            'No puedes iniciar el sistema.\n\nContacta a un administrador para obtener acceso.',
        icon: Icons.lock_outline,
        primaryButtonText: 'Cerrar sesión e ir al login',
        onPrimaryPressed: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
        showSecondaryButton: false,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apertura de Caja'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: CenteredFormCard(
        icon: Icons.storefront_rounded,
        title: 'Iniciar Jornada',
        subtitle: 'Bienvenido, ${user?.firstName ?? 'Usuario'}',
        children: [
          // Selección de sucursal
          const Text(
            'Sucursal',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          warehousesAsync.when(
            data: (warehouses) {
              if (warehouses.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.domain_disabled_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No hay sucursales registradas.\nContacte al administrador.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // If only one, show it as read-only or auto-selected
              if (warehouses.length == 1 && _selectedWarehouseId == null) {
                // Already handled by listener, but for build safety:
                // We don't setState here.
              }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedWarehouseId,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    hint: const Text('Seleccione una sucursal'),
                    items: warehouses
                        .map(
                          (warehouse) => DropdownMenuItem(
                            value: warehouse.id,
                            child: Text(
                              warehouse.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text(
              'Error al cargar sucursales',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          const SizedBox(height: 24),

          // Fondo inicial
          MoneyInputField(
            controller: _amountController,
            label: 'Fondo Inicial',
            helpText: 'Efectivo disponible en caja al inicio',
            autofocus: true,
          ),
          const SizedBox(height: 24),

          // Mensaje de error
          if (_errorMessage != null) ...[
            ErrorMessageBox(message: _errorMessage!),
            const SizedBox(height: 16),
          ],

          // Botón de apertura
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _isLoading ? null : _openSession,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Text(
                      'ABRIR TURNO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

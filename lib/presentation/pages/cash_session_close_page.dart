import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

class CashSessionClosePage extends ConsumerStatefulWidget {
  final bool isLogoutIntent;
  const CashSessionClosePage({super.key, this.isLogoutIntent = false});

  @override
  ConsumerState<CashSessionClosePage> createState() =>
      _CashSessionClosePageState();
}

class _CashSessionClosePageState extends ConsumerState<CashSessionClosePage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _closeSession() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _errorMessage = 'Debe ingresar el efectivo contado';
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
      final currentSession = await ref
          .read(getCurrentCashSessionUseCaseProvider)
          .call();

      if (currentSession == null) {
        throw Exception('No hay una sesión de caja abierta');
      }

      final closingBalanceCents = (amount * 100).round();
      final closedSession = await ref
          .read(closeCashSessionUseCaseProvider)
          .call(currentSession.id!, closingBalanceCents);

      if (mounted) {
        // Mostrar resumen del cierre
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildCloseSummaryDialog(closedSession),
        );

        // Invalidar sesión
        ref.invalidate(currentCashSessionProvider);

        if (widget.isLogoutIntent) {
          if (mounted) {
            ref.read(authProvider.notifier).logout();
          }
        } else {
          if (mounted) {
            // Si no es logout, redirigir a home (que mostrará la pantalla de apertura)
            context.go('/home');
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Widget _buildCloseSummaryDialog(dynamic session) {
    final openingBalance = session.openingBalanceCents / 100;
    final expectedBalance = (session.expectedBalanceCents ?? 0) / 100;
    final closingBalance = (session.closingBalanceCents ?? 0) / 100;
    final difference = (session.differenceCents ?? 0) / 100;
    final isBalanced = difference.abs() < 0.01; // Tolerancia de 1 centavo

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning,
            color: isBalanced ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Resumen de Cierre')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryRow('Fondo Inicial:', openingBalance),
          const Divider(height: 24),
          _buildSummaryRow('Efectivo Esperado:', expectedBalance, isBold: true),
          const SizedBox(height: 8),
          _buildSummaryRow('Efectivo Contado:', closingBalance, isBold: true),
          const Divider(height: 24),
          _buildSummaryRow(
            'Diferencia:',
            difference,
            isBold: true,
            color: difference == 0
                ? Colors.green
                : (difference > 0 ? Colors.blue : Colors.red),
          ),
          if (!isBalanced) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: difference > 0
                    ? Colors.blue.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    difference > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: difference > 0
                        ? Colors.blue.shade700
                        : Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      difference > 0
                          ? 'Sobrante de efectivo'
                          : 'Faltante de efectivo',
                      style: TextStyle(
                        color: difference > 0
                            ? Colors.blue.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ACEPTAR'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si el usuario está autenticado
    final user = ref.watch(authProvider).user;
    if (user == null) {
      // Si no hay usuario (logout en proceso), mostrar carga o nada
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final sessionAsync = ref.watch(currentCashSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cierre de Caja'), centerTitle: true),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
        data: (session) {
          if (session == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay una sesión de caja abierta'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final openingBalance = session.openingBalanceCents / 100;
          final openedAt = session.openedAt;
          final duration = DateTime.now().difference(openedAt);
          final hours = duration.inHours;
          final minutes = duration.inMinutes.remainder(60);

          return Center(
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
                          Icons.lock_clock,
                          size: 64,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cierre de Turno',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Información de la sesión
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Fondo Inicial:'),
                                  Text(
                                    '\$${openingBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tiempo de turno:'),
                                  Text(
                                    '${hours}h ${minutes}m',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Conteo de efectivo
                        const Text(
                          'Conteo de Efectivo',
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
                          'Ingrese el total de efectivo contado en caja',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Botón de cierre
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _closeSession,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
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
                                    'CERRAR CAJA',
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
          );
        },
      ),
    );
  }
}

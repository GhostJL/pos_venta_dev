import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/customer_payment.dart';
import 'package:posventa/features/customers/presentation/widgets/customer_payment_dialog.dart';
import 'package:posventa/presentation/providers/di/customer_di.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

class CustomerDetailsPage extends ConsumerStatefulWidget {
  final int customerId;

  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailsPage> createState() =>
      _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We should fetch the single customer by ID to get fresh data (especially credit balance)
    // Assuming we have a provider or can filter from list.
    // Ideally use a specialized provider for details.
    // implementing a simple one-off fetch or using a Family provider for stream updates would be best.
    // For now, let's try to get it from the list or fetch it.

    // We can use a FutureProvider family?
    // Or just look it up.

    // final customerAsync = ref.watch(
    //   customerProvider,
    // ); // This returns List<Customer>

    // Better: use a stream or future provider for single customer.
    // I'll assume we can pass the customer object via route extra, but we want live updates.
    // I'll create a local provider or fetch calling UseCase.

    final customerAsync = ref.watch(customerByIdProvider(widget.customerId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Cliente'),
        actions: [
          customerAsync.when(
            data: (customer) => customer != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.push('/customers/form', extra: customer);
                    },
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Transacciones'),
          ],
        ),
      ),
      body: AsyncValueHandler<Customer?>(
        value: customerAsync,
        data: (customer) {
          if (customer == null) {
            return const Center(child: Text('Cliente no encontrado'));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(context, customer),
              _buildTransactionsTab(context, customer.id!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionsTab(BuildContext context, int customerId) {
    // We need to fetch both sales and payments to show a complete history
    final historyAsync = ref.watch(customerHistoryProvider(customerId));

    return AsyncValueHandler<List<dynamic>>(
      value: historyAsync,
      data: (historyItems) {
        if (historyItems.isEmpty) {
          return const Center(child: Text('No hay transacciones registradas'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            final item = historyItems[index];

            if (item is Sale) {
              return _buildSaleItem(context, item);
            } else if (item is CustomerPayment) {
              return _buildPaymentItem(context, item);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildSaleItem(BuildContext context, Sale sale) {
    final isCredit = sale.payments.any((p) => p.paymentMethod == 'Crédito');
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha(50),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? Theme.of(context).colorScheme.tertiaryContainer
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            isCredit ? Icons.credit_card : Icons.shopping_bag,
            color: isCredit
                ? Theme.of(context).colorScheme.onTertiaryContainer
                : Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          sale.saleNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${sale.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCredit ? Theme.of(context).colorScheme.error : null,
              ),
            ),
            Text(
              sale.status.name.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        onTap: () {
          // Navigate to sale details?
        },
      ),
    );
  }

  Widget _buildPaymentItem(BuildContext context, CustomerPayment payment) {
    final isVoided = payment.status == 'voided';
    final color = isVoided ? Colors.grey : Colors.green;
    final bgColor = isVoided
        ? Colors.grey.withAlpha(50)
        : Colors.green.withAlpha(20);
    final borderColor = isVoided
        ? Colors.grey.withAlpha(100)
        : Colors.green.withAlpha(50);

    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(50),
          child: Icon(
            isVoided ? Icons.block : Icons.payment,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          isVoided ? 'Abono (ANULADO)' : 'Abono a Cuenta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            decoration: isVoided ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd/MM/yyyy HH:mm').format(payment.paymentDate)),
            if (payment.saleId != null)
              Text(
                'Asignado a Nota #${payment.saleId}', // Could fetch sale number if joined, but ID is okay or verify join
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            if (payment.notes != null && payment.notes!.isNotEmpty)
              Text(
                payment.notes!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (payment.processedByName != null)
              Text(
                'Atendido por: ${payment.processedByName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+\$${payment.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                decoration: isVoided ? TextDecoration.lineThrough : null,
              ),
            ),
            if (!isVoided)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'void') {
                    _confirmVoidPayment(context, payment);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'void',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Anular', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context, Customer customer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final creditLimit = customer.creditLimit;
    final creditUsed = customer.creditUsed;
    final available = creditLimit != null ? creditLimit - creditUsed : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Basic Info Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            customer.firstName.isNotEmpty
                                ? customer.firstName[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.fullName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              customer.code,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (customer.businessName != null) ...[
                    _InfoRow(
                      icon: Icons.business,
                      label: 'Negocio',
                      value: customer.businessName!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (customer.phone != null) ...[
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: customer.phone!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (customer.email != null) ...[
                    _InfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: customer.email!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (customer.address != null) ...[
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Dirección',
                      value: customer.address!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Credit Dashboard
          Text(
            'Crédito',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CreditCard(
                  title: 'Usado',
                  amount: creditUsed,
                  color: colorScheme.error,
                  icon: Icons.credit_card_off,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CreditCard(
                  title: 'Disponible',
                  amount: available,
                  isLimit: creditLimit == null,
                  color: colorScheme.primary,
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CreditCard(
            title: 'Límite Total',
            amount: creditLimit,
            isLimit: creditLimit == null,
            color: colorScheme.tertiary,
            icon: Icons.account_balance_wallet,
            isFullWidth: true,
          ),

          const SizedBox(height: 24),

          // Actions
          if (creditUsed > 0)
            FilledButton.icon(
              onPressed: () {
                _showPaymentDialog(context, customer);
              },
              icon: const Icon(Icons.payment),
              label: const Text('Registrar Pago de Deuda'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => CustomerPaymentDialog(customer: customer),
    );
  }

  Future<void> _confirmVoidPayment(
    BuildContext context,
    CustomerPayment payment,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final reasonController = TextEditingController();
    final shouldVoid = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anular Abono'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Está seguro de anular el abono de \$${payment.amount.toStringAsFixed(2)}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo de anulación',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese un motivo')),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Anular'),
          ),
        ],
      ),
    );

    if (shouldVoid == true && mounted) {
      final user = ref.read(authProvider).user;
      final userId = user?.id ?? 1;

      try {
        await ref
            .read(customerRepositoryProvider)
            .voidPayment(
              paymentId: payment.id!,
              performedBy: userId,
              reason: reasonController.text,
            );

        messenger.showSnackBar(
          const SnackBar(content: Text('Abono anulado correctamente')),
        );
        // Refresh
        ref.invalidate(customerHistoryProvider(payment.customerId));
        ref.invalidate(customerByIdProvider(payment.customerId));
        ref.invalidate(customerProvider);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Error al anular: $e')));
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreditCard extends StatelessWidget {
  final String title;
  final double? amount;
  final bool isLimit;
  final Color color;
  final IconData icon;
  final bool isFullWidth;

  const _CreditCard({
    required this.title,
    this.amount,
    this.isLimit = false,
    required this.color,
    required this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20), // deprecated: withOpacity
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isLimit && amount == null
                ? 'Sin Límite'
                : (amount != null ? '\$${amount!.toStringAsFixed(2)}' : '-'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

final customerSalesProvider = StreamProvider.family<List<Sale>, int>((
  ref,
  customerId,
) {
  final repository = ref.read(saleRepositoryProvider);
  return repository.getSalesStream(customerId: customerId);
});

final customerPaymentsProvider =
    StreamProvider.family<List<CustomerPayment>, int>((ref, customerId) {
      final repository = ref.read(customerRepositoryProvider);
      return repository.getPaymentsStream(customerId);
    });

final customerHistoryProvider = Provider.family<AsyncValue<List<dynamic>>, int>(
  (ref, customerId) {
    final salesAsync = ref.watch(customerSalesProvider(customerId));
    final paymentsAsync = ref.watch(customerPaymentsProvider(customerId));

    // If either is loading and we don't have data yet, show loading
    if (salesAsync.isLoading || paymentsAsync.isLoading) {
      if (!salesAsync.hasValue && !paymentsAsync.hasValue) {
        return const AsyncValue.loading();
      }
    }

    // If we have errors
    if (salesAsync.hasError) {
      return AsyncValue.error(salesAsync.error!, salesAsync.stackTrace!);
    }
    if (paymentsAsync.hasError) {
      return AsyncValue.error(paymentsAsync.error!, paymentsAsync.stackTrace!);
    }

    final sales = salesAsync.value ?? [];
    final payments = paymentsAsync.value ?? [];

    final combined = [...sales, ...payments];

    combined.sort((a, b) {
      DateTime dateA;
      DateTime dateB;

      if (a is Sale) {
        dateA = a.saleDate;
      } else if (a is CustomerPayment) {
        dateA = a.paymentDate;
      } else {
        dateA = DateTime(0);
      }

      if (b is Sale) {
        dateB = b.saleDate;
      } else if (b is CustomerPayment) {
        dateB = b.paymentDate;
      } else {
        dateB = DateTime(0);
      }

      return dateB.compareTo(dateA); // Descending
    });

    return AsyncValue.data(combined);
  },
);

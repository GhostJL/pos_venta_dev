import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:intl/intl.dart';

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
    final transactionsAsync = ref.watch(
      customerTransactionsProvider(customerId),
    );

    return AsyncValueHandler<List<Sale>>(
      value: transactionsAsync,
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(child: Text('No hay transacciones registradas'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final sale = transactions[index];
            final isCredit = sale.payments.any(
              (p) => p.paymentMethod == 'Crédito',
            );

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
                    isCredit ? Icons.credit_card : Icons.attach_money,
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
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${sale.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCredit
                            ? Theme.of(context).colorScheme.error
                            : null,
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
          },
        );
      },
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
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Deuda actual: \$${customer.creditUsed.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto a pagar',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                // Determine logic: We update the debt in CustomerNotifier
                // But we are in Details Page with specialized provider.
                // We should call CustomerNotifier to handle the logic logic
                await ref
                    .read(customerProvider.notifier)
                    .payDebt(customer.id!, amount);
                // Also invalidate local provider
                ref.invalidate(customerByIdProvider(customer.id!));

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pago registrado correctamente'),
                    ),
                  );
                }
              }
            },
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
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

final customerTransactionsProvider = StreamProvider.family<List<Sale>, int>((
  ref,
  customerId,
) {
  final repository = ref.read(saleRepositoryProvider);
  return repository.getSalesStream(customerId: customerId);
});

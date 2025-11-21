import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/payment_dialog.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class CartSection extends ConsumerWidget {
  final bool isMobile;

  const CartSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posState = ref.watch(pOSProvider);
    final posNotifier = ref.read(pOSProvider.notifier);
    final hasVoidPermission = ref.watch(
      hasPermissionProvider(PermissionConstants.posVoidItem),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: isMobile
            ? null
            : Border(
                left: BorderSide(color: Colors.grey.shade300),
                top: BorderSide(color: Colors.grey.shade300),
              ),
      ),
      child: Column(
        children: [
          // Customer Selection
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const CustomerSelectionDialog(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        posState.selectedCustomer != null
                            ? '${posState.selectedCustomer!.firstName} ${posState.selectedCustomer!.lastName}'
                            : 'Cliente General',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ),

          // Cart Items List
          Expanded(
            child: posState.cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carrito vacío',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: posState.cart.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade300),
                    itemBuilder: (context, index) {
                      final item = posState.cart[index];
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product name and remove button
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.productName ?? 'Producto',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                if (hasVoidPermission)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () {
                                      posNotifier.removeFromCart(
                                        item.productId,
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Quantity controls and price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Quantity controls
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          posNotifier.updateQuantity(
                                            item.productId,
                                            item.quantity - 1,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          item.quantity.toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          posNotifier.updateQuantity(
                                            item.productId,
                                            item.quantity + 1,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(
                                            Icons.add,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${(item.unitPriceCents / 100).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (item.taxCents > 0)
                                      Text(
                                        '+ Imp: \$${(item.taxCents / 100).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    Text(
                                      '\$${(item.totalCents / 100).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Totals and Checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTotalRow('Subtotal', posState.subtotal),
                _buildTotalRow('Impuestos', posState.tax),
                if (posState.discount > 0)
                  _buildTotalRow(
                    'Descuento',
                    posState.discount,
                    isDiscount: true,
                  ),
                const Divider(height: 24),
                _buildTotalRow(
                  'TOTAL',
                  posState.total,
                  isBold: true,
                  fontSize: 20,
                ),
                const SizedBox(height: 16),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: posState.cart.isEmpty
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => const PaymentDialog(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'PROCESAR PAGO',
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
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 14,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerSelectionDialog extends ConsumerStatefulWidget {
  const CustomerSelectionDialog({super.key});

  @override
  ConsumerState<CustomerSelectionDialog> createState() =>
      _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState
    extends ConsumerState<CustomerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Seleccionar Cliente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar cliente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  ref.read(customerProvider.notifier).searchCustomers(value);
                },
              ),
            ),

            // Customer List
            Flexible(
              child: customersAsync.when(
                data: (customers) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          title: const Text(
                            'Público General',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          onTap: () {
                            ref.read(pOSProvider.notifier).selectCustomer(null);
                            Navigator.of(context).pop();
                          },
                        );
                      }
                      final customer = customers[index - 1];
                      return ListTile(
                        title: Text(
                          '${customer.firstName} ${customer.lastName}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(customer.email ?? customer.code),
                        onTap: () {
                          ref
                              .read(pOSProvider.notifier)
                              .selectCustomer(customer);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Error: $err'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

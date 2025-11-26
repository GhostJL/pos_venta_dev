import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';

class SaleSearchWidget extends ConsumerStatefulWidget {
  const SaleSearchWidget({super.key});

  @override
  ConsumerState<SaleSearchWidget> createState() => _SaleSearchWidgetState();
}

class _SaleSearchWidgetState extends ConsumerState<SaleSearchWidget> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Sale> _searchResults = [];
  int _selectedDaysLimit = 30; // Default to 30 days

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchSales(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Fetch all sales using the getSalesUseCase
      final getSalesUseCase = ref.read(getSalesUseCaseProvider);

      // Calculate start date based on selected limit
      final startDate = DateTime.now().subtract(
        Duration(days: _selectedDaysLimit),
      );

      // Pass startDate to use case (assuming repository handles filtering or we filter manually if not)
      // Since we are filtering in memory in the original code, we should ideally pass this to the use case
      // to avoid fetching all sales. However, based on the previous code, it seemed to fetch all.
      // We will pass it to the use case now.
      final sales = await getSalesUseCase(startDate: startDate);

      // Filter sales by sale number or customer name
      final filtered = sales.where((sale) {
        final matchesNumber = sale.saleNumber.toLowerCase().contains(
          query.toLowerCase(),
        );
        final matchesCustomer =
            sale.customerName?.toLowerCase().contains(query.toLowerCase()) ??
            false;
        return (matchesNumber || matchesCustomer) &&
            sale.status == SaleStatus.completed;
      }).toList();

      if (mounted) {
        setState(() {
          _searchResults = filtered;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por número de venta o cliente...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchSales('');
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppTheme.cardBackground,
          ),
          onChanged: (value) {
            _searchSales(value);
          },
        ),
        const SizedBox(height: 16),

        // Time limit selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text(
                'Mostrar ventas de:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              _buildTimeLimitChip(15, '15 días'),
              const SizedBox(width: 8),
              _buildTimeLimitChip(30, '30 días'),
              const SizedBox(width: 8),
              _buildTimeLimitChip(45, '45 días'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Search results
        if (_isSearching)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron ventas',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_searchResults.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final sale = _searchResults[index];
              return _buildSaleCard(sale);
            },
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingrese un número de venta o nombre de cliente',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _selectSale(sale),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.saleNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (sale.customerName != null)
                          Text(
                            sale.customerName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    _formatDate(sale.saleDate),
                  ),
                  _buildInfoChip(
                    Icons.shopping_cart,
                    '${sale.items.length} items',
                  ),
                  _buildInfoChip(
                    Icons.attach_money,
                    '\$${sale.total.toStringAsFixed(2)}',
                    isHighlighted: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.green.shade50 : AppTheme.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlighted
                ? Colors.green.shade700
                : AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isHighlighted
                  ? Colors.green.shade700
                  : AppTheme.textSecondary,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectSale(Sale sale) async {
    // Validate eligibility
    final validateUseCase = ref.read(validateReturnEligibilityUseCaseProvider);
    final canReturn = await validateUseCase(sale.id!);

    if (!canReturn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Esta venta no puede ser devuelta'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
      return;
    }

    // Select the sale
    ref.read(returnProcessingNotifierProvider.notifier).selectSale(sale);
  }

  Widget _buildTimeLimitChip(int days, String label) {
    final isSelected = _selectedDaysLimit == days;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedDaysLimit = days;
          });
          // Re-trigger search if there is a query, or just clear results if not
          if (_searchController.text.isNotEmpty) {
            _searchSales(_searchController.text);
          }
        }
      },
      selectedColor: Colors.orange.shade100,
      checkmarkColor: Colors.orange.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.orange.shade900 : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

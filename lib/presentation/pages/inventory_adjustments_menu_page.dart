import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';

class InventoryAdjustmentsMenuPage extends StatelessWidget {
  const InventoryAdjustmentsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Ajustes de Inventario'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 32),

          // Section 1: Transaction Correction
          _buildSectionTitle(
            context,
            'Corrección de Transacciones',
            Icons.receipt_long_rounded,
            Colors.blue.shade600,
          ),
          const SizedBox(height: 16),
          _buildTransactionCorrectionCards(context),
          const SizedBox(height: 32),

          // Section 2: Physical Inventory Adjustment
          _buildSectionTitle(
            context,
            'Ajuste de Inventario Físico',
            Icons.inventory_rounded,
            Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          _buildPhysicalInventoryCards(context),
          const SizedBox(height: 32),

          // Section 3: Cash Control
          _buildSectionTitle(
            context,
            'Control de Caja',
            Icons.account_balance_wallet_rounded,
            Colors.orange.shade600,
          ),
          const SizedBox(height: 16),
          _buildCashControlCards(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade700.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Módulo de Ajustes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona correcciones, ajustes y control de caja',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCorrectionCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: 3.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdjustmentCard(
              context,
              title: 'Anulación de Transacción',
              description: 'Anular ventas incorrectas o canceladas',
              icon: Icons.cancel_rounded,
              color: Colors.red.shade600,
              onTap: () => context.push('/adjustments/transaction-void'),
            ),
            _buildAdjustmentCard(
              context,
              title: 'Ajuste de Precios',
              description: 'Corregir precios o descuentos aplicados',
              icon: Icons.price_change_rounded,
              color: Colors.blue.shade600,
              onTap: () => context.push('/adjustments/price-adjustment'),
            ),
            _buildAdjustmentCard(
              context,
              title: 'Corrección de Pago',
              description: 'Modificar forma de pago registrada',
              icon: Icons.payment_rounded,
              color: Colors.purple.shade600,
              onTap: () => context.push('/adjustments/payment-correction'),
            ),
            _buildAdjustmentCard(
              context,
              title: 'Procesamiento de Devolución',
              description: 'Registrar devoluciones de productos',
              icon: Icons.keyboard_return_rounded,
              color: Colors.orange.shade600,
              onTap: () => context.push('/adjustments/return-processing'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhysicalInventoryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: 3.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdjustmentCard(
              context,
              title: 'Ajuste Individual/Masivo',
              description: 'Ajustar stock por producto o masivamente',
              icon: Icons.edit_note_rounded,
              color: Colors.green.shade600,
              onTap: () => context.push('/adjustments/physical-inventory'),
            ),
            _buildAdjustmentCard(
              context,
              title: 'Reversión por Devolución',
              description: 'Devolver productos al inventario',
              icon: Icons.undo_rounded,
              color: Colors.teal.shade600,
              onTap: () => context.push('/adjustments/inventory-reversal'),
            ),
            _buildAdjustmentCard(
              context,
              title: 'Registro de Mermas',
              description: 'Registrar productos dañados o caducados',
              icon: Icons.delete_sweep_rounded,
              color: Colors.red.shade700,
              onTap: () => context.push('/adjustments/damage-loss'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCashControlCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: 3.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdjustmentCard(
              context,
              title: 'Ingresos/Egresos',
              description: 'Registrar movimientos de efectivo',
              icon: Icons.swap_vert_rounded,
              color: Colors.orange.shade600,
              onTap: () => context.push('/adjustments/cash-movements'),
            ),
            _buildAdjustmentCard(
              context,
              title: 'Ajuste de Recibidos',
              description: 'Corregir montos recibidos en caja',
              icon: Icons.account_balance_rounded,
              color: Colors.deepOrange.shade600,
              onTap: () => context.push('/adjustments/cash-adjustment'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdjustmentCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borders.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

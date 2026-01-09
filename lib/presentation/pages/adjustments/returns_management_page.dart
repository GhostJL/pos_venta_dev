import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/common/layouts/placeholder_page.dart';
import 'package:posventa/core/theme/theme.dart';

/// Returns Management Page (Gestión de Devoluciones)
class ReturnsManagementPage extends StatelessWidget {
  const ReturnsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      moduleName: 'Gestión de Devoluciones',
      showMenuButton: true,
      icon: Icons.keyboard_return_rounded,
      description:
          'Este módulo permitirá gestionar las devoluciones de productos, '
          'procesar reversos de ventas y mantener un historial completo de '
          'todas las transacciones de devolución.',
      accentColor: AppTheme.transactionPending,
      plannedFeatures: [
        'Búsqueda de ventas por folio o cliente',
        'Devolución parcial o total de productos',
        'Reintegro automático al inventario',
        'Generación de notas de crédito',
        'Historial de devoluciones',
        'Reportes de productos más devueltos',
        'Motivos de devolución configurables',
      ],
    );
  }
}

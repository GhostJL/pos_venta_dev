import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/placeholder_page.dart';

/// Kardex Page - Dedicated inventory movement tracking view
class KardexPage extends StatelessWidget {
  const KardexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      moduleName: 'Kardex (Movimientos)',
      icon: Icons.history_rounded,
      description:
          'Vista dedicada del Kardex que muestra el historial completo de '
          'movimientos de inventario con saldos, entradas y salidas para '
          'cada producto y almacén.',
      accentColor: Colors.blue,
      plannedFeatures: [
        'Vista detallada por producto',
        'Filtros por almacén, fecha y tipo de movimiento',
        'Cálculo de saldos en tiempo real',
        'Entradas (compras, ajustes, traspasos)',
        'Salidas (ventas, mermas, traspasos)',
        'Exportación a Excel/PDF',
        'Gráficas de tendencias de inventario',
        'Alertas de stock bajo',
      ],
    );
  }
}

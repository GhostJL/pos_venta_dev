import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/placeholder_page.dart';

/// Inventory Adjustments Page (Ajustes de Inventario)
class InventoryAdjustmentsPage extends StatelessWidget {
  const InventoryAdjustmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      moduleName: 'Ajustes de Inventario',
      icon: Icons.tune_rounded,
      description:
          'Este módulo permitirá realizar ajustes manuales al inventario, '
          'registrar mermas, daños y correcciones de faltantes o sobrantes '
          'con trazabilidad completa.',
      accentColor: Colors.deepPurple,
      plannedFeatures: [
        'Ajustes por producto individual o masivos',
        'Registro de mermas y productos dañados',
        'Corrección de faltantes y sobrantes',
        'Motivos de ajuste configurables',
        'Aprobación de ajustes (para montos grandes)',
        'Historial de ajustes con auditoría',
        'Impacto automático en Kardex',
        'Reportes de ajustes por período',
      ],
    );
  }
}

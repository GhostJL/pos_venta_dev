import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/placeholder_page.dart';

/// Reports and Analytics Dashboard Page
class ReportsAnalyticsPage extends StatelessWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      moduleName: 'Reportes y Análisis',
      icon: Icons.analytics_rounded,
      description:
          'Dashboard ejecutivo con reportes avanzados, análisis de ventas, '
          'utilidades, inventario y métricas clave del negocio.',
      accentColor: Colors.green,
      plannedFeatures: [
        'Dashboard ejecutivo con KPIs',
        'Reporte de ventas por período',
        'Análisis de utilidad y márgenes',
        'Productos más vendidos',
        'Análisis de clientes frecuentes',
        'Reporte de stock crítico',
        'Auditoría de caja consolidada',
        'Gráficas y tendencias',
        'Exportación a Excel/PDF',
        'Comparativas período vs período',
      ],
    );
  }
}

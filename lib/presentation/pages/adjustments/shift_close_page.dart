import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/placeholder_page.dart';

/// Shift Close Page - Quick access for cashiers to close their shift
class ShiftClosePage extends StatelessWidget {
  const ShiftClosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      moduleName: 'Cierre de Turno',
      icon: Icons.lock_clock_rounded,
      description:
          'Acceso rápido para que los cajeros cierren su turno de manera '
          'sencilla, con cuadre de caja y resumen de operaciones del día.',
      accentColor: Colors.deepOrange,
      plannedFeatures: [
        'Vista simplificada de cierre de caja',
        'Resumen de ventas del turno',
        'Conteo de efectivo y otros métodos de pago',
        'Cálculo automático de diferencias',
        'Registro de motivos de diferencia',
        'Impresión de corte de caja',
        'Confirmación de cierre',
        'Redirección automática al login',
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/placeholder_page.dart';

/// Tax and Store Configuration Page
class TaxStoreConfigPage extends StatelessWidget {
  const TaxStoreConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      moduleName: 'Configuración de Impuestos y Tiendas',
      icon: Icons.settings_rounded,
      description:
          'Configuración centralizada de parámetros del sistema, incluyendo '
          'información de la tienda, impuestos, métodos de pago y preferencias generales.',
      accentColor: Colors.teal,
      plannedFeatures: [
        'Información de la empresa (nombre, RFC, dirección)',
        'Configuración de sucursales/tiendas',
        'Gestión de tasas de impuesto por región',
        'Métodos de pago disponibles',
        'Configuración de tickets/facturas',
        'Preferencias de moneda y formato',
        'Configuración de notificaciones',
        'Parámetros de seguridad',
      ],
    );
  }
}

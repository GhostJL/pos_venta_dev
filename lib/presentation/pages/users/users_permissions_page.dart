import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/common/layouts/placeholder_page.dart';

/// Users and Permissions Management Page
class UsersPermissionsPage extends StatelessWidget {
  const UsersPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      moduleName: 'Usuarios y Permisos',
      icon: Icons.badge_rounded,
      description:
          'Este módulo permitirá gestionar usuarios del sistema, asignar roles, '
          'configurar permisos granulares y mantener la seguridad del acceso.',
      accentColor: Colors.indigo,
      plannedFeatures: [
        'Creación y edición de usuarios',
        'Asignación de roles (Admin, Gerente, Cajero, Espectador)',
        'Permisos granulares por módulo',
        'Activación/desactivación de usuarios',
        'Cambio de contraseñas',
        'Historial de accesos',
        'Auditoría de acciones por usuario',
        'Configuración de sesiones',
      ],
    );
  }
}

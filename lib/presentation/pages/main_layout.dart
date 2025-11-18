import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/side_menu.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Usa LayoutBuilder para crear un diseño responsivo
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define un punto de quiebre para pantallas pequeñas (ej. teléfonos móviles)
        final bool isSmallScreen = constraints.maxWidth < 768;

        if (isSmallScreen) {
          // Para pantallas pequeñas, usa un Scaffold con un Drawer
          return Scaffold(
            appBar: AppBar(
              // El AppBar se puede personalizar según sea necesario
            ),
            drawer: const Drawer(child: SideMenu()),
            body: child,
          );
        } else {
          // Para pantallas más grandes, usa una Fila con un menú lateral fijo
          return Scaffold(
            body: Row(
              children: [
                const SideMenu(),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
      },
    );
  }
}

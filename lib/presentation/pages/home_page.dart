import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/presentation/widgets/app_drawer.dart';

class HomePage extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const HomePage({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title;
    final path = state.uri.toString();

    if (path.startsWith('/departments')) {
      title = 'Departamentos';
    } else if (path.startsWith('/categories')) {
      title = 'Categorías';
    } else if (path.startsWith('/brands')) {
      title = 'Marcas';
    } else if (path.startsWith('/suppliers')) {
      title = 'Proveedores';
    } else {
      title = 'Panel de Control';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // El botón de logout ha sido removido de aquí
      ),
      drawer: const AppDrawer(), // El AppDrawer ya contiene la opción de logout
      body: child,
    );
  }
}

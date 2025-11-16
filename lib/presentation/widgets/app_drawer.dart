import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Menú de Gestión',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Panel de Control'),
            onTap: () {
              context.go('/');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Departamentos'),
            onTap: () {
              context.go('/departments');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () {
              context.go('/categories');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Marcas'),
            onTap: () {
              context.go('/brands');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Proveedores'),
            onTap: () {
              context.go('/suppliers');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

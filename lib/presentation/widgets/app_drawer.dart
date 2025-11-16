import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final accountName = user?.firstName ?? 'Usuario';
    final accountEmail = user != null
        ? (user.role == UserRole.admin ? 'Administrador' : 'Cajero')
        : 'Rol no disponible';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              accountName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(accountEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: Text(
                accountName.isNotEmpty ? accountName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Panel de Control'),
            onTap: () {
              if (context.canPop()) Navigator.pop(context);
              context.go('/');
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text(
              'Gestión de Catálogo',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store_outlined),
            title: const Text('Departamentos'),
            onTap: () {
              if (context.canPop()) Navigator.pop(context);
              context.go('/departments');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categorías'),
            onTap: () {
              if (context.canPop()) Navigator.pop(context);
              context.go('/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text('Marcas'),
            onTap: () {
              if (context.canPop()) Navigator.pop(context);
              context.go('/brands');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Proveedores'),
            onTap: () {
              if (context.canPop()) Navigator.pop(context);
              context.go('/suppliers');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              if (context.canPop()) Navigator.pop(context); // Close the drawer
              // The router's redirect logic will handle navigation to /login
            },
          ),
        ],
      ),
    );
  }
}

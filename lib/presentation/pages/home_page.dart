import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const HomePage({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the title based on the current route
    final String title;
    if (state.uri.toString().startsWith('/departments')) {
      title = 'Departments';
    } else {
      title = 'Dashboard';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // The back button will be automatically managed by the router
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: child, // The nested screen from the router
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/app/router.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Listen to authentication changes to trigger side-effects
    ref.listen(authStateProvider, (previous, next) {
      // When the user logs in, fetch their current cash session.
      if (next != null && previous == null) {
        ref.read(cashSessionProvider.notifier).getCurrentSession(next.id!);
      }
    });

    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Auth App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

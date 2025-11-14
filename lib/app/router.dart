
import 'package:go_router/go_router.dart';
import 'package:myapp/presentation/pages/home_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
  ],
);


import 'package:flutter/material.dart';
import 'package:myapp/app/router.dart';
import 'package:myapp/app/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My App',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

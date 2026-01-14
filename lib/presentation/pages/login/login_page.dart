import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/widgets/auth/login/login_footer.dart';
import 'package:posventa/presentation/widgets/auth/login/login_form.dart';
import 'package:posventa/presentation/widgets/auth/login/login_header.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.status == AuthStatus.error && state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            content: Text(state.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LoginHeader(),
                  SizedBox(height: 40),
                  LoginForm(),
                  SizedBox(height: 24),
                  LoginFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton:
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
          ? FloatingActionButton.extended(
              onPressed: () {
                exit(0);
              },
              label: const Text('Salir'),
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Cerrar aplicación',
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
    );
  }
}

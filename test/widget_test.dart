import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/main.dart';
import 'package:posventa/presentation/pages/login_page.dart';

void main() {
  testWidgets('Renders LoginPage and authenticates', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // The app starts with a splash screen, so we need to wait for the
    // navigation to the login screen to complete.
    await tester.pumpAndSettle();

    // Verify that the LoginPage is present.
    expect(find.byType(LoginPage), findsOneWidget);

    // Verify that the login form fields are present
    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
  });
}

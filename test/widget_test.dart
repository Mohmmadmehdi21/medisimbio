import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/screens/splash_screen.dart';

void main() {
  testWidgets('Medisimbio app splash screen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
    expect(find.text('Connecting\nHealthcare\nAround You'), findsOneWidget);
  });
}

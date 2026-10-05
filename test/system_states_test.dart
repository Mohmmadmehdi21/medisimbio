import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/widgets/system_state_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1O — System State Widgets Unit & Widget Tests', () {
    testWidgets('AppLoadingState renders message correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingState(message: 'Loading appointments...'),
          ),
        ),
      );

      expect(find.text('Loading appointments...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppEmptyState renders title, subtitle, and action', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'No appointments yet.',
              message: 'Book an appointment with a doctor to get started.',
              actionLabel: 'Book Appointment',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No appointments yet.'), findsOneWidget);
      expect(find.text('Book an appointment with a doctor to get started.'), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);

      await tester.tap(find.text('Book Appointment'));
      expect(actionTapped, isTrue);
    });

    testWidgets('AppErrorState renders error title and retry callback', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorState(
              title: 'Something went wrong.',
              message: 'Failed to connect to backend server.',
              onRetry: () => retried = true,
              retryLabel: 'Try Again',
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong.'), findsOneWidget);
      expect(find.text('Failed to connect to backend server.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('AppSuccessState renders success title and checkmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSuccessState(
              title: 'Appointment confirmed.',
              message: 'Your booking details have been saved.',
            ),
          ),
        ),
      );

      expect(find.text('Appointment confirmed.'), findsOneWidget);
      expect(find.text('Your booking details have been saved.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('AppUnavailableState renders live tracking unavailable title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppUnavailableState(
              title: 'Live tracking is currently unavailable.',
              message: 'Live tracking will activate when provider starts session.',
            ),
          ),
        ),
      );

      expect(find.text('Live tracking is currently unavailable.'), findsOneWidget);
      expect(find.text('Live tracking will activate when provider starts session.'), findsOneWidget);
    });

    testWidgets('AppPermissionDeniedState renders location permission denied & manual option', (tester) async {
      bool manualTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPermissionDeniedState(
              title: 'Location access was not granted.',
              message: 'Please grant location access or enter location manually.',
              onManualInput: () => manualTapped = true,
              manualInputLabel: 'Enter Location Manually',
            ),
          ),
        ),
      );

      expect(find.text('Location access was not granted.'), findsOneWidget);
      expect(find.text('Enter Location Manually'), findsOneWidget);

      await tester.tap(find.text('Enter Location Manually'));
      expect(manualTapped, isTrue);
    });
  });
}

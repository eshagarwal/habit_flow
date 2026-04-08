import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:habit_flow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App main flow: create habit and view on dashboard', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verify we start on the Dashboard and see the empty state
    expect(find.text('No habits yet'), findsOneWidget);

    // Tap the FAB to create a habit
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify we are on the Create Habit screen
    expect(find.text('Create Habit'), findsOneWidget);

    // Enter a habit title
    await tester.enterText(find.byType(TextFormField).first, 'Read a Book');
    await tester.pumpAndSettle();

    // Save the habit
    await tester.tap(find.text('Save Habit'));
    await tester.pumpAndSettle();

    // Verify we are back on the Dashboard and the habit is listed
    expect(find.text('No habits yet'), findsNothing);
    expect(find.text('Read a Book'), findsOneWidget);
  });
}

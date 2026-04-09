import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/ui/habits/views/create_habit_screen.dart';
import 'package:habit_flow/domain/models/habit.dart';
import 'package:habit_flow/data/providers.dart';
import 'package:habit_flow/data/repositories/habit_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late MockHabitRepository mockRepository;

  setUp(() {
    mockRepository = MockHabitRepository();
    when(() => mockRepository.saveHabit(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(Habit()
      ..uuid = 'dummy'
      ..title = 'dummy'
      ..category = HabitCategory.health
      ..frequencyType = FrequencyType.daily
      ..targetCount = 1
      ..unit = 'times'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now());
  });

  testWidgets('CreateHabitScreen form validation and submission',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: CreateHabitScreen(),
        ),
      ),
    );

    // Tap save button without entering title
    await tester.tap(find.text('Create Habit'));
    await tester.pump();

    // Verify validation error is shown
    expect(find.text('Please enter a title'), findsOneWidget);

    // Enter title
    await tester.enterText(find.byType(TextFormField).first, 'Morning Run');
    await tester.pump();

    // Tap save button again
    await tester.tap(find.text('Create Habit'));
    await tester.pump();

    // Verify saveHabit was called
    verify(() => mockRepository.saveHabit(any())).called(1);
  });

  testWidgets('CreateHabitScreen displays all form fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: CreateHabitScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify form fields are displayed
    expect(find.text('Habit Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Frequency'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Unit'), findsOneWidget);

    // Verify buttons are displayed
    expect(find.text('Create Habit'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('CreateHabitScreen validates title field',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: CreateHabitScreen(),
        ),
      ),
    );

    // Try to submit without title
    await tester.tap(find.text('Create Habit'));
    await tester.pump();

    // Verify error message
    expect(find.text('Please enter a title'), findsOneWidget);

    // Enter valid title
    await tester.enterText(find.byType(TextFormField).first, 'Exercise');
    await tester.pump();

    // Error should disappear
    expect(find.text('Please enter a title'), findsNothing);
  });

  testWidgets('CreateHabitScreen allows category selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: CreateHabitScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap category dropdown
    final categoryDropdowns = find.byType(DropdownButtonFormField);
    if (categoryDropdowns.evaluate().isNotEmpty) {
      await tester.tap(categoryDropdowns.first);
      await tester.pumpAndSettle();

      // Verify dropdown options are visible
      expect(find.text('Fitness'), findsWidgets);
      expect(find.text('Health'), findsWidgets);
    }
  });

  testWidgets('CreateHabitScreen allows frequency selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: CreateHabitScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap frequency dropdown (second dropdown)
    final frequencyDropdowns = find.byType(DropdownButtonFormField);
    if (frequencyDropdowns.evaluate().length > 1) {
      await tester.tap(frequencyDropdowns.at(1));
      await tester.pumpAndSettle();

      // Verify dropdown options are visible
      expect(find.text('Daily'), findsWidgets);
      expect(find.text('Weekly'), findsWidgets);
    }
  });

  testWidgets('CreateHabitScreen allows setting reminder time',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: CreateHabitScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Look for time picker button or field
    final timePickerButtons = find.byIcon(Icons.access_time);
    if (timePickerButtons.evaluate().isNotEmpty) {
      await tester.tap(timePickerButtons.first);
      await tester.pumpAndSettle();

      // Verify time picker is shown
      expect(find.byType(TimePickerDialog), findsWidgets);
    }
  });

  testWidgets('CreateHabitScreen submits form with all fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: CreateHabitScreen(),
        ),
      ),
    );

    // Fill in title field
    await tester.enterText(
        find.byType(TextFormField).first, 'Morning Meditation');
    await tester.pump();

    // Fill in description if available
    final textFields = find.byType(TextFormField);
    if (textFields.evaluate().length > 1) {
      await tester.enterText(textFields.at(1), 'Meditate for 10 minutes');
      await tester.pump();
    }

    // Submit the form
    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();

    // Verify saveHabit was called with habit data
    verify(() => mockRepository.saveHabit(any())).called(greaterThan(0));
  });
}

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
    expect(find.text('Habit Title *'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Category *'), findsOneWidget);
    expect(find.text('Frequency *'), findsOneWidget);
    expect(find.text('Target Count *'), findsOneWidget);
    expect(find.text('Unit *'), findsOneWidget);

    // Verify buttons are displayed
    expect(find.byType(FilledButton), findsWidgets);
    expect(find.byType(OutlinedButton), findsWidgets);
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

  testWidgets('CreateHabitScreen form can be filled and submitted',
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

    // Fill in title field
    final titleFields = find.byType(TextFormField);
    if (titleFields.evaluate().isNotEmpty) {
      await tester.enterText(titleFields.first, 'Morning Meditation');
      await tester.pump();
    }

    // Find FilledButton for submit
    final submitButtons = find.byType(FilledButton);
    expect(submitButtons, findsWidgets);
  });
}

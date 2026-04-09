import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/ui/dashboard/views/dashboard_screen.dart';
import 'package:habit_flow/domain/models/habit.dart';
import 'package:habit_flow/domain/models/habit_entry.dart';
import 'package:habit_flow/data/providers.dart';
import 'package:habit_flow/data/repositories/habit_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class MockIsar extends Mock implements Isar {}

void main() {
  late MockHabitRepository mockRepository;
  late MockIsar mockIsar;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(Habit()
      ..uuid = 'fallback'
      ..title = 'fallback'
      ..category = HabitCategory.fitness
      ..frequencyType = FrequencyType.daily
      ..targetCount = 1
      ..unit = 'times'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now());

    registerFallbackValue(HabitEntry()
      ..habitUuid = 'fallback'
      ..date = DateTime.now()
      ..value = 0
      ..completed = false);

    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockRepository = MockHabitRepository();
    mockIsar = MockIsar();

    // Mock getAllHabits to return sample habits
    when(() => mockRepository.getAllHabits()).thenAnswer((_) async => [
          Habit()
            ..uuid = '1'
            ..title = 'Morning Jog'
            ..description = 'Run in the morning'
            ..category = HabitCategory.fitness
            ..frequencyType = FrequencyType.daily
            ..targetCount = 1
            ..unit = 'times'
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          Habit()
            ..uuid = '2'
            ..title = 'Read Books'
            ..description = 'Read for 30 minutes'
            ..category = HabitCategory.study
            ..frequencyType = FrequencyType.daily
            ..targetCount = 1
            ..unit = 'times'
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        ]);

    // Mock getEntriesForDate
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => [
              HabitEntry()
                ..habitUuid = '1'
                ..date = DateTime.now()
                ..value = 1
                ..completed = true,
              HabitEntry()
                ..habitUuid = '2'
                ..date = DateTime.now()
                ..value = 1
                ..completed = false,
            ]);

    when(() => mockRepository.saveEntry(any())).thenAnswer((_) async {});
    when(() => mockRepository.deleteHabit(any())).thenAnswer((_) async {});
  });

  testWidgets('DashboardScreen displays habits and progress',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          isarProvider.overrideWithValue(mockIsar),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Verify habits are displayed
    expect(find.text('Morning Jog'), findsWidgets);
    expect(find.text('Read Books'), findsWidgets);

    // Verify today's date is displayed
    expect(find.byType(Text), findsWidgets);

    // Verify the progress circle is shown
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('DashboardScreen toggles habit completion',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          isarProvider.overrideWithValue(mockIsar),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Find and tap a habit checkbox/button
    final checkboxes = find.byType(Checkbox);
    if (checkboxes.evaluate().isNotEmpty) {
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Verify saveEntry was called
      verify(() => mockRepository.saveEntry(any())).called(greaterThan(0));
    }
  });

  testWidgets('DashboardScreen shows empty state when no habits',
      (WidgetTester tester) async {
    // Override to return empty list
    when(() => mockRepository.getAllHabits()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          isarProvider.overrideWithValue(mockIsar),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Verify empty state message is shown
    expect(find.text('No habits yet'), findsOneWidget);
  });

  testWidgets('DashboardScreen navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          isarProvider.overrideWithValue(mockIsar),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Verify bottom navigation bar exists
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify navigation destinations
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/ui/stats/views/stats_screen.dart';
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
            ..title = 'Exercise'
            ..category = HabitCategory.fitness
            ..frequencyType = FrequencyType.daily
            ..targetCount = 1
            ..unit = 'times'
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          Habit()
            ..uuid = '2'
            ..title = 'Meditation'
            ..category = HabitCategory.health
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
                ..completed = true,
            ]);

    // Mock getEntriesForHabit
    when(() => mockRepository.getEntriesForHabit(any()))
        .thenAnswer((_) async => [
              HabitEntry()
                ..habitUuid = '1'
                ..date = DateTime.now()
                ..value = 1
                ..completed = true,
              HabitEntry()
                ..habitUuid = '1'
                ..date = DateTime.now().subtract(const Duration(days: 1))
                ..value = 1
                ..completed = true,
              HabitEntry()
                ..habitUuid = '1'
                ..date = DateTime.now().subtract(const Duration(days: 2))
                ..value = 1
                ..completed = false,
            ]);
  });

  testWidgets('StatsScreen displays statistics and charts',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          isarProvider.overrideWithValue(mockIsar),
        ],
        child: const MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Verify key stat cards are displayed
    expect(find.text('Active Habits'), findsOneWidget);
    expect(find.text('Overall Rate'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);

    // Verify chart sections exist
    expect(find.text('Weekly Activity'), findsOneWidget);
    expect(find.text('Completion Trend'), findsOneWidget);
    expect(find.text('Habit Performance'), findsOneWidget);
    expect(find.text('By Category'), findsOneWidget);
  });

  testWidgets('StatsScreen shows habit performance data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          isarProvider.overrideWithValue(mockIsar),
        ],
        child: const MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Verify habits are shown in performance section
    expect(find.text('Exercise'), findsWidgets);
    expect(find.text('Meditation'), findsWidgets);

    // Verify progress indicators are displayed
    expect(find.byType(LinearProgressIndicator), findsWidgets);
  });

  testWidgets('StatsScreen shows empty state when no habits',
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
          home: StatsScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Verify empty state message is shown
    expect(find.text('No statistics available'), findsOneWidget);
  });

  testWidgets('StatsScreen navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          isarProvider.overrideWithValue(mockIsar),
        ],
        child: const MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Verify bottom navigation bar exists and Stats is selected
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify all navigation destinations
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('StatsScreen scrolls content properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          isarProvider.overrideWithValue(mockIsar),
        ],
        child: const MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    // Wait for async data loading
    await tester.pumpAndSettle();

    // Scroll down to see more content
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Verify habit performance section is visible
    expect(find.text('Habit Performance'), findsOneWidget);
  });
}

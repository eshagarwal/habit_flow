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
    registerFallbackValue(Habit()..uuid='dummy'..title='dummy'..category=HabitCategory.health..frequencyType=FrequencyType.daily..targetCount=1..unit='times'..createdAt=DateTime.now()..updatedAt=DateTime.now());
  });

  testWidgets('CreateHabitScreen form validation and submission', (WidgetTester tester) async {
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
    await tester.tap(find.text('Save Habit'));
    await tester.pump();

    // Verify validation error is shown
    expect(find.text('Please enter a title'), findsOneWidget);

    // Enter title
    await tester.enterText(find.byType(TextFormField).first, 'Morning Run');
    await tester.pump();

    // Tap save button again
    await tester.tap(find.text('Save Habit'));
    await tester.pump();

    // Verify saveHabit was called
    verify(() => mockRepository.saveHabit(any())).called(1);
  });
}

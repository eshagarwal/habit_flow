import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/domain/models/habit.dart';
import 'package:habit_flow/domain/models/habit_entry.dart';
import 'package:habit_flow/data/services/streak_service.dart';

void main() {
  group('StreakService', () {
    late StreakService streakService;
    late Habit testHabit;

    setUp(() {
      streakService = StreakService();
      testHabit = Habit()
        ..uuid = '123'
        ..title = 'Test Habit'
        ..createdAt = DateTime.now().subtract(const Duration(days: 10));
    });

    test('Returns empty stats when there are no entries', () {
      final stats = streakService.calculateStats(testHabit, []);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.completionRate, 0.0);
    });

    test('Calculates current streak correctly for consecutive days', () {
      final today = DateTime.now();
      final entries = [
        HabitEntry()..date = today..completed = true,
        HabitEntry()..date = today.subtract(const Duration(days: 1))..completed = true,
        HabitEntry()..date = today.subtract(const Duration(days: 2))..completed = true,
      ];

      final stats = streakService.calculateStats(testHabit, entries);
      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 3);
    });

    test('Breaks streak if a day is missed', () {
      final today = DateTime.now();
      final entries = [
        HabitEntry()..date = today..completed = true,
        HabitEntry()..date = today.subtract(const Duration(days: 2))..completed = true,
        HabitEntry()..date = today.subtract(const Duration(days: 3))..completed = true,
      ];

      final stats = streakService.calculateStats(testHabit, entries);
      expect(stats.currentStreak, 1);
      expect(stats.longestStreak, 2);
    });

    test('Current streak is zero if missed today and yesterday', () {
      final today = DateTime.now();
      final entries = [
        HabitEntry()..date = today.subtract(const Duration(days: 2))..completed = true,
        HabitEntry()..date = today.subtract(const Duration(days: 3))..completed = true,
      ];

      final stats = streakService.calculateStats(testHabit, entries);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 2);
    });
  });
}

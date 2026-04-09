import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/models/habit.dart';
import '../domain/models/habit_entry.dart';
import 'repositories/habit_repository.dart';
import 'repositories/habit_repository_impl.dart';
import 'datasources/local/habit_local_source.dart';
import 'services/streak_service.dart';
import 'services/reminder_service.dart';

// Theme provider
final themeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Provides the Isar instance
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden in ProviderScope');
});

// Provides the local data source
final habitLocalSourceProvider = Provider<HabitLocalSource>((ref) {
  return HabitLocalSource(ref.watch(isarProvider));
});

// Provides the habit repository
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(ref.watch(habitLocalSourceProvider));
});

// Provides the streak service
final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});

// Provides the reminder service
final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(FlutterLocalNotificationsPlugin());
});

// A provider to fetch habits
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getAllHabits();
});

// A provider to fetch entries for today
final todayEntriesProvider = FutureProvider<List<HabitEntry>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getEntriesForDate(DateTime.now());
});

// A provider to fetch entries for a specific date
final entriesByDateProvider =
    FutureProvider.family<List<HabitEntry>, DateTime>((ref, date) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getEntriesForDate(date);
});

// A provider to fetch entries for a specific habit
final entriesByHabitProvider =
    FutureProvider.family<List<HabitEntry>, String>((ref, habitUuid) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getEntriesForHabit(habitUuid);
});

// Stats data class
class HabitStats {
  final int activeHabits;
  final int completedToday;
  final int completedThisWeek;
  final double overallCompletionRate;
  final int currentStreak;
  final Map<String, int> categoryBreakdown;

  HabitStats({
    required this.activeHabits,
    required this.completedToday,
    required this.completedThisWeek,
    required this.overallCompletionRate,
    required this.currentStreak,
    required this.categoryBreakdown,
  });
}

// A provider to calculate overall statistics
final statsProvider = FutureProvider<HabitStats>((ref) async {
  final habitsAsync = await ref.watch(habitsProvider.future);
  final todayEntriesAsync = await ref.watch(todayEntriesProvider.future);

  if (habitsAsync.isEmpty) {
    return HabitStats(
      activeHabits: 0,
      completedToday: 0,
      completedThisWeek: 0,
      overallCompletionRate: 0,
      currentStreak: 0,
      categoryBreakdown: {},
    );
  }

  final repository = ref.watch(habitRepositoryProvider);
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));

  // Count completed today
  final completedToday =
      todayEntriesAsync.where((entry) => entry.completed).length;

  // Count completed this week
  int completedThisWeek = 0;
  for (final habit in habitsAsync) {
    final entries = await repository.getEntriesForHabit(habit.uuid);
    completedThisWeek += entries
        .where((entry) => entry.completed && entry.date.isAfter(weekAgo))
        .length;
  }

  // Calculate overall completion rate
  int totalPossible = 0;
  int totalCompleted = 0;
  for (final habit in habitsAsync) {
    final entries = await repository.getEntriesForHabit(habit.uuid);
    totalPossible += entries.length;
    totalCompleted += entries.where((entry) => entry.completed).length;
  }
  final overallRate =
      totalPossible > 0 ? (totalCompleted / totalPossible * 100) : 0.0;

  // Calculate category breakdown
  final categoryBreakdown = <String, int>{};
  for (final habit in habitsAsync) {
    final categoryName = habit.category.toString().split('.').last;
    categoryBreakdown[categoryName] =
        (categoryBreakdown[categoryName] ?? 0) + 1;
  }

  // Calculate current streak (simple implementation - days where all habits were completed)
  int streak = 0;
  for (int i = 0; i < 30; i++) {
    final checkDate = now.subtract(Duration(days: i));
    final dayEntries = await repository.getEntriesForDate(checkDate);
    if (dayEntries.isNotEmpty && dayEntries.every((e) => e.completed)) {
      streak++;
    } else {
      break;
    }
  }

  return HabitStats(
    activeHabits: habitsAsync.length,
    completedToday: completedToday,
    completedThisWeek: completedThisWeek,
    overallCompletionRate: overallRate,
    currentStreak: streak,
    categoryBreakdown: categoryBreakdown,
  );
});

// Weekly activity data for chart
class WeeklyActivityData {
  final List<int> dailyCompletions;

  WeeklyActivityData({required this.dailyCompletions});
}

// A provider to get weekly activity data
final weeklyActivityProvider = FutureProvider<WeeklyActivityData>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  final now = DateTime.now();
  final dailyCompletions = <int>[];

  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final entries = await repository.getEntriesForDate(date);
    final completed = entries.where((entry) => entry.completed).length;
    dailyCompletions.add(completed);
  }

  return WeeklyActivityData(dailyCompletions: dailyCompletions);
});

// Monthly completion data for chart (weeks 1-4)
class MonthlyTrendData {
  final List<double> weeklyCompletionRates;

  MonthlyTrendData({required this.weeklyCompletionRates});
}

// A provider to get monthly trend data
final monthlyTrendProvider = FutureProvider<MonthlyTrendData>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  final now = DateTime.now();
  final weeklyRates = <double>[];

  for (int week = 3; week >= 0; week--) {
    final weekStart = now.subtract(Duration(days: week * 7 + 6));

    int totalCompleted = 0;
    int totalPossible = 0;

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final entries = await repository.getEntriesForDate(date);
      totalPossible += entries.length;
      totalCompleted += entries.where((entry) => entry.completed).length;
    }

    final rate =
        totalPossible > 0 ? (totalCompleted / totalPossible * 100) : 0.0;
    weeklyRates.add(rate);
  }

  return MonthlyTrendData(weeklyCompletionRates: weeklyRates);
});

// Monthly entries data for history view
class MonthlyEntriesData {
  final Map<int, List<HabitEntry>> entriesByDay;
  final int completedCount;
  final int totalCount;

  MonthlyEntriesData({
    required this.entriesByDay,
    required this.completedCount,
    required this.totalCount,
  });
}

// A provider to get entries for a specific month
final monthEntriesProvider =
    FutureProvider.family<MonthlyEntriesData, DateTime>((ref, month) async {
  final repository = ref.watch(habitRepositoryProvider);

  final entriesByDay = <int, List<HabitEntry>>{};
  int totalCompleted = 0;
  int totalPossible = 0;

  // Get the first and last day of the month
  final firstDay = DateTime(month.year, month.month, 1);
  final lastDay = month.month == 12
      ? DateTime(month.year + 1, 1, 1).subtract(const Duration(days: 1))
      : DateTime(month.year, month.month + 1, 1)
          .subtract(const Duration(days: 1));

  // Collect all entries for the month
  for (DateTime d = firstDay;
      d.isBefore(lastDay.add(const Duration(days: 1)));
      d = d.add(const Duration(days: 1))) {
    final dayEntries = await repository.getEntriesForDate(d);
    entriesByDay[d.day] = dayEntries;
    totalPossible += dayEntries.length;
    totalCompleted += dayEntries.where((e) => e.completed).length;
  }

  return MonthlyEntriesData(
    entriesByDay: entriesByDay,
    completedCount: totalCompleted,
    totalCount: totalPossible,
  );
});

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import 'package:habit_flow/domain/models/habit.dart';
import 'package:habit_flow/domain/models/habit_entry.dart';

final _uuid = DateTime.now().millisecondsSinceEpoch;

Future<void> seedData() async {
  final isar = Isar.getInstance();

  if (isar == null) {
    debugPrint("No isar!");
    return;
  }

  final now = DateTime.now();

  final habits = [
    Habit()
      ..uuid = 'seed-habit-fitness-$_uuid'
      ..title = 'Morning Workout'
      ..description = '30 minutes of exercise every morning'
      ..category = HabitCategory.fitness
      ..frequencyType = FrequencyType.daily
      ..targetCount = 1
      ..unit = 'session'
      ..daysOfWeek = [1, 2, 3, 4, 5, 6, 7]
      ..reminderEnabled = false
      ..createdAt = now.subtract(const Duration(days: 30))
      ..updatedAt = now,
    Habit()
      ..uuid = 'seed-habit-water-$_uuid'
      ..title = 'Drink Water'
      ..description = 'Drink 8 glasses of water daily'
      ..category = HabitCategory.health
      ..frequencyType = FrequencyType.daily
      ..targetCount = 8
      ..unit = 'glasses'
      ..daysOfWeek = [1, 2, 3, 4, 5, 6, 7]
      ..reminderEnabled = false
      ..createdAt = now.subtract(const Duration(days: 25))
      ..updatedAt = now,
    Habit()
      ..uuid = 'seed-habit-read-$_uuid'
      ..title = 'Read 30 Minutes'
      ..description = 'Read for at least 30 minutes'
      ..category = HabitCategory.study
      ..frequencyType = FrequencyType.daily
      ..targetCount = 30
      ..unit = 'minutes'
      ..daysOfWeek = [1, 2, 3, 4, 5]
      ..reminderEnabled = false
      ..createdAt = now.subtract(const Duration(days: 20))
      ..updatedAt = now,
    Habit()
      ..uuid = 'seed-habit-meditate-$_uuid'
      ..title = 'Meditate'
      ..description = '10 minutes of mindfulness meditation'
      ..category = HabitCategory.health
      ..frequencyType = FrequencyType.daily
      ..targetCount = 10
      ..unit = 'minutes'
      ..daysOfWeek = [1, 2, 3, 4, 5, 6, 7]
      ..reminderEnabled = false
      ..createdAt = now.subtract(const Duration(days: 15))
      ..updatedAt = now,
    Habit()
      ..uuid = 'seed-habit-run-$_uuid'
      ..title = 'Evening Run'
      ..description = 'Go for a 5km run'
      ..category = HabitCategory.fitness
      ..frequencyType = FrequencyType.weekly
      ..targetCount = 3
      ..unit = 'runs'
      ..daysOfWeek = [1, 3, 5]
      ..reminderEnabled = false
      ..createdAt = now.subtract(const Duration(days: 10))
      ..updatedAt = now,
  ];

  await isar.writeTxn(() async {
    await isar.habits.putAll(habits);
  });

  final entries = <HabitEntry>[];
  final rng = DateTime.now().microsecondsSinceEpoch % 100;

  for (final habit in habits) {
    final createdDaysAgo = now.difference(habit.createdAt).inDays;
    for (int i = 0; i <= createdDaysAgo; i++) {
      final date = now.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);

      final isScheduledDay = habit.daysOfWeek.contains(normalizedDate.weekday);
      if (!isScheduledDay) continue;

      final hash = (habit.uuid.hashCode + i + rng) % 10;
      final completed = hash < 7;

      entries.add(HabitEntry()
        ..habitUuid = habit.uuid
        ..date = normalizedDate
        ..value = completed ? habit.targetCount : 0
        ..completed = completed
        ..completedAt =
            completed ? normalizedDate.add(const Duration(hours: 8)) : null);
    }
  }

  await isar.writeTxn(() async {
    await isar.habitEntrys.putAll(entries);
  });

  final habitCount = await isar.habits.count();
  final entryCount = await isar.habitEntrys.count();
  debugPrint('Seeded $habitCount habits and $entryCount entries.');

  await isar.close();
}

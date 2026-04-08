import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../domain/models/habit.dart';
import '../domain/models/habit_entry.dart';
import 'repositories/habit_repository.dart';
import 'repositories/habit_repository_impl.dart';
import 'datasources/local/habit_local_source.dart';
import 'services/streak_service.dart';

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

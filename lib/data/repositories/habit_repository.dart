import '../../domain/models/habit.dart';
import '../../domain/models/habit_entry.dart';

abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(String uuid);
  Future<void> saveHabit(Habit habit);
  Future<void> deleteHabit(String uuid);

  Future<List<HabitEntry>> getEntriesForDate(DateTime date);
  Future<List<HabitEntry>> getEntriesForHabit(String habitUuid);
  Future<void> saveEntry(HabitEntry entry);
  Future<void> deleteEntry(String entryId);
  Future<void> deleteEntriesForHabit(String habitUuid);
}

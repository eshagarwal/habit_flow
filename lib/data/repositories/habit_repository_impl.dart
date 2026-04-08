import '../../domain/models/habit.dart';
import '../../domain/models/habit_entry.dart';
import '../repositories/habit_repository.dart';
import '../datasources/local/habit_local_source.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalSource localSource;

  HabitRepositoryImpl(this.localSource);

  @override
  Future<List<Habit>> getAllHabits() => localSource.getAllHabits();

  @override
  Future<Habit?> getHabitById(String uuid) => localSource.getHabitByUuid(uuid);

  @override
  Future<void> saveHabit(Habit habit) => localSource.saveHabit(habit);

  @override
  Future<void> deleteHabit(String uuid) async {
    await localSource.deleteEntriesForHabit(uuid);
    await localSource.deleteHabit(uuid);
  }

  @override
  Future<List<HabitEntry>> getEntriesForDate(DateTime date) =>
      localSource.getEntriesForDate(date);

  @override
  Future<List<HabitEntry>> getEntriesForHabit(String habitUuid) =>
      localSource.getEntriesForHabit(habitUuid);

  @override
  Future<void> saveEntry(HabitEntry entry) => localSource.saveEntry(entry);

  @override
  Future<void> deleteEntry(String entryId) =>
      localSource.deleteEntry(int.parse(entryId));

  @override
  Future<void> deleteEntriesForHabit(String habitUuid) =>
      localSource.deleteEntriesForHabit(habitUuid);
}

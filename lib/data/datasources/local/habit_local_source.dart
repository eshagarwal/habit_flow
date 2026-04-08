import 'package:isar/isar.dart';
import '../../../domain/models/habit.dart';
import '../../../domain/models/habit_entry.dart';

class HabitLocalSource {
  final Isar isar;

  HabitLocalSource(this.isar);

  Future<List<Habit>> getAllHabits() async {
    return await isar.habits.where().findAll();
  }

  Future<Habit?> getHabitByUuid(String uuid) async {
    return await isar.habits.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> saveHabit(Habit habit) async {
    await isar.writeTxn(() async {
      await isar.habits.put(habit);
    });
  }

  Future<void> deleteHabit(String uuid) async {
    await isar.writeTxn(() async {
      await isar.habits.filter().uuidEqualTo(uuid).deleteAll();
    });
  }

  Future<List<HabitEntry>> getEntriesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.habitEntrys
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .findAll();
  }

  Future<List<HabitEntry>> getEntriesForHabit(String habitUuid) async {
    return await isar.habitEntrys.filter().habitUuidEqualTo(habitUuid).findAll();
  }

  Future<void> saveEntry(HabitEntry entry) async {
    await isar.writeTxn(() async {
      await isar.habitEntrys.put(entry);
    });
  }

  Future<void> deleteEntry(Id id) async {
    await isar.writeTxn(() async {
      await isar.habitEntrys.delete(id);
    });
  }

  Future<void> deleteEntriesForHabit(String habitUuid) async {
    await isar.writeTxn(() async {
      await isar.habitEntrys.filter().habitUuidEqualTo(habitUuid).deleteAll();
    });
  }
}

import 'package:isar/isar.dart';

part 'habit_entry.g.dart';

@collection
class HabitEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late String habitUuid;

  @Index()
  late DateTime date;

  late int value;
  late bool completed;
  DateTime? completedAt;
}

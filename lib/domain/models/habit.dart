import 'package:isar/isar.dart';

part 'habit.g.dart';

enum HabitCategory {
  fitness,
  health,
  study,
  custom
}

enum FrequencyType {
  daily,
  weekly
}

@collection
class Habit {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;
  String? description;

  @enumerated
  late HabitCategory category;

  @enumerated
  late FrequencyType frequencyType;

  late int targetCount;
  late String unit;

  List<int> daysOfWeek = []; // 1=Mon, 7=Sun

  bool reminderEnabled = false;
  DateTime? reminderTime;

  bool isArchived = false;
  late DateTime createdAt;
  late DateTime updatedAt;
}

class ReminderConfig {
  final String habitUuid;
  final bool enabled;
  final DateTime? time;
  final List<int> daysOfWeek;

  ReminderConfig({
    required this.habitUuid,
    required this.enabled,
    this.time,
    this.daysOfWeek = const [],
  });
}

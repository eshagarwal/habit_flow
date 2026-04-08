import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/reminder_config.dart';

class ReminderService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  ReminderService(this.flutterLocalNotificationsPlugin);

  Future<void> initialize() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleReminder(Habit habit, ReminderConfig config) async {
    if (!config.enabled || config.time == null) return;

    // A real implementation would use flutter_local_notifications' tz.TZDateTime
    // and zonedSchedule to support recurring daily/weekly notifications based on config.daysOfWeek
    // For MVP, we stub the plugin call.
    
    // Example:
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   habit.id,
    //   'Habit Reminder',
    //   'Time for ${habit.title}',
    //   _nextInstanceOfTime(config.time!),
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails('habit_channel', 'Habits',
    //         channelDescription: 'Habit reminders'),
    //   ),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    //   matchDateTimeComponents: DateTimeComponents.time,
    // );
  }

  Future<void> cancelReminder(int habitId) async {
    await flutterLocalNotificationsPlugin.cancel(habitId);
  }
}

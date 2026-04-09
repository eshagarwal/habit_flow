import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../domain/models/habit.dart';
import '../../domain/models/reminder_config.dart';

class ReminderService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  ReminderService(this.flutterLocalNotificationsPlugin);

  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleReminder(Habit habit, ReminderConfig config) async {
    if (!config.enabled || config.time == null) return;

    try {
      // Get the device timezone
      final String deviceTimeZone = tz.local.name;
      final location = tz.getLocation(deviceTimeZone);

      // Calculate the next occurrence of the reminder time
      final scheduledDateTime =
          _nextInstanceOfTime(config.time!, location, config.daysOfWeek);

      // Create notification details
      const androidNotificationDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Reminders for your daily habits',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        sound: 'notification_sound.aiff',
      );

      const notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        habit.uuid.hashCode, // Use habit ID as notification ID
        'Habit Reminder',
        'Time for ${habit.title}',
        scheduledDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // For recurring reminders, we need to use matchDateTimeComponents
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Log error silently in production
      // TODO: Add proper logging/analytics here
    }
  }

  Future<void> cancelReminder(String habitUuid) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(habitUuid.hashCode);
    } catch (e) {
      // Log error silently in production
      // TODO: Add proper logging/analytics here
    }
  }

  /// Calculate the next occurrence of the specified time
  /// If daysOfWeek is empty, it schedules for daily
  /// Otherwise, it schedules for the specified days of the week
  tz.TZDateTime _nextInstanceOfTime(
    DateTime time,
    tz.Location location,
    List<int> daysOfWeek,
  ) {
    final now = tz.TZDateTime.now(location);
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0,
      0,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // If specific days of the week are specified, find the next occurrence
    if (daysOfWeek.isNotEmpty) {
      // daysOfWeek contains 0 (Monday) through 6 (Sunday) or 1-7
      // Normalize to ISO 8601 standard (1 = Monday, 7 = Sunday)
      while (!daysOfWeek.contains(scheduledDate.weekday % 7)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    return scheduledDate;
  }
}

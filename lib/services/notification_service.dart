import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/reminder.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // iOS settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      iOS: darwinSettings,
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Could navigate to specific reminder here
    // For now, just opening the app is enough
  }

  /// Request notification permissions (iOS)
  static Future<bool> requestPermissions() async {
    final iOS = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true; // Android doesn't need explicit permission for basic notifications
  }

  /// Schedule a notification for a reminder
  static Future<void> scheduleReminder(Reminder reminder) async {
    // Don't schedule if already past or done
    if (reminder.isDone || reminder.dueAt.isBefore(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminder.dueAt, tz.local);

    await _notifications.zonedSchedule(
      reminder.id.hashCode, // Unique ID based on reminder ID
      'Reminder',
      reminder.title,
      scheduledDate,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'reminders',
          'Reminders',
          channelDescription: 'Reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a scheduled notification
  static Future<void> cancelReminder(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Schedule notifications for multiple reminders
  static Future<void> scheduleAll(List<Reminder> reminders) async {
    // Cancel all existing first
    await cancelAll();

    // Schedule all pending reminders
    for (final reminder in reminders) {
      if (!reminder.isDone && reminder.dueAt.isAfter(DateTime.now())) {
        await scheduleReminder(reminder);
      }
    }
  }
}

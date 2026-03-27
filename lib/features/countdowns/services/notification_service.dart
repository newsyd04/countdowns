import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../domain/entities/countdown.dart';

/// Handles local notification scheduling for countdowns.
///
/// Features:
/// - Timezone-safe scheduling
/// - Multiple notification offsets (day before, day of, etc.)
/// - Automatic rescheduling for recurring events
/// - Permission handling
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification plugin.
  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// Request notification permissions (call when user enables notifications).
  Future<bool> requestPermissions() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }

  /// Schedule notifications for a countdown based on its offsets.
  Future<void> scheduleForCountdown(Countdown countdown) async {
    if (!countdown.notificationsEnabled) return;

    // Cancel existing notifications for this countdown
    await cancelForCountdown(countdown.id);

    final targetDate = countdown.effectiveDate;

    for (int i = 0; i < countdown.notificationOffsets.length; i++) {
      final offsetMinutes = countdown.notificationOffsets[i];
      final scheduledDate =
          targetDate.subtract(Duration(minutes: offsetMinutes));

      // Skip if scheduled date is in the past
      if (scheduledDate.isBefore(DateTime.now())) continue;

      final notificationId = _generateId(countdown.id, i);
      final title = _notificationTitle(countdown, offsetMinutes);
      final body = _notificationBody(countdown, offsetMinutes);

      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'countdowns',
          ),
          android: AndroidNotificationDetails(
            'countdowns_channel',
            'Countdowns',
            channelDescription: 'Countdown event notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Cancel all notifications for a specific countdown.
  Future<void> cancelForCountdown(String countdownId) async {
    // Cancel up to 10 possible notification offsets per countdown
    for (int i = 0; i < 10; i++) {
      await _plugin.cancel(_generateId(countdownId, i));
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Generate a stable notification ID from countdown ID and offset index.
  int _generateId(String countdownId, int offsetIndex) {
    return countdownId.hashCode + offsetIndex;
  }

  String _notificationTitle(Countdown countdown, int offsetMinutes) {
    if (offsetMinutes == 0) {
      return '${countdown.emoji} ${countdown.title} is today!';
    }
    if (offsetMinutes == 1440) {
      return '${countdown.emoji} ${countdown.title} is tomorrow!';
    }
    final days = offsetMinutes ~/ 1440;
    return '${countdown.emoji} ${countdown.title} in $days days';
  }

  String _notificationBody(Countdown countdown, int offsetMinutes) {
    if (offsetMinutes == 0) {
      return 'The day has arrived!';
    }
    if (offsetMinutes == 1440) {
      return 'Just one more day to go!';
    }
    return 'Getting closer!';
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigate to the specific countdown when tapped
    // This would integrate with go_router for deep linking
  }
}

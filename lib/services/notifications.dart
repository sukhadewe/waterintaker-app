import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../app_state.dart';
import '../i18n.dart';

/// "Smart" reminders: we schedule one-shot notifications for the next few days.
/// Every time the app opens or a drink is logged we reschedule, so today's
/// remaining reminders disappear once the goal is reached.
class Reminders {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static const _daysAhead = 5;

  static Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    _ready = true;
  }

  static Future<bool> requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      final a = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final ok = await a?.requestNotificationsPermission();
      return ok ?? true;
    }
    if (Platform.isIOS) {
      final i = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final ok = await i?.requestPermissions(alert: true, badge: true, sound: true);
      return ok ?? false;
    }
    return false;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'hydration_reminders',
      'Hydration reminders',
      channelDescription: 'Reminders to drink water',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> reschedule() async {
    await init();
    await _plugin.cancelAll();
    final s = AppState.instance;
    if (!s.remindersOn) return;

    final now = DateTime.now();
    final rnd = Random();
    final generic = ['n1', 'n2', 'n3', 'n4', 'n5'];
    var id = 1;
    final step = s.remindIntervalMin.clamp(30, 600);
    final todayDone = s.goalReached(now);
    final leftMl = (s.goalMl - s.todayMl).clamp(0, 100000);

    for (var d = 0; d < _daysAhead; d++) {
      if (d == 0 && todayDone && s.smartSkip) continue;
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: d));
      for (var m = s.remindStartMin; m <= s.remindEndMin; m += step) {
        final when = day.add(Duration(minutes: m));
        if (!when.isAfter(now.add(const Duration(minutes: 1)))) continue;
        String body;
        if (d == 0 && leftMl > 0 && leftMl <= 600) {
          body = tr('n_left', {'n': s.fmt(leftMl)});
        } else {
          body = tr(generic[rnd.nextInt(generic.length)]);
        }
        await _plugin.zonedSchedule(
          id++,
          tr('notif_title'),
          body,
          tz.TZDateTime.from(when, tz.UTC),
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        if (id > 60) return;
      }
    }
  }
}

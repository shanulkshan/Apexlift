import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// System notification for "rest's over" while the app is in the background.
abstract interface class RestAlerts {
  /// Asks for notification permission (Android 13+, iOS) once.
  Future<void> ensurePermission();

  Future<void> schedule(DateTime at, {required String title, required String body});

  Future<void> cancel();
}

class LocalRestAlerts implements RestAlerts {
  LocalRestAlerts({required this.channelName, required this.channelDescription});

  final String channelName;
  final String channelDescription;

  static const _id = 7001;
  static const _channelId = 'rest_timer';

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _init;
  bool _askedPermission = false;

  Future<void> _ready() => _init ??= () async {
        tzdata.initializeTimeZones();
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('@drawable/ic_stat_ox'),
            // Permission is requested explicitly on the first rest instead.
            iOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestSoundPermission: false,
              requestBadgePermission: false,
            ),
          ),
        );
      }();

  /// Notification failures must never break a workout.
  Future<void> _safely(Future<void> Function() action) async {
    try {
      await _ready();
      await action();
    } catch (e) {
      debugPrint('Rest alert unavailable: $e');
    }
  }

  @override
  Future<void> ensurePermission() async {
    if (_askedPermission) return;
    _askedPermission = true;
    await _safely(() async {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true);
    });
  }

  @override
  Future<void> schedule(DateTime at, {required String title, required String body}) =>
      _safely(() async {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        // Exact alarms need user consent on Android 14+; fall back to an
        // inexact alarm (usually within seconds for short rests).
        final exact = await android?.canScheduleExactNotifications() ?? true;
        await _plugin.zonedSchedule(
          id: _id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
          androidScheduleMode: exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              channelName,
              channelDescription: channelDescription,
              importance: Importance.high,
              priority: Priority.high,
              category: AndroidNotificationCategory.alarm,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
        );
      });

  @override
  Future<void> cancel() => _safely(() => _plugin.cancel(id: _id));
}

/// Does nothing (tests, unsupported platforms).
class NoopRestAlerts implements RestAlerts {
  const NoopRestAlerts();

  @override
  Future<void> ensurePermission() async {}

  @override
  Future<void> schedule(DateTime at, {required String title, required String body}) async {}

  @override
  Future<void> cancel() async {}
}

final restAlertsProvider = Provider<RestAlerts>((ref) {
  if (kIsWeb) return const NoopRestAlerts();
  return LocalRestAlerts(
    channelName: 'Rest timer',
    channelDescription: 'Alerts when your rest between sets ends',
  );
});

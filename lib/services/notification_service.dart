import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../domain/models/prayer_name.dart';
import '../domain/models/prayer_times.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  static const _channelId = 'prayer_reminders';
  static const _channelName = 'تذكيرات الصلاة';
  static const _channelDesc = 'تذكيرات بأوقات قضاء الصلوات';

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    _plugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin!.initialize(settings: settings);

    final androidPlugin = _plugin!.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ),
      );
    }
    _initialized = true;
  }

  Future<void> schedulePrayerReminders(PrayerTimes times) async {
    await init();
    await cancelAll();

    final now = DateTime.now();
    final location = tz.local;

    for (final p in allPrayers) {
      final time = times.forPrayer(p);
      final parts = time.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      var scheduled = tz.TZDateTime(
        location, now.year, now.month, now.day, hour, minute,
      );

      if (scheduled.isBefore(tz.TZDateTime.from(now, location))) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final id = p.index + 100;
      await _plugin!.zonedSchedule(
        id: id,
        title: 'تذكير بصلاة ${p.arName}',
        body: 'حان وقت قضاء صلاة ${p.arName}',
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelAll() async {
    await _plugin!.cancelAll();
  }

  void setPlugin(FlutterLocalNotificationsPlugin plugin) {
    _plugin = plugin;
  }
}

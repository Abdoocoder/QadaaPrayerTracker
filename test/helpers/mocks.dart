import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qadaa_prayer_tracker/data/models/prayer_times_model.dart';
import 'package:qadaa_prayer_tracker/data/repositories/prayer_log_repository.dart';
import 'package:qadaa_prayer_tracker/data/repositories/prayer_time_repository.dart';
import 'package:qadaa_prayer_tracker/domain/models/day_log.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_times.dart';
import 'package:qadaa_prayer_tracker/data/services/database_service.dart';
import 'package:qadaa_prayer_tracker/data/services/notification_service.dart';
import 'package:qadaa_prayer_tracker/data/services/prayer_time_service.dart';
import 'package:qadaa_prayer_tracker/data/services/qadaa_service.dart';
import 'package:qadaa_prayer_tracker/data/services/supabase_service.dart';
import 'package:qadaa_prayer_tracker/data/services/supabase_sync_service.dart';
import 'package:qadaa_prayer_tracker/di/locale_notifier.dart';
import 'package:qadaa_prayer_tracker/di/theme_notifier.dart';

final testDayLog = DayLog(
  date: DateTime(2026, 5, 29),
  prayers: {for (final p in allPrayers) p: false},
);

final testDayLogOneDone = DayLog(
  date: DateTime(2026, 5, 29),
  prayers: {for (final p in allPrayers) p: p == PrayerName.fajr},
);

final testAggregates = <String, int>{
  'today_done': 0, 'today_total': 5,
  'week_done': 12, 'week_total': 35,
  'month_done': 45, 'month_total': 150,
  'all_done': 200, 'all_total': 1000,
};

final testDistribution = <String, int>{
  'fajr': 50, 'dhuhr': 45, 'asr': 40, 'maghrib': 35, 'isha': 30,
};

final testTimes = PrayerTimes(
  fajr: '04:30', sunrise: '05:45', dhuhr: '12:30',
  asr: '16:00', maghrib: '19:30', isha: '21:00',
);

class MockLogRepo implements PrayerLogRepository {
  bool failOnGetDayLog = false;
  bool failOnToggle = false;
  void Function(DateTime, PrayerName)? onToggle;

  @override
  Future<void> ensureTodayLogs() async {}

  @override
  Future<DayLog> getDayLog(DateTime date) async {
    if (failOnGetDayLog) throw Exception('mock failure');
    return testDayLog;
  }

  @override
  Future<Map<String, int>> getAggregates() async {
    if (failOnGetDayLog) throw Exception('mock failure');
    return Map.from(testAggregates);
  }

  @override
  Future<Map<String, int>> getPrayerDistribution() async {
    if (failOnGetDayLog) throw Exception('mock failure');
    return Map.from(testDistribution);
  }

  @override
  Future<List<DayLog>> getWeekLogs() async {
    if (failOnGetDayLog) throw Exception('mock failure');
    return List.generate(7, (_) => testDayLog);
  }

  @override
  Future<void> togglePrayer(DateTime date, PrayerName prayer) async {
    if (failOnToggle) throw Exception('mock toggle failure');
    onToggle?.call(date, prayer);
  }

  @override
  Future<void> clearAll() async {}
}

class MockTimeRepo implements PrayerTimeRepository {
  @override
  Future<PrayerTimes> getTimes(DateTime date) async => testTimes;

  @override
  Future<PrayerTimes> getTodayTimes() async => testTimes;
}

class MockDatabaseService extends DatabaseService {
  final Map<String, String> _settings = {};
  bool failOnSetSetting = false;

  @override
  Future<void> setSetting(String key, String value) async {
    if (failOnSetSetting) throw Exception('mock db failure');
    _settings[key] = value;
  }

  @override
  Future<String?> getSetting(String key) async => _settings[key];
}

class MockNotificationService extends NotificationService {
  bool didCancelAll = false;
  PrayerTimes? scheduledTimes;
  bool shouldThrowOnSchedule = false;

  @override
  Future<void> init() async {}

  @override
  Future<void> schedulePrayerReminders(PrayerTimes times) async {
    if (shouldThrowOnSchedule) throw Exception('mock notification failure');
    scheduledTimes = times;
  }

  @override
  Future<void> cancelAll() async {
    didCancelAll = true;
  }
}

class MockSupabaseService implements SupabaseService {
  bool _signedIn = true;
  bool failOnUpsertPrayerLog = false;
  bool failOnGetPrayerLogs = false;
  bool failOnUpsertSetting = false;

  final _authListeners = <VoidCallback>[];

  @override
  void addAuthListener(VoidCallback cb) => _authListeners.add(cb);

  @override
  void removeAuthListener(VoidCallback cb) => _authListeners.remove(cb);

  final upsertedLogs = <Map<String, dynamic>>[];
  final upsertedSettings = <String, String>{};
  List<Map<String, dynamic>> cloudLogs = [];

  @override
  bool get isSignedIn => _signedIn;
  void setSignedIn(bool v) => _signedIn = v;

  @override
  String? get userId => _signedIn ? 'test-user-id' : null;

  @override
  String? get userEmail => _signedIn ? 'test@example.com' : null;

  @override
  GoTrueClient get auth => throw UnimplementedError('auth not mocked');

  @override
  SupabaseClient get client => throw UnimplementedError('client not mocked');

  @override
  Future<void> init() async {}

  @override
  Future<AuthResponse> signUp(String email, String password) async =>
      throw UnimplementedError('signUp not mocked');

  @override
  Future<AuthResponse> signIn(String email, String password) async =>
      throw UnimplementedError('signIn not mocked');

  @override
  Future<AuthResponse> signInAnonymously() async =>
      throw UnimplementedError('signInAnonymously not mocked');

  @override
  Future<void> signOut() async {}

  @override
  Future<Map<String, dynamic>?> fetchPrayerTimes({
    required String date, String? lat, String? lng, String? method,
  }) async => null;

  @override
  Future<void> upsertPrayerLog({
    required String date,
    required String prayerName,
    required bool completed,
  }) async {
    if (failOnUpsertPrayerLog) throw Exception('mock upsert failure');
    upsertedLogs.add({'date': date, 'prayer_name': prayerName, 'completed': completed});
  }

  @override
  Future<List<Map<String, dynamic>>> getPrayerLogs({
    DateTime? from, DateTime? to, int? limit,
  }) async {
    if (failOnGetPrayerLogs) throw Exception('mock fetch failure');
    return cloudLogs;
  }

  @override
  Future<void> upsertSetting(String key, String value) async {
    if (failOnUpsertSetting) throw Exception('mock setting failure');
    upsertedSettings[key] = value;
  }

  @override
  Future<String?> getSetting(String key) async => null;

  final upsertedQadaaProgress = <Map<String, dynamic>>[];
  final qadaaProgressData = <String, Map<String, dynamic>>{};
  final qadaaLogsData = <Map<String, dynamic>>[];

  @override
  Future<void> upsertQadaaProgress({
    required String prayerName,
    required int totalMissed,
    required int completed,
  }) async {
    upsertedQadaaProgress.add({
      'prayer_name': prayerName,
      'total_missed': totalMissed,
      'completed': completed,
    });
    qadaaProgressData[prayerName] = {
      'prayer_name': prayerName,
      'total_missed': totalMissed,
      'completed': completed,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>?> getQadaaProgress(String prayerName) async {
    return qadaaProgressData[prayerName];
  }

  @override
  Future<void> upsertQadaaLog({
    required String prayerName,
    required int count,
    required String createdAt,
  }) async {
    qadaaLogsData.add({
      'prayer_name': prayerName,
      'count': count,
      'created_at': createdAt,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getQadaaLogs({int? limit}) async {
    var logs = List<Map<String, dynamic>>.from(qadaaLogsData);
    logs.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    if (limit != null && logs.length > limit) logs = logs.sublist(0, limit);
    return logs;
  }
}

class MockPrayerTimeService extends PrayerTimeService {
  MockPrayerTimeService() : super() {
    city = 'Amman';
    country = 'Jordan';
    method = 3;
  }

  @override
  Future<PrayerTimesModel> fetchTimes(DateTime date) async {
    return PrayerTimesModel(
      date: '2026-05-29', fajr: '04:30', sunrise: '05:45',
      dhuhr: '12:30', asr: '16:00', maghrib: '19:30',
      isha: '21:00', timezone: 'Asia/Amman',
    );
  }
}

class MockLocaleNotifier extends ChangeNotifier implements LocaleNotifier {
  Locale _locale = const Locale('ar');
  @override
  Locale get locale => _locale;
  @override
  void setLocale(Locale l) { _locale = l; notifyListeners(); }
}

class MockThemeNotifier extends ChangeNotifier implements ThemeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  @override
  ThemeMode get themeMode => _themeMode;
  @override
  void setThemeMode(ThemeMode mode) { _themeMode = mode; notifyListeners(); }
}

class MockQadaaService extends QadaaService {
  MockQadaaService() : super(db: MockDatabaseService());

  int _years = 0;

  @override
  int getYears() => _years;

  @override
  Future<void> resetFromYears(int years) async {
    _years = years;
  }
}

class MockSupabaseSyncService extends SupabaseSyncService {
  MockSupabaseSyncService()
      : super(supabase: MockSupabaseService(), db: MockDatabaseService());

  bool didSyncAll = false;

  @override
  Future<SyncResult> syncAll() async {
    didSyncAll = true;
    return SyncResult(0, 0, null);
  }
}

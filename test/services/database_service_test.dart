import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qadaa_prayer_tracker/data/services/database_service.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';
import 'package:qadaa_prayer_tracker/data/models/prayer_log_model.dart';

void main() {
  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseService db;

  setUp(() async {
    final dbPath = await getDatabasesPath();
    await databaseFactory.deleteDatabase('$dbPath/qadaa.db');
    db = DatabaseService();
  });

  group('DatabaseService', () {
    test('init creates all tables', () async {
      final database = await db.database;
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final names = tables.map((r) => r['name'] as String).toList();
      expect(names, contains('prayer_logs'));
      expect(names, contains('prayer_times'));
      expect(names, contains('settings'));
      expect(names, contains('qadaa_progress'));
      expect(names, contains('qadaa_logs'));
    });

    test('ensureTodayLogs inserts 5 prayer logs for today', () async {
      await db.ensureTodayLogs();
      final database = await db.database;
      final today = PrayerLogModel.dateToStr(DateTime.now());
      final rows = await database.query(
        'prayer_logs',
        where: 'date = ?',
        whereArgs: [today],
      );
      expect(rows.length, 5);
      for (final row in rows) {
        expect(row['completed'], 0);
      }
    });

    test('ensureTodayLogs is idempotent', () async {
      await db.ensureTodayLogs();
      await db.ensureTodayLogs();
      final database = await db.database;
      final today = PrayerLogModel.dateToStr(DateTime.now());
      final rows = await database.query(
        'prayer_logs',
        where: 'date = ?',
        whereArgs: [today],
      );
      expect(rows.length, 5);
    });

    test('togglePrayer sets completed to 1', () async {
      await db.ensureTodayLogs();
      await db.togglePrayer(DateTime.now(), PrayerName.fajr);
      final log = await db.getDayLog(DateTime.now());
      expect(log.prayers[PrayerName.fajr], isTrue);
    });

    test('togglePrayer toggles back to 0', () async {
      await db.ensureTodayLogs();
      await db.togglePrayer(DateTime.now(), PrayerName.fajr);
      await db.togglePrayer(DateTime.now(), PrayerName.fajr);
      final log = await db.getDayLog(DateTime.now());
      expect(log.prayers[PrayerName.fajr], isFalse);
    });

    test('togglePrayer inserts row if none exists', () async {
      await db.togglePrayer(DateTime.now(), PrayerName.maghrib);
      final log = await db.getDayLog(DateTime.now());
      expect(log.prayers[PrayerName.maghrib], isTrue);
      for (final p in allPrayers) {
        if (p != PrayerName.maghrib) {
          expect(log.prayers[p], isFalse);
        }
      }
    });

    test('getDayLog returns all 5 prayers defaulting to false', () async {
      final log = await db.getDayLog(DateTime(2026, 1, 1));
      expect(log.date, DateTime(2026, 1, 1));
      for (final p in allPrayers) {
        expect(log.prayers[p], isFalse);
      }
    });

    test('getWeekLogs returns 7 days', () async {
      final logs = await db.getWeekLogs(end: DateTime(2026, 5, 29));
      expect(logs.length, 7);
      expect(logs.first.date, DateTime(2026, 5, 23));
      expect(logs.last.date, DateTime(2026, 5, 29));
    });

    test('getAggregates returns zero counts when no data', () async {
      final agg = await db.getAggregates();
      expect(agg['today_total'], 0);
      expect(agg['today_done'], 0);
      expect(agg['week_total'], 0);
      expect(agg['all_total'], 0);
    });

    test('getAggregates returns correct counts', () async {
      await db.ensureTodayLogs();
      await db.togglePrayer(DateTime.now(), PrayerName.fajr);
      await db.togglePrayer(DateTime.now(), PrayerName.dhuhr);

      final agg = await db.getAggregates();
      expect(agg['today_total'], 5);
      expect(agg['today_done'], 2);
    });

    test('getPrayerDistribution returns zero for all prayers when no data', () async {
      final dist = await db.getPrayerDistribution();
      for (final p in allPrayers) {
        expect(dist[p.name], 0);
      }
    });

    test('getPrayerDistribution returns correct counts', () async {
      await db.ensureTodayLogs();
      await db.togglePrayer(DateTime.now(), PrayerName.fajr);
      await db.togglePrayer(DateTime.now(), PrayerName.dhuhr);

      final dist = await db.getPrayerDistribution();
      expect(dist['fajr'], 1);
      expect(dist['dhuhr'], 1);
      expect(dist['asr'], 0);
    });

    test('setSetting and getSetting persist values', () async {
      await db.setSetting('test_key', 'test_value');
      final value = await db.getSetting('test_key');
      expect(value, 'test_value');
    });

    test('setSetting overwrites existing key', () async {
      await db.setSetting('test_key', 'first');
      await db.setSetting('test_key', 'second');
      final value = await db.getSetting('test_key');
      expect(value, 'second');
    });

    test('getSetting returns null for missing key', () async {
      final value = await db.getSetting('nonexistent');
      expect(value, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qadaa_prayer_tracker/services/database_service.dart';
import 'package:qadaa_prayer_tracker/services/qadaa_service.dart';

void main() {
  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  const testDbName = 'qadaa_service_test.db';

  late DatabaseService db;
  late QadaaService service;

  setUp(() async {
    final dbPath = await getDatabasesPath();
    await databaseFactory.deleteDatabase('$dbPath/$testDbName');
    db = DatabaseService(dbName: testDbName);
    service = QadaaService(db: db);
    await service.initFromDb();
  });

  group('initYears / getYears', () {
    test('defaults to 0 years when nothing is set', () {
      expect(service.getYears(), 0);
    });

    test('setYears persists the value', () async {
      await service.setYears(3);
      expect(service.getYears(), 3);
      final saved = await db.getSetting('qadaa_years');
      expect(saved, '3');
    });

    test('initYears does nothing if years already set', () async {
      await service.setYears(5);
      await service.initYears(3);
      expect(service.getYears(), 5);
    });

    test('initYears sets years if none set', () async {
      await service.initYears(2);
      expect(service.getYears(), 2);
    });
  });

  group('QadaaService', () {
    setUp(() async {
      await service.initYears(1);
    });

    group('getProgress / getAllProgress', () {
      test('getProgress returns 0 completed initially', () {
        final p = service.getProgress('fajr');
        expect(p.totalMissed, 365);
        expect(p.completed, 0);
        expect(p.remaining, 365);
      });

      test('getAllProgress returns 5 entries', () {
        final all = service.getAllProgress();
        expect(all.length, 5);
        for (final p in all) {
          expect(p.totalMissed, 365);
          expect(p.completed, 0);
        }
      });
    });

    group('addLog', () {
      test('deducts completed count from the right prayer', () {
        service.addLog('fajr', 10);
        final p = service.getProgress('fajr');
        expect(p.completed, 10);
        expect(p.remaining, 355);
      });

      test('does not affect other prayers', () {
        service.addLog('fajr', 10);
        final p = service.getProgress('dhuhr');
        expect(p.completed, 0);
      });

      test('caps at totalMissed', () {
        service.addLog('fajr', 9999);
        final p = service.getProgress('fajr');
        expect(p.completed, 365);
        expect(p.remaining, 0);
      });
    });

    group('getLogs', () {
      test('returns logs newest first', () {
        service.addLog('fajr', 5);
        service.addLog('fajr', 3);
        final logs = service.getLogs();
        expect(logs.length, 2);
        expect(logs[0].prayerName, 'fajr');
        expect(logs[0].count, 3);
        expect(logs[1].count, 5);
      });
    });

    group('getGrandTotal', () {
      test('sums all completed', () {
        service.addLog('fajr', 10);
        service.addLog('maghrib', 20);
        expect(service.getGrandTotal(), 30);
      });
    });

    group('resetFromYears', () {
      test('resets all progress when years change', () async {
        service.addLog('fajr', 50);
        service.addLog('isha', 30);
        await service.resetFromYears(2);
        expect(service.getGrandTotal(), 0);
        final all = service.getAllProgress();
        for (final p in all) {
          expect(p.totalMissed, 730);
          expect(p.completed, 0);
        }
      });
    });

    group('isLogAllowed', () {
      test('returns true when prayer has remaining', () {
        expect(service.isLogAllowed('fajr'), true);
      });

      test('returns false when prayer is complete', () {
        service.addLog('fajr', 365);
        expect(service.isLogAllowed('fajr'), false);
      });

      test('returns true for incomplete even after some progress', () {
        service.addLog('fajr', 200);
        expect(service.isLogAllowed('fajr'), true);
      });
    });

    group('initFromDb', () {
      test('restores years from database', () async {
        final db2 = DatabaseService(dbName: testDbName);
        await db2.setSetting('qadaa_years', '3');
        final service2 = QadaaService(db: db2);
        await service2.initFromDb();
        expect(service2.getYears(), 3);
      });
    });
  });
}

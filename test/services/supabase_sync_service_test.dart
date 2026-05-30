import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qadaa_prayer_tracker/services/database_service.dart';
import 'package:qadaa_prayer_tracker/services/supabase_service.dart';
import 'package:qadaa_prayer_tracker/services/supabase_sync_service.dart';
import '../helpers/mocks.dart';

void main() {
  const testDbName = 'qadaa_sync_test.db';

  setUpAll(() async {
    databaseFactory = databaseFactoryFfi;
    final dbPath = await getDatabasesPath();
    await databaseFactory.deleteDatabase('$dbPath/$testDbName');
  });

  late DatabaseService db;
  late MockSupabaseService supabase;
  late SupabaseSyncService syncService;

  setUp(() async {
    db = DatabaseService(dbName: testDbName);
    supabase = MockSupabaseService();
    syncService = SupabaseSyncService(supabase: supabase, db: db);

    final database = await db.database;
    for (final t in ['prayer_logs', 'prayer_times', 'settings']) {
      await database.execute('DROP TABLE IF EXISTS "$t"');
    }
    await database.execute('''
      CREATE TABLE prayer_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        prayer_name TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        UNIQUE(date, prayer_name)
      )
    ''');
    await database.execute('''
      CREATE TABLE prayer_times (
        date TEXT PRIMARY KEY,
        fajr TEXT NOT NULL,
        sunrise TEXT NOT NULL,
        dhuhr TEXT NOT NULL,
        asr TEXT NOT NULL,
        maghrib TEXT NOT NULL,
        isha TEXT NOT NULL,
        timezone TEXT NOT NULL DEFAULT 'Asia/Amman'
      )
    ''');
    await database.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  });

  group('SupabaseSyncService', () {
    test('syncAll returns error when not signed in', () async {
      supabase.setSignedIn(false);
      final result = await syncService.syncAll();
      expect(result.isSuccess, isFalse);
      expect(result.error, 'Not signed in');
    });

    test('syncAll returns error when sync already in progress', () async {
      syncService.syncAll();
      final result = await syncService.syncAll();
      expect(result.isSuccess, isFalse);
      expect(result.error, 'Sync already in progress');
    });

    test('syncAll uploads local completed prayers', () async {
      await db.ensureTodayLogs();
      final database = await db.database;
      await database.update(
        'prayer_logs',
        {'completed': 1},
        where: 'prayer_name = ?',
        whereArgs: ['fajr'],
      );

      supabase.cloudLogs = [];
      final result = await syncService.syncAll();

      expect(result.isSuccess, isTrue);
      expect(result.uploaded, greaterThan(0));
      expect(supabase.upsertedLogs.any((l) => l['prayer_name'] == 'fajr'), isTrue);
    });

    test('syncAll downloads today cloud logs not present locally', () async {
      final today = SupabaseService.formatDate(DateTime.now());
      supabase.cloudLogs = [
        {'date': today, 'prayer_name': 'fajr', 'completed': true},
        {'date': today, 'prayer_name': 'isha', 'completed': false},
      ];

      final result = await syncService.syncAll();

      expect(result.isSuccess, isTrue);
      expect(result.downloaded, greaterThan(0));
    });

    test('syncAll uploads local settings', () async {
      await db.setSetting('test_key', 'test_value');
      supabase.cloudLogs = [];

      final result = await syncService.syncAll();

      expect(result.isSuccess, isTrue);
      expect(supabase.upsertedSettings, containsPair('test_key', 'test_value'));
    });

    test('syncAll handles individual upload failures gracefully', () async {
      await db.ensureTodayLogs();
      supabase.failOnUpsertPrayerLog = true;

      final result = await syncService.syncAll();

      expect(result.isSuccess, isTrue);
      expect(supabase.upsertedLogs, isEmpty);
    });

    test('syncAll returns error when fetch fails', () async {
      supabase.failOnGetPrayerLogs = true;

      final result = await syncService.syncAll();

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('progress stream emits starting event', () async {
      supabase.cloudLogs = [];
      final events = <SyncProgress>[];
      syncService.progress.listen(events.add);

      final result = syncService.syncAll();
      await result;

      expect(events.isNotEmpty, isTrue);
      expect(events.first.status, 'starting');
    });

    test('progress stream emits complete on success', () async {
      supabase.cloudLogs = [];
      final events = <SyncProgress>[];
      syncService.progress.listen(events.add);

      await syncService.syncAll();
      await Future(() {});

      expect(events.any((e) => e.status == 'complete'), isTrue);
    });

    test('progress stream emits error on fetch failure', () async {
      supabase.failOnGetPrayerLogs = true;
      final events = <SyncProgress>[];
      syncService.progress.listen(events.add);

      await syncService.syncAll();
      await Future(() {});

      expect(events.any((e) => e.status == 'error'), isTrue);
    });

    test('isSyncing is true during sync and false after', () async {
      supabase.cloudLogs = [];
      expect(syncService.isSyncing, isFalse);

      final future = syncService.syncAll();
      expect(syncService.isSyncing, isTrue);

      await future;
      expect(syncService.isSyncing, isFalse);
    });
  });
}

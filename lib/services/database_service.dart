import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../data/models/prayer_log_model.dart';
import '../domain/models/prayer_name.dart';
import '../domain/models/day_log.dart';

class DatabaseService {
  final String dbName;
  Database? _db;

  DatabaseService({this.dbName = 'qadaa.db'});

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);
    return openDatabase(
      path,
      version: 4,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE prayer_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            prayer_name TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            UNIQUE(date, prayer_name)
          )
        ''');
        await db.execute('''
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
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE qadaa_progress (
            prayer_name TEXT PRIMARY KEY,
            total_missed INTEGER NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE qadaa_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prayer_name TEXT NOT NULL,
            count INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, old, _) async {
        if (old < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS prayer_times (
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
        }
        if (old < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        }
        if (old < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS qadaa_progress (
              prayer_name TEXT PRIMARY KEY,
              total_missed INTEGER NOT NULL,
              completed INTEGER NOT NULL DEFAULT 0,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS qadaa_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              prayer_name TEXT NOT NULL,
              count INTEGER NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<void> ensureTodayLogs() async {
    final db = await database;
    final today = PrayerLogModel.dateToStr(DateTime.now());
    for (final p in allPrayers) {
      await db.insert(
        'prayer_logs',
        {
          'date': today,
          'prayer_name': p.name,
          'completed': 0,
          'created_at': today,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> togglePrayer(DateTime date, PrayerName name) async {
    final db = await database;
    final dateStr = PrayerLogModel.dateToStr(date);
    final existing = await db.query(
      'prayer_logs',
      where: 'date = ? AND prayer_name = ?',
      whereArgs: [dateStr, name.name],
    );
    if (existing.isEmpty) {
      await db.insert('prayer_logs', {
        'date': dateStr,
        'prayer_name': name.name,
        'completed': 1,
        'created_at': dateStr,
      });
    } else {
      final current = existing.first['completed'] as int;
      await db.update(
        'prayer_logs',
        {'completed': current == 0 ? 1 : 0},
        where: 'date = ? AND prayer_name = ?',
        whereArgs: [dateStr, name.name],
      );
    }
  }

  Future<DayLog> getDayLog(DateTime date) async {
    final db = await database;
    final dateStr = PrayerLogModel.dateToStr(date);
    final rows = await db.query(
      'prayer_logs',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    final map = <PrayerName, bool>{};
    for (final p in allPrayers) {
      map[p] = false;
    }
    for (final row in rows) {
      final name = PrayerName.values.byName(row['prayer_name'] as String);
      map[name] = (row['completed'] as int) == 1;
    }
    return DayLog(date: date, prayers: map);
  }

  Future<List<DayLog>> getWeekLogs({DateTime? end}) async {
    final endDate = end ?? DateTime.now();
    final start = endDate.subtract(const Duration(days: 6));
    final logs = <DayLog>[];
    for (var d = start; d.isBefore(endDate.add(const Duration(days: 1)));
        d = d.add(const Duration(days: 1))) {
      logs.add(await getDayLog(d));
    }
    return logs;
  }

  Future<Map<String, int>> getAggregates() async {
    final db = await database;
    final now = DateTime.now();
    final todayStr = PrayerLogModel.dateToStr(now);
    final weekStart = PrayerLogModel.dateToStr(now.subtract(const Duration(days: 6)));
    final monthStart = PrayerLogModel.dateToStr(
      DateTime(now.year, now.month, 1),
    );

    final today = await db.rawQuery(
      'SELECT COUNT(*) as total, SUM(completed) as done FROM prayer_logs WHERE date = ?',
      [todayStr],
    );

    final week = await db.rawQuery(
      'SELECT COUNT(*) as total, SUM(completed) as done FROM prayer_logs WHERE date >= ? AND date <= ?',
      [weekStart, todayStr],
    );

    final month = await db.rawQuery(
      'SELECT COUNT(*) as total, SUM(completed) as done FROM prayer_logs WHERE date >= ? AND date <= ?',
      [monthStart, todayStr],
    );

    final allTime = await db.rawQuery(
      'SELECT COUNT(*) as total, SUM(completed) as done FROM prayer_logs',
    );

    return {
      'today_total': (today.first['total'] as int?) ?? 0,
      'today_done': (today.first['done'] as int?) ?? 0,
      'week_total': (week.first['total'] as int?) ?? 0,
      'week_done': (week.first['done'] as int?) ?? 0,
      'month_total': (month.first['total'] as int?) ?? 0,
      'month_done': (month.first['done'] as int?) ?? 0,
      'all_total': (allTime.first['total'] as int?) ?? 0,
      'all_done': (allTime.first['done'] as int?) ?? 0,
    };
  }

  Future<Map<String, int>> getPrayerDistribution() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT prayer_name, SUM(completed) as done FROM prayer_logs GROUP BY prayer_name',
    );
    final map = <String, int>{};
    for (final p in allPrayers) {
      map[p.name] = 0;
    }
    for (final row in rows) {
      map[row['prayer_name'] as String] = (row['done'] as int?) ?? 0;
    }
    return map;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }
}

# Qadaa Progress Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the existing day-by-day prayer tracker with a qadaa (makeup) focused system where users enter years of missed prayers and log per-prayer-type progress.

**Architecture:** 5 separate counters (Fajr/Dhuhr/Asr/Maghrib/Isha) stored in a new `qadaa_progress` SQLite table. A new `QadaaService` encapsulates all business logic. The existing `DatabaseService` gains table creation for the new tables. `SupabaseService` and `SupabaseSyncService` gain methods for the new tables. The home screen switches from `DashboardTab` (day-by-day) to `QadaaTrackerScreen` (per-prayer counters). A new onboarding years-input page is inserted after the 3-page carousel.

**Tech Stack:** Flutter + Material 3 + ChangeNotifier + GetIt DI + sqflite + supabase_flutter

---

### Task 1: Data Models — QadaaProgress + QadaaLog

**Files:**
- Create: `lib/domain/models/qadaa_progress.dart`
- Create: `lib/data/models/qadaa_progress_model.dart`
- Create: `lib/data/models/qadaa_log_model.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/domain/models/qadaa_progress_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/domain/models/qadaa_progress.dart';

void main() {
  group('QadaaProgress', () {
    test('remaining = totalMissed - completed', () {
      final p = QadaaProgress(totalMissed: 365, completed: 40);
      expect(p.remaining, 325);
    });

    test('percentage = (completed / totalMissed) * 100', () {
      final p = QadaaProgress(totalMissed: 365, completed: 73);
      expect(p.percentage, 20.0);
    });

    test('percentage is 0 when totalMissed is 0', () {
      final p = QadaaProgress(totalMissed: 0, completed: 0);
      expect(p.percentage, 0.0);
    });

    test('isComplete returns true when remaining == 0', () {
      final p = QadaaProgress(totalMissed: 365, completed: 365);
      expect(p.isComplete, true);
    });

    test('isComplete returns false when remaining > 0', () {
      final p = QadaaProgress(totalMissed: 365, completed: 100);
      expect(p.isComplete, false);
    });
  });
}
```

Run: `flutter test test/domain/models/qadaa_progress_test.dart`
Expected: FAIL — "target of URI doesn't exist"

- [ ] **Step 2: Implement QadaaProgress domain model**

```dart
// lib/domain/models/qadaa_progress.dart
class QadaaProgress {
  final int totalMissed;
  final int completed;

  const QadaaProgress({
    required this.totalMissed,
    required this.completed,
  });

  int get remaining => totalMissed - completed;
  double get percentage => totalMissed > 0 ? (completed / totalMissed) * 100 : 0;
  bool get isComplete => remaining <= 0;
}
```

- [ ] **Step 3: Write test for QadaaProgressModel**

```dart
// test/data/models/qadaa_progress_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/data/models/qadaa_progress_model.dart';

void main() {
  group('QadaaProgressModel', () {
    test('toMap / fromMap round-trip', () {
      final model = QadaaProgressModel(
        prayerName: 'fajr',
        totalMissed: 365,
        completed: 40,
        updatedAt: '2026-05-30T10:00:00',
      );
      final map = model.toMap();
      final restored = QadaaProgressModel.fromMap(map);
      expect(restored.prayerName, 'fajr');
      expect(restored.totalMissed, 365);
      expect(restored.completed, 40);
      expect(restored.updatedAt, '2026-05-30T10:00:00');
    });

    test('toDomain creates QadaaProgress', () {
      final model = QadaaProgressModel(
        prayerName: 'dhuhr',
        totalMissed: 365,
        completed: 50,
        updatedAt: '2026-05-30T10:00:00',
      );
      final domain = model.toDomain();
      expect(domain.totalMissed, 365);
      expect(domain.completed, 50);
      expect(domain.remaining, 315);
    });
  });
}
```

Run: `flutter test test/data/models/qadaa_progress_model_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 4: Implement QadaaProgressModel**

```dart
// lib/data/models/qadaa_progress_model.dart
import '../../domain/models/qadaa_progress.dart';

class QadaaProgressModel {
  final String prayerName;
  final int totalMissed;
  final int completed;
  final String updatedAt;

  QadaaProgressModel({
    required this.prayerName,
    required this.totalMissed,
    required this.completed,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'prayer_name': prayerName,
    'total_missed': totalMissed,
    'completed': completed,
    'updated_at': updatedAt,
  };

  factory QadaaProgressModel.fromMap(Map<String, dynamic> map) => QadaaProgressModel(
    prayerName: map['prayer_name'] as String,
    totalMissed: map['total_missed'] as int,
    completed: map['completed'] as int,
    updatedAt: map['updated_at'] as String,
  );

  QadaaProgress toDomain() => QadaaProgress(
    totalMissed: totalMissed,
    completed: completed,
  );
}
```

- [ ] **Step 5: Write test for QadaaLogModel**

```dart
// test/data/models/qadaa_log_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/data/models/qadaa_log_model.dart';

void main() {
  group('QadaaLogModel', () {
    test('toMap / fromMap round-trip', () {
      final model = QadaaLogModel(
        prayerName: 'fajr',
        count: 3,
        createdAt: '2026-05-30T10:00:00',
      );
      final map = model.toMap();
      final restored = QadaaLogModel.fromMap(map);
      expect(restored.prayerName, 'fajr');
      expect(restored.count, 3);
      expect(restored.createdAt, '2026-05-30T10:00:00');
    });
  });
}
```

Run: `flutter test test/data/models/qadaa_log_model_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 6: Implement QadaaLogModel**

```dart
// lib/data/models/qadaa_log_model.dart
class QadaaLogModel {
  final int? id;
  final String prayerName;
  final int count;
  final String createdAt;

  QadaaLogModel({
    this.id,
    required this.prayerName,
    required this.count,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'prayer_name': prayerName,
    'count': count,
    'created_at': createdAt,
  };

  factory QadaaLogModel.fromMap(Map<String, dynamic> map) => QadaaLogModel(
    id: map['id'] as int?,
    prayerName: map['prayer_name'] as String,
    count: map['count'] as int,
    createdAt: map['created_at'] as String,
  );
}
```

- [ ] **Step 7: Run all model tests**

Run: `flutter test test/domain/models/qadaa_progress_test.dart test/data/models/qadaa_progress_model_test.dart test/data/models/qadaa_log_model_test.dart`
Expected: ALL PASS

- [ ] **Step 8: Commit**

```bash
git add test/domain/models/qadaa_progress_test.dart lib/domain/models/qadaa_progress.dart test/data/models/qadaa_progress_model_test.dart lib/data/models/qadaa_progress_model.dart test/data/models/qadaa_log_model_test.dart lib/data/models/qadaa_log_model.dart
git commit -m "feat: add QadaaProgress and QadaaLog models"
```

---

### Task 2: QadaaService — Business Logic + Tests

**Files:**
- Create: `lib/services/qadaa_service.dart`
- Create: `test/services/qadaa_service_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/services/qadaa_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/services/qadaa_service.dart';
import 'package:qadaa_prayer_tracker/services/database_service.dart';
import 'package:qadaa_prayer_tracker/domain/models/qadaa_progress.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';
import '../helpers/test_setup.dart';

void main() {
  late DatabaseService db;
  late QadaaService service;

  setUp(() async {
    await testSetupDi();
    db = DatabaseService(dbName: 'qadaa_test_${DateTime.now().millisecondsSinceEpoch}.db');
    service = QadaaService(db: db);
  });

  group('initYears', () {
    test('creates 5 progress rows with correct totals', () async {
      await service.initYears(3);
      for (final p in allPrayers) {
        final progress = await service.getProgress(p);
        expect(progress, isNotNull);
        expect(progress!.totalMissed, 1095);
        expect(progress.completed, 0);
      }
    });

    test('re-initializing resets all counters', () async {
      await service.initYears(1);
      await service.addLog(PrayerName.fajr, 50);
      await service.initYears(2);
      final progress = await service.getProgress(PrayerName.fajr);
      expect(progress!.totalMissed, 730);
      expect(progress.completed, 0);
    });
  });

  group('addLog', () {
    test('increments completed count for the given prayer', () async {
      await service.initYears(1);
      await service.addLog(PrayerName.fajr, 5);
      final progress = await service.getProgress(PrayerName.fajr);
      expect(progress!.completed, 5);
      expect(progress.remaining, 360);
    });

    test('increments completed count across multiple calls', () async {
      await service.initYears(1);
      await service.addLog(PrayerName.dhuhr, 3);
      await service.addLog(PrayerName.dhuhr, 7);
      final progress = await service.getProgress(PrayerName.dhuhr);
      expect(progress!.completed, 10);
    });

    test('does not exceed totalMissed', () async {
      await service.initYears(1);
      await service.addLog(PrayerName.isha, 400);
      final progress = await service.getProgress(PrayerName.isha);
      expect(progress!.completed, 365);
    });

    test('inserts a row into qadaa_logs', () async {
      await service.initYears(1);
      await service.addLog(PrayerName.maghrib, 3);
      final logs = await service.getLogs();
      expect(logs.length, 1);
      expect(logs.first.prayerName, 'maghrib');
      expect(logs.first.count, 3);
    });
  });

  group('getAllProgress', () {
    test('returns all 5 progress records', () async {
      await service.initYears(2);
      final all = await service.getAllProgress();
      expect(all.length, 5);
      for (final p in allPrayers) {
        expect(all.containsKey(p), true);
        expect(all[p]!.totalMissed, 730);
      }
    });
  });

  group('getGrandTotal', () {
    test('returns sum of totalMissed and completed across all prayers', () async {
      await service.initYears(1);
      await service.addLog(PrayerName.fajr, 10);
      await service.addLog(PrayerName.dhuhr, 20);
      final total = await service.getGrandTotal();
      expect(total['total'], 1825);
      expect(total['done'], 30);
    });
  });

  group('getYears / setYears', () {
    test('persists and retrieves years from settings', () async {
      await service.setYears(5);
      final years = await service.getYears();
      expect(years, 5);
    });

    test('returns null when not set', () async {
      final years = await service.getYears();
      expect(years, isNull);
    });
  });
}
```

Run: `flutter test test/services/qadaa_service_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 2: Implement QadaaService**

```dart
// lib/services/qadaa_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/models/qadaa_log_model.dart';
import '../data/models/qadaa_progress_model.dart';
import '../domain/models/prayer_name.dart';
import '../domain/models/qadaa_progress.dart';
import 'database_service.dart';

class QadaaService {
  final DatabaseService _db;

  QadaaService({required DatabaseService db}) : _db = db;

  Future<void> initYears(int years) async {
    final total = years * 365;
    final now = DateTime.now().toIso8601String();
    final db = await _db.database;
    final batch = db.batch();
    for (final p in allPrayers) {
      batch.insert(
        'qadaa_progress',
        {
          'prayer_name': p.name,
          'total_missed': total,
          'completed': 0,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    await _db.setSetting('qadaa_years', years.toString());
  }

  Future<int?> getYears() async {
    final val = await _db.getSetting('qadaa_years');
    return val != null ? int.tryParse(val) : null;
  }

  Future<void> setYears(int years) async {
    await _db.setSetting('qadaa_years', years.toString());
  }

  Future<QadaaProgress?> getProgress(PrayerName prayer) async {
    final db = await _db.database;
    final rows = await db.query(
      'qadaa_progress',
      where: 'prayer_name = ?',
      whereArgs: [prayer.name],
    );
    if (rows.isEmpty) return null;
    return QadaaProgressModel.fromMap(rows.first).toDomain();
  }

  Future<Map<PrayerName, QadaaProgress>> getAllProgress() async {
    final db = await _db.database;
    final rows = await db.query('qadaa_progress');
    final map = <PrayerName, QadaaProgress>{};
    for (final row in rows) {
      final model = QadaaProgressModel.fromMap(row);
      final name = PrayerName.values.byName(model.prayerName);
      map[name] = model.toDomain();
    }
    return map;
  }

  Future<void> addLog(PrayerName prayer, int count) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();

    final row = await db.query(
      'qadaa_progress',
      where: 'prayer_name = ?',
      whereArgs: [prayer.name],
    );
    if (row.isEmpty) return;

    final model = QadaaProgressModel.fromMap(row.first);
    final newCompleted = (model.completed + count).clamp(0, model.totalMissed);

    await db.update(
      'qadaa_progress',
      {'completed': newCompleted, 'updated_at': now},
      where: 'prayer_name = ?',
      whereArgs: [prayer.name],
    );

    await db.insert('qadaa_logs', {
      'prayer_name': prayer.name,
      'count': count,
      'created_at': now,
    });

    debugPrint('QadaaService: +$count ${prayer.name} ($newCompleted/${model.totalMissed})');
  }

  Future<List<QadaaLogModel>> getLogs({int limit = 50}) async {
    final db = await _db.database;
    final rows = await db.query(
      'qadaa_logs',
      orderBy: 'id DESC',
      limit: limit,
    );
    return rows.map((r) => QadaaLogModel.fromMap(r)).toList();
  }

  Future<Map<String, int>> getGrandTotal() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total_missed), 0) as total, COALESCE(SUM(completed), 0) as done FROM qadaa_progress',
    );
    return {
      'total': (result.first['total'] as int?) ?? 0,
      'done': (result.first['done'] as int?) ?? 0,
    };
  }

  Future<void> resetFromYears(int years) async {
    final db = await _db.database;
    final total = years * 365;
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final p in allPrayers) {
      batch.insert(
        'qadaa_progress',
        {
          'prayer_name': p.name,
          'total_missed': total,
          'completed': 0,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    await db.delete('qadaa_logs');
    await _db.setSetting('qadaa_years', years.toString());
  }
}
```

- [ ] **Step 3: Run test to verify it passes**

Run: `flutter test test/services/qadaa_service_test.dart`
Expected: ALL PASS

- [ ] **Step 4: Commit**

```bash
git add lib/services/qadaa_service.dart test/services/qadaa_service_test.dart
git commit -m "feat: add QadaaService with years init, logging, and progress tracking"
```

---

### Task 3: DatabaseService Migration — Add qadaa_progress + qadaa_logs Tables

**Files:**
- Modify: `lib/services/database_service.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/services/database_service_qadaa_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/services/database_service.dart';
import '../helpers/test_setup.dart';

void main() {
  late DatabaseService db;

  setUp(() async {
    await testSetupDi();
    db = DatabaseService(dbName: 'qadaa_db_test_${DateTime.now().millisecondsSinceEpoch}.db');
  });

  test('qadaa_progress and qadaa_logs tables exist', () async {
    final database = await db.database;
    final tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('qadaa_progress', 'qadaa_logs')",
    );
    expect(tables.length, 2);
  });
}
```

Run: `flutter test test/services/database_service_qadaa_test.dart`
Expected: FAIL — tables don't exist

- [ ] **Step 2: Modify DatabaseService to create new tables**

Edit `lib/services/database_service.dart`:

In `onCreate`, add after settings table creation:
```dart
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
```

Bump version from 3 to 4:
```dart
version: 4,
```

In `onUpgrade`, add after old < 3 block:
```dart
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
```

- [ ] **Step 3: Run test to verify it passes**

Run: `flutter test test/services/database_service_qadaa_test.dart`
Expected: ALL PASS

- [ ] **Step 4: Run all existing tests to verify no regression**

Run: `flutter test`
Expected: ALL PASS (189+ existing + new)

- [ ] **Step 5: Commit**

```bash
git add lib/services/database_service.dart test/services/database_service_qadaa_test.dart
git commit -m "feat: add qadaa_progress and qadaa_logs tables to DatabaseService (v4)"
```

---

### Task 4: Supabase Migration — New Tables

**Files:**
- Create: `supabase/migrations/20260530_create_qadaa_progress_tables.sql`

- [ ] **Step 1: Write migration SQL**

```sql
-- supabase/migrations/20260530_create_qadaa_progress_tables.sql

CREATE TABLE IF NOT EXISTS qadaa.qadaa_progress (
  prayer_name TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_missed INTEGER NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (prayer_name, user_id)
);

CREATE TABLE IF NOT EXISTS qadaa.qadaa_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  prayer_name TEXT NOT NULL,
  count INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE qadaa.qadaa_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE qadaa.qadaa_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own qadaa progress"
  ON qadaa.qadaa_progress FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage their own qadaa logs"
  ON qadaa.qadaa_logs FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

GRANT USAGE ON SCHEMA qadaa TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA qadaa TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA qadaa TO service_role;
```

- [ ] **Step 2: Commit**

```bash
git add supabase/migrations/20260530_create_qadaa_progress_tables.sql
git commit -m "feat: add qadaa_progress and qadaa_logs tables to Supabase schema"
```

---

### Task 5: SupabaseService + SupabaseSyncService — New Table Support

**Files:**
- Modify: `lib/services/supabase_service.dart`
- Modify: `lib/services/supabase_sync_service.dart`
- Modify: `test/helpers/mocks.dart`

- [ ] **Step 1: Add methods to SupabaseService**

Edit `lib/services/supabase_service.dart`, add after line 114:

```dart
Future<void> upsertQadaaProgress({
  required String prayerName,
  required int totalMissed,
  required int completed,
}) async {
  if (userId == null) return;
  final now = DateTime.now().toUtc().toIso8601String();
  await client.from('qadaa.qadaa_progress').upsert({
    'user_id': userId,
    'prayer_name': prayerName,
    'total_missed': totalMissed,
    'completed': completed,
    'updated_at': now,
  }, onConflict: 'prayer_name,user_id');
}

Future<List<Map<String, dynamic>>> getQadaaProgress() async {
  if (userId == null) return [];
  final resp = await client
      .from('qadaa.qadaa_progress')
      .select()
      .eq('user_id', userId!);
  return (resp as List<dynamic>).cast<Map<String, dynamic>>();
}

Future<void> upsertQadaaLog({
  required String prayerName,
  required int count,
}) async {
  if (userId == null) return;
  await client.from('qadaa.qadaa_logs').insert({
    'user_id': userId,
    'prayer_name': prayerName,
    'count': count,
  });
}

Future<List<Map<String, dynamic>>> getQadaaLogs({int limit = 100}) async {
  if (userId == null) return [];
  final resp = await client
      .from('qadaa.qadaa_logs')
      .select()
      .eq('user_id', userId!)
      .order('created_at', ascending: false)
      .limit(limit);
  return (resp as List<dynamic>).cast<Map<String, dynamic>>();
}
```

- [ ] **Step 2: Update SupabaseSyncService to sync new tables**

Edit `lib/services/supabase_sync_service.dart`:

In `syncAll()`, add after settings sync block:
```dart
final qadaaResult = await _syncQadaaProgress();
uploaded += qadaaResult.$1;
downloaded += qadaaResult.$2;
```

Add new methods:
```dart
Future<(int, int)> _syncQadaaProgress() async {
  final db = await _db.database;
  final localRows = await db.query('qadaa_progress');

  for (final row in localRows) {
    try {
      await _supabase.upsertQadaaProgress(
        prayerName: row['prayer_name'] as String,
        totalMissed: row['total_missed'] as int,
        completed: row['completed'] as int,
      );
    } catch (e) {
      debugPrint('Failed to sync qadaa progress: $e');
    }
  }

  try {
    final cloudRows = await _supabase.getQadaaProgress();
    for (final row in cloudRows) {
      final existing = await db.query(
        'qadaa_progress',
        where: 'prayer_name = ?',
        whereArgs: [row['prayer_name']],
      );
      if (existing.isEmpty) {
        await db.insert('qadaa_progress', {
          'prayer_name': row['prayer_name'],
          'total_missed': row['total_missed'],
          'completed': row['completed'],
          'updated_at': row['updated_at'] ?? DateTime.now().toIso8601String(),
        });
      }
    }
    return (localRows.length, cloudRows.length);
  } catch (e) {
    debugPrint('Failed to download qadaa progress: $e');
    return (localRows.length, 0);
  }
}
```

- [ ] **Step 3: Update MockSupabaseService**

Edit `test/helpers/mocks.dart`, add inside `MockSupabaseService`:
```dart
@override
Future<void> upsertQadaaProgress({
  required String prayerName,
  required int totalMissed,
  required int completed,
}) async {}

@override
Future<List<Map<String, dynamic>>> getQadaaProgress() async => [];

@override
Future<void> upsertQadaaLog({
  required String prayerName,
  required int count,
}) async {}

@override
Future<List<Map<String, dynamic>>> getQadaaLogs({int limit = 100}) async => [];
```

- [ ] **Step 4: Run all tests**

Run: `flutter test`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/supabase_service.dart lib/services/supabase_sync_service.dart test/helpers/mocks.dart
git commit -m "feat: add qadaa_progress and qadaa_logs sync support"
```

---

### Task 6: L10n — Add Qadaa-Related Strings

**Files:**
- Modify: `lib/l10n/app_ar.arb`
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Add Arabic strings**

Edit `lib/l10n/app_ar.arb`:
```json
{
  "qadaaTitle": "القضاء",
  "qadaaYearsPrompt": "كم سنة فاتتك من الصلوات؟",
  "qadaaYearsSummary": "المطلوب: 5 صلوات × 365 يوم × {years} سنة = {total} صلاة",
  "qadaaYearsSummaryPlaceholder": "المطلوب: 5 صلوات × 365 يوم · {years} سنة · {total} صلاة",
  "qadaaStart": "ابدأ",
  "qadaaRemaining": "المتبقي",
  "qadaaCompleted": "مقضية",
  "qadaaTotal": "الإجمالي",
  "qadaaProgress": "التقدم",
  "qadaaLog": "سجل",
  "qadaaQuickAdd1": "+1",
  "qadaaQuickAdd5": "+5",
  "qadaaQuickAdd10": "+10",
  "qadaaCustomAdd": "أدخل عدد",
  "qadaaNoYearsSet": "لم تحدد عدد السنوات بعد",
  "qadaaConfigureNow": "تحديد السنوات",
  "qadaaCompleteBadge": "تم القضاء",
  "qadaaYearsLabel": "سنين الفائتة",
  "qadaaYearsResetWarning": "سيتم إعادة تعيين التقدم بالكامل",
  "qadaaResetConfirm": "تأكيد إعادة التعيين",
  "qadaaNowPrayer": "الآن: وقت {prayer}",
  "qadaaGrandTotal": "{done} / {total} صلاة",
  "qadaaPrayerFajr": "الفجر",
  "qadaaPrayerDhuhr": "الظهر",
  "qadaaPrayerAsr": "العصر",
  "qadaaPrayerMaghrib": "المغرب",
  "qadaaPrayerIsha": "العشاء"
}
```

- [ ] **Step 2: Add English strings**

Edit `lib/l10n/app_en.arb`:
```json
{
  "qadaaTitle": "Qadaa",
  "qadaaYearsPrompt": "How many years of missed prayers?",
  "qadaaYearsSummary": "Required: 5 prayers × 365 days × {years} years = {total} prayers",
  "qadaaYearsSummaryPlaceholder": "Required: 5 prayers × 365 days · {years} years · {total} prayers",
  "qadaaStart": "Start",
  "qadaaRemaining": "Remaining",
  "qadaaCompleted": "Completed",
  "qadaaTotal": "Total",
  "qadaaProgress": "Progress",
  "qadaaLog": "Log",
  "qadaaQuickAdd1": "+1",
  "qadaaQuickAdd5": "+5",
  "qadaaQuickAdd10": "+10",
  "qadaaCustomAdd": "Enter count",
  "qadaaNoYearsSet": "Years not set yet",
  "qadaaConfigureNow": "Set Years",
  "qadaaCompleteBadge": "Complete",
  "qadaaYearsLabel": "Missed Years",
  "qadaaYearsResetWarning": "This will reset all progress",
  "qadaaResetConfirm": "Confirm Reset",
  "qadaaNowPrayer": "Now: {prayer} time",
  "qadaaGrandTotal": "{done} / {total} prayers",
  "qadaaPrayerFajr": "Fajr",
  "qadaaPrayerDhuhr": "Dhuhr",
  "qadaaPrayerAsr": "Asr",
  "qadaaPrayerMaghrib": "Maghrib",
  "qadaaPrayerIsha": "Isha"
}
```

- [ ] **Step 3: Run analyzer**

Run: `dart analyze lib/l10n/`
Expected: no errors

- [ ] **Step 4: Commit**

```bash
git add lib/l10n/app_ar.arb lib/l10n/app_en.arb
git commit -m "feat: add qadaa-related localization strings"
```

---

### Task 7: DI — Register QadaaService

**Files:**
- Modify: `lib/di/locator.dart`
- Modify: `test/helpers/test_setup.dart`

- [ ] **Step 1: Register QadaaService**

Edit `lib/di/locator.dart`:
- Add import: `import '../services/qadaa_service.dart';`
- Add after SupabaseSyncService registration:
```dart
sl.registerLazySingleton<QadaaService>(() => QadaaService(db: sl()));
```

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: ALL PASS

- [ ] **Step 3: Commit**

```bash
git add lib/di/locator.dart
git commit -m "feat: register QadaaService in DI"
```

---

### Task 8: Onboarding — Years Input Page

**Files:**
- Create: `lib/ui/features/onboarding/views/years_input_page.dart`
- Modify: `lib/ui/features/onboarding/views/onboarding_screen.dart`
- Create: `test/features/onboarding/years_input_page_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/features/onboarding/years_input_page_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:qadaa_prayer_tracker/ui/features/onboarding/views/years_input_page.dart';
import 'package:qadaa_prayer_tracker/theme/app_theme.dart';

void main() {
  testWidgets('renders years prompt and summary', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const YearsInputPage(),
      ),
    );

    expect(find.text('كم سنة فاتتك من الصلوات؟'), findsOneWidget);
    expect(find.text('ابدأ'), findsOneWidget);
  });

  testWidgets('increment and decrement years', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: YearsInputPage(onConfirm: (years) => result = years),
      ),
    );

    // Default should be 1
    expect(find.text('1'), findsOneWidget);

    // Increment
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    // Decrement
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('calls onConfirm with years value', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: YearsInputPage(onConfirm: (years) => result = years),
      ),
    );

    await tester.tap(find.text('ابدأ'));
    expect(result, 1);
  });
}
```

Run: `flutter test test/features/onboarding/years_input_page_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 2: Implement YearsInputPage**

```dart
// lib/ui/features/onboarding/views/years_input_page.dart
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class YearsInputPage extends StatefulWidget {
  final ValueChanged<int>? onConfirm;

  const YearsInputPage({super.key, this.onConfirm});

  @override
  State<YearsInputPage> createState() => _YearsInputPageState();
}

class _YearsInputPageState extends State<YearsInputPage> {
  int _years = 1;

  int get _total => 5 * 365 * _years;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.access_time_rounded, size: 56, color: AppTheme.primary),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
            const Text(
              'كم سنة فاتتك من الصلوات؟',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceXxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _years > 1 ? () => setState(() => _years--) : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: AppTheme.spaceXxl),
                Text(
                  '$_years',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceXxl),
                IconButton.filled(
                  onPressed: _years < 50 ? () => setState(() => _years++) : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'سنة',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                'المطلوب: 5 صلوات × 365 يوم · $_years سنة · $_total صلاة',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onConfirm?.call(_years),
                child: const Text('ابدأ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run widget test to verify it passes**

Run: `flutter test test/features/onboarding/years_input_page_test.dart`
Expected: ALL PASS

- [ ] **Step 4: Integrate into OnboardingScreen**

Edit `lib/ui/features/onboarding/views/onboarding_screen.dart`:

- Add import for YearsInputPage, QadaaTrackerScreen, QadaaService, and DI
```dart
import 'years_input_page.dart';
import '../../home/views/home_screen.dart';
import '../../../../services/qadaa_service.dart';
import '../../../../di/locator.dart';
```

- Change `_goToHome()` to navigate to YearsInputPage instead:
```dart
void _goToHome() {
  // Initially goes to home, after onboarding years input
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
  );
}
```

Actually, the onboarding flow should be:
1. 3 carousel pages (existing)
2. "ابدأ الآن" button navigates to YearsInputPage
3. YearsInputPage onConfirm → saves years to QadaaService → navigates to HomeScreen

Edit the `_goToHome` method and the button handler:

```dart
void _goToYearsInput() {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => YearsInputPage(
        onConfirm: (years) async {
          final qadaaService = sl<QadaaService>();
          await qadaaService.initYears(years);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
      ),
    ),
  );
}
```

Replace calls to `_goToHome` with `_goToYearsInput` in:
- The ElevatedButton `onPressed` on the last page
- The TextButton "تخطي" also routes to years input (they still need to set years)

Actually, skip button should go directly to HomeScreen (years set later in settings). Let me keep skip → HomeScreen, and the main button → YearsInputPage.

- [ ] **Step 5: Run all tests**

Run: `flutter test`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```bash
git add lib/ui/features/onboarding/views/years_input_page.dart test/features/onboarding/years_input_page_test.dart lib/ui/features/onboarding/views/onboarding_screen.dart
git commit -m "feat: add years input page to onboarding"
```

---

### Task 9: Qadaa Tracker Home Screen — QadaaPrayerCard + QadaaTrackerScreen

**Files:**
- Create: `lib/ui/features/home/views/qadaa_prayer_card.dart`
- Create: `lib/ui/features/home/views/qadaa_tracker_screen.dart`
- Create: `test/features/home/qadaa_prayer_card_test.dart`
- Create: `test/features/home/qadaa_tracker_screen_test.dart`

- [ ] **Step 1: Write the failing test for QadaaPrayerCard**

```dart
// test/features/home/qadaa_prayer_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/views/qadaa_prayer_card.dart';
import 'package:qadaa_prayer_tracker/domain/models/qadaa_progress.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';
import 'package:qadaa_prayer_tracker/theme/app_theme.dart';

void main() {
  testWidgets('displays prayer name and remaining count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: QadaaPrayerCard(
            prayer: PrayerName.fajr,
            progress: const QadaaProgress(totalMissed: 365, completed: 40),
            isCurrent: false,
          ),
        ),
      ),
    );

    expect(find.text('الفجر'), findsOneWidget);
    expect(find.text('325'), findsOneWidget); // remaining
  });

  testWidgets('shows quick add buttons when not complete', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: QadaaPrayerCard(
            prayer: PrayerName.dhuhr,
            progress: const QadaaProgress(totalMissed: 365, completed: 40),
            isCurrent: true,
          ),
        ),
      ),
    );

    expect(find.text('+1'), findsOneWidget);
    expect(find.text('+5'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
  });

  testWidgets('shows complete badge when remaining is 0', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: QadaaPrayerCard(
            prayer: PrayerName.fajr,
            progress: const QadaaProgress(totalMissed: 365, completed: 365),
            isCurrent: true,
          ),
        ),
      ),
    );

    expect(find.text('تم القضاء'), findsOneWidget);
    expect(find.text('+1'), findsNothing);
  });

  testWidgets('calls onAdd when quick add button is tapped', (tester) async {
    int added = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: QadaaPrayerCard(
            prayer: PrayerName.maghrib,
            progress: const QadaaProgress(totalMissed: 365, completed: 40),
            isCurrent: true,
            onAdd: (count) => added = count,
          ),
        ),
      ),
    );

    await tester.tap(find.text('+5'));
    expect(added, 5);
  });
}
```

Run: `flutter test test/features/home/qadaa_prayer_card_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 2: Implement QadaaPrayerCard**

```dart
// lib/ui/features/home/views/qadaa_prayer_card.dart
import 'package:flutter/material.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../../../domain/models/qadaa_progress.dart';
import '../../../../theme/app_theme.dart';

class QadaaPrayerCard extends StatelessWidget {
  final PrayerName prayer;
  final QadaaProgress progress;
  final bool isCurrent;
  final ValueChanged<int>? onAdd;

  const QadaaPrayerCard({
    super.key,
    required this.prayer,
    required this.progress,
    required this.isCurrent,
    this.onAdd,
  });

  Color get _prayerColor => AppTheme.prayerColor(prayer.index);

  @override
  Widget build(BuildContext context) {
    final isComplete = progress.isComplete;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        decoration: isCurrent && !isComplete
            ? BoxDecoration(
                border: Border.all(color: _prayerColor.withValues(alpha: 0.4), width: 1.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: isComplete ? AppTheme.primary : _prayerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Text(
                    prayer.arName,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${progress.remaining}',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isComplete ? AppTheme.primary : _prayerColor,
                    ),
                  ),
                ],
              ),
              if (isComplete) ...[
                const SizedBox(height: AppTheme.spaceMd),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text(
                        'تم القضاء',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!isComplete && isCurrent) ...[
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    _QuickAddBtn(label: '+1', count: 1),
                    const SizedBox(width: AppTheme.spaceSm),
                    _QuickAddBtn(label: '+5', count: 5),
                    const SizedBox(width: AppTheme.spaceSm),
                    _QuickAddBtn(label: '+10', count: 10),
                  ],
                ),
              ],
              if (!isComplete && !isCurrent)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spaceSm),
                  child: Text(
                    'متبقي ${progress.remaining}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _QuickAddBtn({required String label, required int count}) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => onAdd?.call(count),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _prayerColor,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run QadaaPrayerCard test**

Run: `flutter test test/features/home/qadaa_prayer_card_test.dart`
Expected: ALL PASS

- [ ] **Step 4: Write failing test for QadaaTrackerScreen**

```dart
// test/features/home/qadaa_tracker_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/views/qadaa_tracker_screen.dart';
import 'package:qadaa_prayer_tracker/theme/app_theme.dart';

void main() {
  testWidgets('shows loading state initially', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const QadaaTrackerScreen(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

Run: `flutter test test/features/home/qadaa_tracker_screen_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 5: Implement QadaaTrackerScreen**

```dart
// lib/ui/features/home/views/qadaa_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../di/locator.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../../../domain/models/qadaa_progress.dart';
import '../../../../services/qadaa_service.dart';
import '../../../../services/prayer_time_service.dart';
import '../../../../theme/app_theme.dart';
import 'qadaa_prayer_card.dart';

class QadaaTrackerScreen extends StatefulWidget {
  const QadaaTrackerScreen({super.key});

  @override
  State<QadaaTrackerScreen> createState() => _QadaaTrackerScreenState();
}

class _QadaaTrackerScreenState extends State<QadaaTrackerScreen> {
  final _qadaaService = sl<QadaaService>();
  final _prayerTimeService = sl<PrayerTimeService>();

  bool _loading = true;
  Map<PrayerName, QadaaProgress> _progress = {};
  int? _grandTotal;
  int? _grandDone;
  PrayerName _selectedPrayer = PrayerName.dhuhr;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final years = await _qadaaService.getYears();
      if (years == null) {
        setState(() {
          _loading = false;
          _progress = {};
        });
        return;
      }

      final allProgress = await _qadaaService.getAllProgress();
      final grand = await _qadaaService.getGrandTotal();
      final currentPrayer = _guessCurrentPrayer();

      setState(() {
        _progress = allProgress;
        _grandTotal = grand['total'];
        _grandDone = grand['done'];
        _selectedPrayer = currentPrayer;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  PrayerName _guessCurrentPrayer() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final totalMinutes = hour * 60 + minute;

    // Rough estimate based on typical prayer times
    if (totalMinutes < 4 * 60 + 30) return PrayerName.fajr;        // Before 4:30
    if (totalMinutes < 12 * 60 + 30) return PrayerName.dhuhr;      // 4:30 - 12:30
    if (totalMinutes < 16 * 60) return PrayerName.asr;              // 12:30 - 16:00
    if (totalMinutes < 19 * 60 + 30) return PrayerName.maghrib;     // 16:00 - 19:30
    return PrayerName.isha;                                          // After 19:30
  }

  Future<void> _addLog(PrayerName prayer, int count) async {
    await _qadaaService.addLog(prayer, count);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    if (_progress.isEmpty) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceXxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, size: 64, color: AppTheme.outline.withValues(alpha: 0.4)),
                const SizedBox(height: AppTheme.spaceLg),
                const Text(
                  'لم تحدد عدد السنوات بعد',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                FilledButton.icon(
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('تحديد السنوات'),
                  onPressed: () => _showYearsDialog(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentProgress = _progress[_selectedPrayer];
    if (currentProgress == null) return const SizedBox.shrink();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'القضاء',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'الآن: وقت ${_selectedPrayer.arName} 🕌',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            QadaaPrayerCard(
              prayer: _selectedPrayer,
              progress: currentProgress,
              isCurrent: true,
              onAdd: (count) => _addLog(_selectedPrayer, count),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            // Other prayers row
            ...allPrayers.where((p) => p != _selectedPrayer).map((p) {
              final prog = _progress[p];
              if (prog == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
                child: QadaaPrayerCard(
                  prayer: p,
                  progress: prog,
                  isCurrent: false,
                  onAdd: (count) => _addLog(p, count),
                ),
              );
            }),
            if (_grandTotal != null && _grandDone != null) ...[
              const SizedBox(height: AppTheme.spaceXl),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: LinearProgressIndicator(
                  value: _grandTotal! > 0 ? _grandDone! / _grandTotal! : 0,
                  minHeight: 8,
                  backgroundColor: AppTheme.outlineVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Center(
                child: Text(
                  '$_grandDone / $_grandTotal صلاة',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showYearsDialog(BuildContext context) {
    int years = 1;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('تحديد السنوات', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('كم سنة فاتتك من الصلوات؟', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
              const SizedBox(height: AppTheme.spaceLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: years > 1 ? () => setDState(() => years--) : null, icon: const Icon(Icons.remove)),
                  Text('$years', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  IconButton(onPressed: years < 50 ? () => setDState(() => years++) : null, icon: const Icon(Icons.add)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _qadaaService.initYears(years).then((_) => _load());
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run QadaaTrackerScreen test**

Run: `flutter test test/features/home/qadaa_tracker_screen_test.dart`
Expected: ALL PASS

- [ ] **Step 7: Commit**

```bash
git add lib/ui/features/home/views/qadaa_prayer_card.dart lib/ui/features/home/views/qadaa_tracker_screen.dart test/features/home/qadaa_prayer_card_test.dart test/features/home/qadaa_tracker_screen_test.dart
git commit -m "feat: add QadaaPrayerCard and QadaaTrackerScreen"
```

---

### Task 10: Update HomeScreen to use QadaaTrackerScreen

**Files:**
- Modify: `lib/ui/features/home/views/home_screen.dart`

- [ ] **Step 1: Replace DashboardTab with QadaaTrackerScreen**

Edit `lib/ui/features/home/views/home_screen.dart`:
- Add import: `import 'qadaa_tracker_screen.dart';`
- Replace `DashboardTab()` with `const QadaaTrackerScreen()`:

```dart
final _pages = const [QadaaTrackerScreen(), StatsScreen(), ContentScreen(), SettingsScreen()];
```

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: ALL PASS

- [ ] **Step 3: Commit**

```bash
git add lib/ui/features/home/views/home_screen.dart
git commit -m "feat: replace DashboardTab with QadaaTrackerScreen in HomeScreen"
```

---

### Task 11: Settings — Add Qadaa Years Section

**Files:**
- Modify: `lib/ui/features/settings/views/settings_screen.dart`
- Modify: `lib/ui/features/settings/view_models/settings_view_model.dart`
- Create: `test/features/settings/qadaa_years_settings_test.dart`

- [ ] **Step 1: Write failing test for settings view model years**

```dart
// test/features/settings/qadaa_years_settings_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/services/database_service.dart';
import 'package:qadaa_prayer_tracker/ui/features/settings/view_models/settings_view_model.dart';
import 'package:qadaa_prayer_tracker/data/repositories/prayer_log_repository.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  late SettingsViewModel vm;
  late MockNotificationService notifService;
  late MockDatabaseService db;
  late MockPrayerTimeService prayerTimeService;
  late MockLocaleNotifier localeNotifier;
  late MockThemeNotifier themeNotifier;

  setUp(() async {
    await testSetupDi();
    notifService = MockNotificationService();
    db = MockDatabaseService();
    prayerTimeService = MockPrayerTimeService();
    localeNotifier = MockLocaleNotifier();
    themeNotifier = MockThemeNotifier();

    vm = SettingsViewModel(
      logRepo: MockLogRepo(),
      notifService: notifService,
      db: db,
      prayerTimeService: prayerTimeService,
      localeNotifier: localeNotifier,
      themeNotifier: themeNotifier,
    );
  });

  test('qadaaYears defaults to null', () {
    expect(vm.qadaaYears, isNull);
  });

  test('setQadaaYears updates the value', () async {
    await vm.setQadaaYears(5);
    expect(vm.qadaaYears, 5);
  });

  test('loadSettings loads qadaa_years from settings', () async {
    await db.setSetting('qadaa_years', '3');
    await vm.loadSettings();
    expect(vm.qadaaYears, 3);
  });
}
```

Run: `flutter test test/features/settings/qadaa_years_settings_test.dart`
Expected: FAIL — qadaaYears not in VM

- [ ] **Step 2: Update SettingsViewModel**

Edit `lib/ui/features/settings/view_models/settings_view_model.dart`:

Add after existing fields:
```dart
int? _qadaaYears;
int? get qadaaYears => _qadaaYears;
```

Add in `loadSettings()` after existing settings:
```dart
final savedQadaaYears = await _db.getSetting('qadaa_years');
_qadaaYears = int.tryParse(savedQadaaYears ?? '');
```

Add new methods:
```dart
Future<void> setQadaaYears(int years) async {
  try {
    _qadaaYears = years;
    await _db.setSetting('qadaa_years', years.toString());
    notifyListeners();
  } catch (e) {
    error = e.toString();
    notifyListeners();
  }
}

Future<void> resetQadaaProgress() async {
  try {
    final db = await _db.database;
    await db.delete('qadaa_progress');
    await db.delete('qadaa_logs');
    _qadaaYears = null;
    await _db.setSetting('qadaa_years', '');
    notifyListeners();
  } catch (e) {
    error = e.toString();
    notifyListeners();
  }
}
```

- [ ] **Step 3: Update SettingsScreen UI**

Edit `lib/ui/features/settings/views/settings_screen.dart`:

Add after the notification section and before العامة:
```dart
const SizedBox(height: AppTheme.spaceXxl),
const _GroupHeader(title: 'القضاء'),
const SizedBox(height: AppTheme.spaceMd),
_SettingsNav(
  icon: Icons.access_time_rounded,
  title: 'سنين الفائتة',
  subtitle: vm.qadaaYears != null ? '${vm.qadaaYears} سنة' : 'غير محدد',
  onTap: () => _showQadaaYearsDialog(context),
),
```

Add method:
```dart
void _showQadaaYearsDialog(BuildContext context) {
  int years = vm.qadaaYears ?? 1;
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDState) => AlertDialog(
        title: const Text('سنين الفائتة', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('كم سنة فاتتك من الصلوات؟', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
            const SizedBox(height: AppTheme.spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: years > 1 ? () => setDState(() => years--) : null, icon: const Icon(Icons.remove)),
                Text('$years', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                IconButton(onPressed: years < 50 ? () => setDState(() => years++) : null, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.error),
                  SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: Text(
                      'سيتم إعادة تعيين التقدم بالكامل',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.resetQadaaProgress();
              if (context.mounted) {
                final qadaaService = sl<QadaaService>();
                await qadaaService.initYears(years);
                await vm.loadSettings();
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    ),
  );
}
```

Add import for service and DI:
```dart
import '../../../../services/qadaa_service.dart';
```

- [ ] **Step 4: Run all tests**

Run: `flutter test`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
git add lib/ui/features/settings/view_models/settings_view_model.dart lib/ui/features/settings/views/settings_screen.dart test/features/settings/qadaa_years_settings_test.dart
git commit -m "feat: add qadaa years section to settings"
```

---

### Task 12: Remove Old Dashboard Tab / Prayer Logs References (Cleanup)

**Files:**
- Optionally delete: `lib/ui/features/home/views/dashboard_tab.dart`
- Optionally delete: `lib/ui/features/home/views/hero_stats_card.dart`
- Optionally delete: `lib/ui/features/home/views/greeting_header.dart`
- Optionally delete: `lib/ui/features/home/views/reminder_list.dart`
- Update: `lib/ui/features/home/view_models/home_view_model.dart` (simplify or remove)

- [ ] **Step 1: Clean up old home files**

Delete unused dashboard files:
```bash
git rm lib/ui/features/home/views/dashboard_tab.dart lib/ui/features/home/views/hero_stats_card.dart lib/ui/features/home/views/greeting_header.dart lib/ui/features/home/views/reminder_list.dart
```

- [ ] **Step 2: Run analyzer + tests**

Run: `dart analyze lib/ && flutter test`
Expected: 0 issues, ALL PASS

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove old dashboard tab (replaced by QadaaTrackerScreen)"
```

---

### Task 13: Full Test Pass + Health Check

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: ALL PASS (expected ~200+ tests)

- [ ] **Step 2: Run analyzer**

Run: `dart analyze lib/`
Expected: 0 issues

- [ ] **Step 3: Commit final state**

```bash
git add -A
git commit -m "chore: final qadaa progress tracking feature complete"
```

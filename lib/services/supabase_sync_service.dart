import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'supabase_service.dart';

class SupabaseSyncService {
  final SupabaseService _supabase;
  final DatabaseService _db;

  SupabaseSyncService({
    required SupabaseService supabase,
    required DatabaseService db,
  }) : _supabase = supabase, _db = db;

  bool _syncing = false;
  bool get isSyncing => _syncing;

  Stream<SyncProgress> get progress => _progressController.stream;
  final _progressController = StreamController<SyncProgress>.broadcast();

  void dispose() => _progressController.close();

  Future<SyncResult> syncAll() async {
    if (!_supabase.isSignedIn) return SyncResult(0, 0, 'Not signed in');
    if (_syncing) return SyncResult(0, 0, 'Sync already in progress');

    _syncing = true;
    _progressController.add(SyncProgress.starting());
    int uploaded = 0;
    int downloaded = 0;

    try {
      final logsResult = await _syncPrayerLogs();
      uploaded += logsResult.$1;
      downloaded += logsResult.$2;

      final settingsResult = await _syncSettings();
      uploaded += settingsResult.$1;
      downloaded += settingsResult.$2;

      _progressController.add(SyncProgress.complete(uploaded, downloaded));
      return SyncResult(uploaded, downloaded, null);
    } catch (e) {
      _progressController.add(SyncProgress.error(e.toString()));
      return SyncResult(uploaded, downloaded, e.toString());
    } finally {
      _syncing = false;
    }
  }

  Future<(int, int)> _syncPrayerLogs() async {
    final db = await _db.database;
    final localRows = await db.rawQuery(
      "SELECT date, prayer_name, completed FROM prayer_logs WHERE completed = 1",
    );

    for (final row in localRows) {
      try {
        await _supabase.upsertPrayerLog(
          date: row['date'] as String,
          prayerName: row['prayer_name'] as String,
          completed: (row['completed'] as int) == 1,
        );
      } catch (e) {
        debugPrint('Failed to sync prayer log: $e');
      }
    }

    final cloudRows = await _supabase.getPrayerLogs();
    final now = DateTime.now();
    final today = SupabaseService.formatDate(now);

    int downloaded = 0;
    for (final row in cloudRows) {
      final date = row['date'] as String;
      if (date == today) {
        final existing = await db.query(
          'prayer_logs',
          where: 'date = ? AND prayer_name = ?',
          whereArgs: [date, row['prayer_name']],
        );
        if (existing.isEmpty) {
          await db.insert('prayer_logs', {
            'date': date,
            'prayer_name': row['prayer_name'],
            'completed': (row['completed'] as bool) ? 1 : 0,
            'created_at': date,
          });
          downloaded++;
        }
      }
    }

    return (localRows.length, downloaded);
  }

  Future<(int, int)> _syncSettings() async {
    final db = await _db.database;
    final localSettings = await db.query('settings');

    int uploaded = 0;
    for (final row in localSettings) {
      await _supabase.upsertSetting(
        row['key'] as String,
        row['value'] as String,
      );
      uploaded++;
    }

    return (uploaded, 0);
  }
}

class SyncProgress {
  final String status;
  final int uploaded;
  final int downloaded;
  final String? error;

  SyncProgress._({
    required this.status,
    this.uploaded = 0,
    this.downloaded = 0,
    this.error,
  });

  factory SyncProgress.starting() =>
      SyncProgress._(status: 'starting');
  factory SyncProgress.inProgress(int uploaded, int downloaded) =>
      SyncProgress._(status: 'in_progress', uploaded: uploaded, downloaded: downloaded);
  factory SyncProgress.complete(int uploaded, int downloaded) =>
      SyncProgress._(status: 'complete', uploaded: uploaded, downloaded: downloaded);
  factory SyncProgress.error(String error) =>
      SyncProgress._(status: 'error', error: error);
}

class SyncResult {
  final int uploaded;
  final int downloaded;
  final String? error;

  SyncResult(this.uploaded, this.downloaded, this.error);

  bool get isSuccess => error == null;
}

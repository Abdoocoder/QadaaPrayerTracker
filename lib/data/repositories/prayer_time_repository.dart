import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../services/prayer_time_service.dart';
import '../models/prayer_log_model.dart';
import '../models/prayer_times_model.dart';
import '../../domain/models/prayer_times.dart';

class PrayerTimeRepository {
  final DatabaseService _db;
  final PrayerTimeService _api;

  PrayerTimeRepository({required DatabaseService db, required PrayerTimeService api})
      : _db = db, _api = api;

  Future<PrayerTimes> getTimes(DateTime date) async {
    final database = await _db.database;
    final dateStr = PrayerLogModel.dateToStr(date);
    final rows = await database.query('prayer_times', where: 'date = ?', whereArgs: [dateStr]);
    if (rows.isNotEmpty) {
      return PrayerTimesModel.fromMap(rows.first).toDomain();
    }
    final model = await _api.fetchTimes(date);
    await database.insert('prayer_times', model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return model.toDomain();
  }

  Future<PrayerTimes> getTodayTimes() => getTimes(DateTime.now());
}

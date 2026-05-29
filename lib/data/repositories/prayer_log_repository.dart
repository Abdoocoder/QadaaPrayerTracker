import '../../services/database_service.dart';
import '../../domain/models/day_log.dart';
import '../../domain/models/prayer_name.dart';

class PrayerLogRepository {
  final DatabaseService _db;

  PrayerLogRepository({required DatabaseService db}) : _db = db;

  Future<void> ensureTodayLogs() => _db.ensureTodayLogs();
  Future<void> togglePrayer(DateTime date, PrayerName prayer) => _db.togglePrayer(date, prayer);
  Future<DayLog> getDayLog(DateTime date) => _db.getDayLog(date);
  Future<List<DayLog>> getWeekLogs() => _db.getWeekLogs();
  Future<Map<String, int>> getAggregates() => _db.getAggregates();
  Future<Map<String, int>> getPrayerDistribution() => _db.getPrayerDistribution();

  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('prayer_logs');
  }
}

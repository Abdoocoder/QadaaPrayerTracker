import '../models/qadaa_log_model.dart';
import '../../domain/models/qadaa_progress.dart';
import 'database_service.dart';

class QadaaService {
  final DatabaseService _db;

  QadaaService({required DatabaseService db}) : _db = db;

  static const _yearsKey = 'qadaa_years';

  int _years = 0;
  final _progress = <String, int>{};
  final _logs = <QadaaLogModel>[];

  static const prayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
  static const int daysPerYear = 365;

  Future<void> initFromDb() async {
    final yearsStr = await _db.getSetting(_yearsKey);
    if (yearsStr != null) {
      _years = int.tryParse(yearsStr) ?? 0;
      _refreshFromYears();
    }
  }

  int getYears() => _years;

  Future<void> initYears(int years) async {
    if (_years > 0) return;
    await setYears(years);
  }

  Future<void> setYears(int years) async {
    _years = years;
    await _db.setSetting(_yearsKey, years.toString());
    _refreshFromYears();
  }

  void _refreshFromYears() {
    _progress.clear();
    if (_years <= 0) return;
    for (final name in prayerNames) {
      _progress[name] = 0;
    }
  }

  Future<void> resetFromYears(int years) async {
    _logs.clear();
    _progress.clear();
    _years = years;
    await _db.setSetting(_yearsKey, years.toString());
    _refreshFromYears();
  }

  QadaaProgress getProgress(String prayerName) {
    final total = _years * daysPerYear;
    final completed = _progress[prayerName] ?? 0;
    return QadaaProgress(totalMissed: total, completed: completed);
  }

  List<QadaaProgress> getAllProgress() {
    return prayerNames.map((name) => getProgress(name)).toList();
  }

  void addLog(String prayerName, int count) {
    final current = _progress[prayerName] ?? 0;
    final total = _years * daysPerYear;
    final capped = (current + count).clamp(0, total);
    _progress[prayerName] = capped;

    _logs.insert(
      0,
      QadaaLogModel(
        prayerName: prayerName,
        count: count,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  List<QadaaLogModel> getLogs() => List.unmodifiable(_logs);

  int getGrandTotal() {
    return _progress.values.fold(0, (a, b) => a + b);
  }

  bool isLogAllowed(String prayerName) {
    final p = getProgress(prayerName);
    return p.remaining > 0;
  }
}

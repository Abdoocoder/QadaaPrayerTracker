import 'package:flutter/foundation.dart';
import '../../../../data/repositories/prayer_log_repository.dart';
import '../../../../data/repositories/prayer_time_repository.dart';
import '../../../../domain/models/day_log.dart';
import '../../../../domain/models/prayer_times.dart';

class HomeViewModel extends ChangeNotifier {
  final PrayerLogRepository _logRepo;
  final PrayerTimeRepository _timeRepo;

  DayLog? today;
  PrayerTimes? times;
  Map<String, int>? agg;
  bool loading = true;

  HomeViewModel({required PrayerLogRepository logRepo, required PrayerTimeRepository timeRepo})
      : _logRepo = logRepo, _timeRepo = timeRepo;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    await _logRepo.ensureTodayLogs();
    final results = await Future.wait([
      _logRepo.getDayLog(DateTime.now()),
      _logRepo.getAggregates(),
      _timeRepo.getTodayTimes(),
    ]);
    today = results[0] as DayLog;
    agg = results[1] as Map<String, int>;
    times = results[2] as PrayerTimes;
    loading = false;
    notifyListeners();
  }
}

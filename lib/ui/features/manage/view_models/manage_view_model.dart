import 'package:flutter/foundation.dart';
import '../../../../data/repositories/prayer_log_repository.dart';
import '../../../../data/repositories/prayer_time_repository.dart';
import '../../../../domain/models/day_log.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../../../domain/models/prayer_times.dart';

class ManageViewModel extends ChangeNotifier {
  final PrayerLogRepository _logRepo;
  final PrayerTimeRepository _timeRepo;

  int selectedDay = 0;
  DayLog? dayLog;
  PrayerTimes? times;
  bool loading = true;
  String? error;
  final dates = List.generate(7, (i) => DateTime.now().subtract(Duration(days: i)));

  ManageViewModel({required PrayerLogRepository logRepo, required PrayerTimeRepository timeRepo})
      : _logRepo = logRepo, _timeRepo = timeRepo;

  Future<void> loadDay() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final date = dates[selectedDay];
      await _logRepo.ensureTodayLogs();
      final results = await Future.wait([_logRepo.getDayLog(date), _timeRepo.getTimes(date)]);
      dayLog = results[0] as DayLog;
      times = results[1] as PrayerTimes;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(PrayerName prayer) async {
    try {
      await _logRepo.togglePrayer(dates[selectedDay], prayer);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return;
    }
    await loadDay();
  }

  void selectDay(int i) { selectedDay = i; loadDay(); }
}

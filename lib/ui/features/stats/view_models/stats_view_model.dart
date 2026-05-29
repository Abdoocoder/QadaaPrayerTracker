import 'package:flutter/foundation.dart';
import '../../../../data/repositories/prayer_log_repository.dart';
import '../../../../domain/models/day_log.dart';

class StatsViewModel extends ChangeNotifier {
  final PrayerLogRepository _logRepo;
  Map<String, int>? agg;
  Map<String, int>? dist;
  List<DayLog>? weekLogs;
  bool loading = true;
  String? error;

  StatsViewModel({required PrayerLogRepository logRepo}) : _logRepo = logRepo;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _logRepo.getAggregates(),
        _logRepo.getPrayerDistribution(),
        _logRepo.getWeekLogs(),
      ]);
      agg = results[0] as Map<String, int>;
      dist = results[1] as Map<String, int>;
      weekLogs = results[2] as List<DayLog>;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

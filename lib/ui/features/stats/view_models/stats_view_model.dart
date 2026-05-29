import 'package:flutter/foundation.dart';
import '../../../../data/repositories/prayer_log_repository.dart';
import '../../../../domain/models/day_log.dart';

class StatsViewModel extends ChangeNotifier {
  final PrayerLogRepository _logRepo;
  Map<String, int>? agg;
  Map<String, int>? dist;
  List<DayLog>? weekLogs;
  bool loading = true;

  StatsViewModel({required PrayerLogRepository logRepo}) : _logRepo = logRepo;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    final results = await Future.wait([
      _logRepo.getAggregates(),
      _logRepo.getPrayerDistribution(),
      _logRepo.getWeekLogs(),
    ]);
    agg = results[0] as Map<String, int>;
    dist = results[1] as Map<String, int>;
    weekLogs = results[2] as List<DayLog>;
    loading = false;
    notifyListeners();
  }
}

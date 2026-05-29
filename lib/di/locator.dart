import 'package:get_it/get_it.dart';
import '../data/repositories/prayer_log_repository.dart';
import '../data/repositories/prayer_time_repository.dart';
import '../services/database_service.dart';
import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';
import '../ui/features/home/view_models/home_view_model.dart';
import '../ui/features/manage/view_models/manage_view_model.dart';
import '../ui/features/stats/view_models/stats_view_model.dart';
import '../ui/features/settings/view_models/settings_view_model.dart';
import 'locale_notifier.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  sl.registerSingleton<DatabaseService>(DatabaseService());
  sl.registerLazySingleton<PrayerTimeService>(() => PrayerTimeService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  sl.registerLazySingleton<PrayerLogRepository>(() => PrayerLogRepository(db: sl()));
  sl.registerLazySingleton<PrayerTimeRepository>(() => PrayerTimeRepository(db: sl(), api: sl()));

  sl.registerLazySingleton<LocaleNotifier>(() => LocaleNotifier());

  sl.registerFactory<HomeViewModel>(() => HomeViewModel(logRepo: sl(), timeRepo: sl()));
  sl.registerFactory<ManageViewModel>(() => ManageViewModel(logRepo: sl(), timeRepo: sl()));
  sl.registerFactory<StatsViewModel>(() => StatsViewModel(logRepo: sl()));
  sl.registerFactory<SettingsViewModel>(() => SettingsViewModel(logRepo: sl(), notifService: sl(), db: sl(), prayerTimeService: sl(), localeNotifier: sl()));
}

# MVVM + Repository Architecture Refactor

## Goal
Restructure the Qadaa Prayer Tracker to follow the MVVM + Repository pattern as specified in the Flutter architecture guide. Introduce `get_it` for dependency injection, `ChangeNotifier` ViewModels, and a feature-based folder structure.

## Architecture Overview

```
lib/
├── main.dart                          # Entry point, calls di/setup()
├── app.dart                           # MaterialApp, no state
├── di/
│   └── locator.dart                   # get_it container setup
├── data/
│   ├── models/
│   │   ├── prayer_log_model.dart      # DB row -> PrayerLogModel (toMap/fromMap)
│   │   └── prayer_times_model.dart    # API JSON -> PrayerTimesModel (fromJson)
│   ├── repositories/
│   │   ├── prayer_log_repository.dart # CRUD logs, aggregates, distribution
│   │   └── prayer_time_repository.dart# Fetch + cache prayer times
│   └── services/
│       ├── database_service.dart      # sqflite init, raw queries
│       ├── prayer_time_service.dart   # aladhan.com API client
│       └── notification_service.dart  # flutter_local_notifications wrapper
├── domain/
│   └── models/
│       ├── prayer_name.dart           # enum (fajr/dhuhr/asr/maghrib/isha)
│       └── day_log.dart               # Date + Map<PrayerName, bool> aggregate
└── ui/
    ├── core/
    │   ├── theme/
    │   │   └── app_theme.dart         # (unchanged)
    │   └── widgets/
    │       ├── section_header.dart    # Reusable section header + action
    │       └── stat_card.dart         # Reusable stat card for bento grid
    ├── features/
    │   ├── onboarding/
    │   │   └── views/
    │   │       └── onboarding_screen.dart  # (minimal changes)
    │   ├── home/
    │   │   ├── view_models/
    │   │   │   └── home_view_model.dart
    │   │   └── views/
    │   │       ├── home_screen.dart        # Shell with NavigationBar
    │   │       ├── dashboard_tab.dart
    │   │       ├── greeting_header.dart
    │   │       ├── hero_stats_card.dart
    │   │       └── reminder_list.dart
    │   ├── manage/
    │   │   ├── view_models/
    │   │   │   └── manage_view_model.dart
    │   │   └── views/
    │   │       ├── prayer_management_screen.dart
    │   │       ├── date_strip.dart
    │   │       └── toggle_tile.dart
    │   ├── stats/
    │   │   ├── view_models/
    │   │   │   └── stats_view_model.dart
    │   │   └── views/
    │   │       ├── stats_screen.dart
    │   │       └── weekly_chart.dart
    │   ├── content/
    │   │   └── views/
    │   │       └── content_screen.dart    # (minimal changes)
    │   └── settings/
    │       ├── view_models/
    │       │   └── settings_view_model.dart
    │       └── views/
    │           └── settings_screen.dart
    └── l10n/
        ├── app_en.arb
        ├── app_ar.arb
        └── app_localizations.dart    # (generated)
```

## Data Layer

### Models

**`data/models/prayer_log_model.dart`** — Maps directly to `prayer_logs` SQLite table:
```dart
class PrayerLogModel {
  final int? id;
  final String date;
  final String prayerName;
  final bool completed;
  final String createdAt;

  Map<String, dynamic> toMap();
  factory PrayerLogModel.fromMap(Map<String, dynamic> map);
}
```

**`data/models/prayer_times_model.dart`** — Maps to aladhan.com API JSON response:
```dart
class PrayerTimesModel {
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String timezone;

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json, String date);
  Map<String, dynamic> toMap();
  PrayerTimes toDomain(); // -> domain model
}
```

### Services (unchanged logic, migrated to instance methods)

- **`DatabaseService`** — `sqflite` initialization, `settings` table CRUD, all raw SQL queries. Instance methods, registered in get_it as singleton.
- **`PrayerTimeService`** — aladhan.com API client. Instance methods.
- **`NotificationService`** — `flutter_local_notifications` init + scheduling. Instance methods.

All three remain in `data/services/` with their current implementation but become instance-based classes injected via constructor.

### Repositories

**`PrayerLogRepository`**:
```dart
class PrayerLogRepository {
  PrayerLogRepository({required DatabaseService db});
  
  Future<DayLog> getDayLog(DateTime date);
  Future<Map<String, int>> getAggregates();       // today/week/month/all
  Future<Map<String, int>> getPrayerDistribution();
  Future<List<DayLog>> getWeekLogs();
  Future<void> togglePrayer(DateTime date, PrayerName prayer);
  Future<void> ensureTodayLogs();
  Future<void> clearAll();
}
```

**`PrayerTimeRepository`**:
```dart
class PrayerTimeRepository {
  PrayerTimeRepository({
    required DatabaseService db,
    required PrayerTimeService api,
  });

  Future<PrayerTimes> getTodayTimes();   // tries cache, falls back to API
  Future<PrayerTimes> getTimes(DateTime date);
}
```

## Domain Models

```dart
// prayer_name.dart — enum with arName, rakah (unchanged)
// day_log.dart — date + Map<PrayerName, bool> + total/completed/percentage (unchanged)
// prayer_times.dart — 5 strings + timezone + forPrayer() getter (unchanged)
```

These are already clean domain models and move to `domain/models/`.

## UI Layer

### ViewModels (each extends ChangeNotifier)

**`HomeViewModel`**:
- State: `DayLog? today`, `PrayerTimes? times`, `Map<String, int>? agg`, `bool loading`
- Actions: `load()` → calls `PrayerLogRepository.getDayLog()` + `.getAggregates()` + `PrayerTimeRepository.getTodayTimes()`
- Exposes `Listenable` for `ListenableBuilder`

**`ManageViewModel`**:
- State: `int selectedDay`, `List<DateTime> dates`, `DayLog? dayLog`, `PrayerTimes? times`, `bool loading`
- Actions: `selectDay(int)`, `toggle(PrayerName)`, `loadDay()`

**`StatsViewModel`**:
- State: `Map<String, int>? agg`, `Map<String, int>? dist`, `List<DayLog>? weekLogs`, `bool loading`
- Actions: `load()`

**`SettingsViewModel`**:
- State: `bool notificationsEnabled`, `bool vibrationEnabled`, `bool loading`
- Actions: `loadSettings()`, `toggleNotifications(bool)`, `toggleVibration(bool)`, `resetData()`

### Views

Views are rebuilt using `ListenableBuilder` that listens to their ViewModel. Features with no async state (content screen) remain stateless with no ViewModel.

### Shared Widgets

- `SectionHeader` — title + optional action button (extracted from `_SectionHeader` in home_screen)
- `StatCard` — icon + value + label card (extracted from `_StatCard` in stats_screen)

Feature-specific private widgets (e.g. `_DateStrip`, `_ToggleTile`, `_PrayerCard`, `_GreetingHeader`) stay in their feature view files.

## Dependency Injection (`di/locator.dart`)

```dart
final sl = GetIt.instance;

void setup() {
  // Services
  sl.registerSingleton<DatabaseService>(DatabaseService());
  sl.registerLazySingleton<PrayerTimeService>(() => PrayerTimeService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // Repositories
  sl.registerLazySingleton<PrayerLogRepository>(() => PrayerLogRepository(db: sl()));
  sl.registerLazySingleton<PrayerTimeRepository>(() => PrayerTimeRepository(db: sl(), api: sl()));

  // ViewModels (not singletons — new instance per screen)
  sl.registerFactory<HomeViewModel>(() => HomeViewModel(
    logRepo: sl(),
    timeRepo: sl(),
  ));
  sl.registerFactory<ManageViewModel>(() => ManageViewModel(
    logRepo: sl(),
    timeRepo: sl(),
  ));
  sl.registerFactory<StatsViewModel>(() => StatsViewModel(
    logRepo: sl(),
  ));
  sl.registerFactory<SettingsViewModel>(() => SettingsViewModel(
    logRepo: sl(),
    notifService: sl(),
  ));
}
```

## Data Flow

```
User taps prayer toggle
    → ManageViewModel.toggle(prayer)
        → PrayerLogRepository.togglePrayer(date, prayer)
            → DatabaseService.update(INSERT OR IGNORE…)
        → [State updates, notifyListeners]
    → ListenableBuilder rebuilds UI
```

## Migration Path

1. Install `get_it` dependency
2. Create `di/locator.dart` with initial setup
3. Convert `DatabaseService`, `PrayerTimeService`, `NotificationService` from static classes to instance-based
4. Create `data/models/` (PrayerLogModel, PrayerTimesModel)
5. Create `data/repositories/` (PrayerLogRepository, PrayerTimeRepository)
6. Create `ui/core/widgets/` (SectionHeader, StatCard)
7. Move domain models to `domain/models/`
8. Create ViewModels for Home, Manage, Stats, Settings
9. Rewrite screens to use ViewModels + ListenableBuilder
10. Move files into feature folders
11. Update all imports
12. Verify flutter analyze + flutter test pass

## Scope Boundaries

- **In scope**: File restructuring, DI setup, Repository pattern, ViewModel pattern, get_it integration
- **Not in scope**: Adding new features, changing UI, changing business logic, adding tests (existing test must still pass)
- **Out of scope**: Replacing sqflite, adding code generation (freezed), state management beyond ChangeNotifier

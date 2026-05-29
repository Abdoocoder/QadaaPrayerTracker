# MVVM + Repository Architecture Refactor

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure Qadaa Prayer Tracker into MVVM + Repository pattern with `get_it` DI, feature-based folders, and ChangeNotifier ViewModels.

**Architecture:** Three layers (data/domain/ui). Services handle raw I/O, Repositories transform to domain models, ViewModels expose immutable state to Views. `get_it` container wires dependencies.

**Tech Stack:** Flutter, sqflite, get_it, ChangeNotifier

---

### Task 1: Add get_it dependency

**Files:** Modify `pubspec.yaml`

- [ ] **Add get_it to pubspec.yaml**

```yaml
dependencies:
  # ...
  get_it: ^8.0.0
```

- [ ] **Run `flutter pub get`**
- [ ] **Run `flutter analyze`**

---

### Task 2: Convert DatabaseService to instance-based

**Files:** Modify `lib/services/database_service.dart`

- [ ] **Remove `static` from all fields and methods**

Changes needed:
- `Database? _db` (instance field, was static)
- `Future<Database> get database` (instance getter, was static)
- `Future<Database> _init()` (instance method, was static)
- All public methods: remove `static` keyword
- Keep `PrayerLog.dateToStr` / `PrayerLog.strToDate` as static calls since they're pure functions on PrayerLogModel

- [ ] **Run `flutter analyze` — expect 0 errors**

---

### Task 3: Convert PrayerTimeService to instance-based + add fetchTimes

**Files:** Modify `lib/services/prayer_time_service.dart`

- [ ] **Remove `static` from all fields and methods**

The current implementation has static methods `getTodayTimes()` and `getTimes(DateTime)` that combine API fetching + DB caching. The API fetching will stay in this service, but DB caching moves to `PrayerTimeRepository` (Task 9).

- [ ] **Add public `fetchTimes(DateTime)` method**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/prayer_times_model.dart';  // adjust path later

class PrayerTimeService {
  static const _baseUrl = 'https://api.aladhan.com/v1/timingsByCity';
  static const _city = 'Amman';
  static const _country = 'Jordan';
  static const _method = 3;

  Future<PrayerTimesModel> fetchTimes(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse('$_baseUrl/$dateStr?city=$_city&country=$_country&method=$_method');
    final response = await http.get(uri);
    if (response.statusCode != 200) throw Exception('API error: ${response.statusCode}');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PrayerTimesModel.fromJson(json['data'] as Map<String, dynamic>, dateStr);
  }
}
```

- [ ] **Remove old static DB-caching methods** (`getTodayTimes`, `getTimes` with DB logic)
- [ ] **Run `flutter analyze`**

---

### Task 4: Convert NotificationService to instance-based

**Files:** Modify `lib/services/notification_service.dart`

- [ ] **Remove `static` from all fields and methods**

```dart
class NotificationService {
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  Future<void> init() async { /* same init logic */ }
  Future<void> schedulePrayerReminders(PrayerTimes times) async { /* same, but accepts param */ }
  Future<void> cancelAll() async { /* same */ }
}
```

- [ ] **Change `schedulePrayerReminders` to accept `PrayerTimes` parameter instead of calling static `PrayerTimeService.getTodayTimes()`**

- [ ] **Run `flutter analyze`**

---

### Task 5: Create data/models directory with PrayerLogModel

**Files:** Create `lib/data/models/prayer_log_model.dart`

- [ ] **Create PrayerLogModel class**

```dart
class PrayerLogModel {
  final int? id;
  final String date;
  final String prayerName;
  final bool completed;
  final String createdAt;

  PrayerLogModel({this.id, required this.date, required this.prayerName, required this.completed, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id, 'date': date, 'prayer_name': prayerName,
    'completed': completed ? 1 : 0, 'created_at': createdAt,
  };

  factory PrayerLogModel.fromMap(Map<String, dynamic> map) => PrayerLogModel(
    id: map['id'] as int?,
    date: map['date'] as String,
    prayerName: map['prayer_name'] as String,
    completed: (map['completed'] as int) == 1,
    createdAt: map['created_at'] as String,
  );

  static String dateToStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static DateTime strToDate(String s) {
    final parts = s.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
```

- [ ] **Run `flutter analyze`**

---

### Task 6: Create PrayerTimesModel

**Files:** Create `lib/data/models/prayer_times_model.dart`

- [ ] **Create PrayerTimesModel class**

```dart
import '../../domain/models/prayer_times.dart';

class PrayerTimesModel {
  final String date;
  final String fajr, sunrise, dhuhr, asr, maghrib, isha;
  final String timezone;

  PrayerTimesModel({
    required this.date, required this.fajr, required this.sunrise,
    required this.dhuhr, required this.asr, required this.maghrib,
    required this.isha, required this.timezone,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json, String date) => PrayerTimesModel(
    date: date,
    fajr: json['timings']['Fajr'] as String,
    sunrise: json['timings']['Sunrise'] as String,
    dhuhr: json['timings']['Dhuhr'] as String,
    asr: json['timings']['Asr'] as String,
    maghrib: json['timings']['Maghrib'] as String,
    isha: json['timings']['Isha'] as String,
    timezone: json['meta']['timezone'] as String,
  );

  Map<String, dynamic> toMap() => {
    'date': date, 'fajr': fajr, 'sunrise': sunrise, 'dhuhr': dhuhr,
    'asr': asr, 'maghrib': maghrib, 'isha': isha, 'timezone': timezone,
  };

  factory PrayerTimesModel.fromMap(Map<String, dynamic> map) => PrayerTimesModel(
    date: map['date'] as String, fajr: map['fajr'] as String,
    sunrise: map['sunrise'] as String, dhuhr: map['dhuhr'] as String,
    asr: map['asr'] as String, maghrib: map['maghrib'] as String,
    isha: map['isha'] as String, timezone: map['timezone'] as String,
  );

  PrayerTimes toDomain() => PrayerTimes(
    fajr: fajr, sunrise: sunrise, dhuhr: dhuhr, asr: asr,
    maghrib: maghrib, isha: isha, timezone: timezone,
  );
}
```

- [ ] **Run `flutter analyze`**

---

### Task 7: Move domain models

**Files:**
- Move `lib/models/prayer.dart` → `lib/domain/models/prayer_name.dart`
- Move `lib/models/day_log.dart` → `lib/domain/models/day_log.dart`
- Move `lib/models/prayer_times.dart` → `lib/domain/models/prayer_times.dart`
- Delete `lib/models/prayer_log.dart` (replaced by PrayerLogModel)

- [ ] **Create `lib/domain/models/` directory**
- [ ] **Move each file, updating imports to use relative `package:` or relative paths**

`prayer_name.dart` — add `const allPrayers = PrayerName.values;` at bottom

`day_log.dart` — update import from `'prayer.dart'` to `'prayer_name.dart'`

`prayer_times.dart` — no import changes needed

- [ ] **Delete `lib/models/prayer_log.dart`** (all callers now use `PrayerLogModel`)

- [ ] **Run `flutter analyze`** and fix any import path errors

---

### Task 8: Create PrayerLogRepository

**Files:** Create `lib/data/repositories/prayer_log_repository.dart`

- [ ] **Create repository**

```dart
import '../services/database_service.dart';
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
```

- [ ] **Run `flutter analyze`**

---

### Task 9: Create PrayerTimeRepository

**Files:** Create `lib/data/repositories/prayer_time_repository.dart`

- [ ] **Create repository**

```dart
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
```

- [ ] **Run `flutter analyze`**

---

### Task 10: Create shared core widgets

**Files:**
- Create `lib/ui/core/widgets/section_header.dart`
- Create `lib/ui/core/widgets/stat_card.dart`

- [ ] **Create SectionHeader**

Extract from `_SectionHeader` in home_screen.dart — title + optional action button:

```dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurface, letterSpacing: -0.2)),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceXs), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(action!, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.secondary)),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Create StatCard**

Extract from `_StatCard` in stats_screen.dart:

```dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const StatCard({super.key, required this.label, required this.value, required this.sub, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - AppTheme.spaceLg * 2 - AppTheme.spaceMd) / 2;
    return SizedBox(width: w, child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppTheme.radiusSm)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: AppTheme.spaceMd),
          Text(value, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 26, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w400, color: AppTheme.outline)),
        ]),
      ),
    ));
  }
}
```

- [ ] **Run `flutter analyze`**

---

### Task 11: Create HomeViewModel

**Files:** Create `lib/ui/features/home/view_models/home_view_model.dart`

- [ ] **Create HomeViewModel**

```dart
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
```

- [ ] **Run `flutter analyze`**

---

### Task 12: Create ManageViewModel

**Files:** Create `lib/ui/features/manage/view_models/manage_view_model.dart`

- [ ] **Create ManageViewModel**

```dart
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
  final dates = List.generate(7, (i) => DateTime.now().subtract(Duration(days: i)));

  ManageViewModel({required PrayerLogRepository logRepo, required PrayerTimeRepository timeRepo})
      : _logRepo = logRepo, _timeRepo = timeRepo;

  Future<void> loadDay() async {
    loading = true;
    notifyListeners();
    final date = dates[selectedDay];
    await _logRepo.ensureTodayLogs();
    final results = await Future.wait([_logRepo.getDayLog(date), _timeRepo.getTimes(date)]);
    dayLog = results[0] as DayLog;
    times = results[1] as PrayerTimes;
    loading = false;
    notifyListeners();
  }

  Future<void> toggle(PrayerName prayer) async {
    await _logRepo.togglePrayer(dates[selectedDay], prayer);
    await loadDay();
  }

  void selectDay(int i) { selectedDay = i; loadDay(); }
}
```

- [ ] **Run `flutter analyze`**

---

### Task 13: Create StatsViewModel

**Files:** Create `lib/ui/features/stats/view_models/stats_view_model.dart`

- [ ] **Create StatsViewModel**

```dart
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
```

- [ ] **Run `flutter analyze`**

---

### Task 14: Create SettingsViewModel

**Files:** Create `lib/ui/features/settings/view_models/settings_view_model.dart`

- [ ] **Create SettingsViewModel**

```dart
import 'package:flutter/foundation.dart';
import '../../../../data/repositories/prayer_log_repository.dart';
import '../../../../services/database_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/prayer_time_service.dart';
import '../../../../data/models/prayer_times_model.dart';

class SettingsViewModel extends ChangeNotifier {
  final PrayerLogRepository _logRepo;
  final NotificationService _notifService;
  final DatabaseService _db;
  final PrayerTimeService _prayerTimeService;

  bool notificationsEnabled = false;
  bool vibrationEnabled = true;
  bool loading = true;

  SettingsViewModel({
    required PrayerLogRepository logRepo,
    required NotificationService notifService,
    required DatabaseService db,
    required PrayerTimeService prayerTimeService,
  }) : _logRepo = logRepo, _notifService = notifService, _db = db, _prayerTimeService = prayerTimeService;

  Future<void> loadSettings() async {
    final notif = await _db.getSetting('notifications_enabled');
    final vibrate = await _db.getSetting('vibration_enabled');
    notificationsEnabled = notif == 'true';
    vibrationEnabled = vibrate != 'false';
    loading = false;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool v) async {
    notificationsEnabled = v;
    notifyListeners();
    await _db.setSetting('notifications_enabled', v ? 'true' : 'false');
    if (v) {
      final model = await _prayerTimeService.fetchTimes(DateTime.now());
      await _notifService.schedulePrayerReminders(model.toDomain());
    } else {
      await _notifService.cancelAll();
    }
  }

  Future<void> toggleVibration(bool v) async {
    vibrationEnabled = v;
    notifyListeners();
    await _db.setSetting('vibration_enabled', v ? 'true' : 'false');
  }

  Future<void> resetData() async {
    await _logRepo.clearAll();
    await _notifService.cancelAll();
    await _db.setSetting('notifications_enabled', 'false');
    notificationsEnabled = false;
    notifyListeners();
  }
}
```

- [ ] **Run `flutter analyze`**

---

### Task 15: Create DI locator

**Files:** Create `lib/di/locator.dart`

- [ ] **Create locator with all registrations**

```dart
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

final sl = GetIt.instance;

Future<void> setupDi() async {
  // Services
  sl.registerSingleton<DatabaseService>(DatabaseService());
  sl.registerLazySingleton<PrayerTimeService>(() => PrayerTimeService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // Repositories
  sl.registerLazySingleton<PrayerLogRepository>(() => PrayerLogRepository(db: sl()));
  sl.registerLazySingleton<PrayerTimeRepository>(() => PrayerTimeRepository(db: sl(), api: sl()));

  // ViewModels
  sl.registerFactory<HomeViewModel>(() => HomeViewModel(logRepo: sl(), timeRepo: sl()));
  sl.registerFactory<ManageViewModel>(() => ManageViewModel(logRepo: sl(), timeRepo: sl()));
  sl.registerFactory<StatsViewModel>(() => StatsViewModel(logRepo: sl()));
  sl.registerFactory<SettingsViewModel>(() => SettingsViewModel(logRepo: sl(), notifService: sl(), db: sl(), prayerTimeService: sl()));
}
```

- [ ] **Run `flutter analyze`**

---

### Task 16: Rewrite Home screen

**Files:**
- Create `lib/ui/features/home/views/home_screen.dart`
- Create `lib/ui/features/home/views/dashboard_tab.dart`
- Create `lib/ui/features/home/views/greeting_header.dart`
- Create `lib/ui/features/home/views/hero_stats_card.dart`
- Create `lib/ui/features/home/views/reminder_list.dart`

- [ ] **Create home_screen.dart** — NavigationBar shell with 4 tabs, imports the other screens

```dart
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../manage/views/prayer_management_screen.dart';
import '../../stats/views/stats_screen.dart';
import '../../content/views/content_screen.dart';
import '../../settings/views/settings_screen.dart';
import 'dashboard_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _pages = const [DashboardTab(), StatsScreen(), ContentScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(duration: AppTheme.durationBase, child: _pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'الإحصائيات'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'المحتوى'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
```

- [ ] **Create dashboard_tab.dart** — ListenableBuilder + HomeViewModel

```dart
import 'package:flutter/material.dart';
import '../../../../di/locator.dart';
import '../../../../theme/app_theme.dart';
import '../../../core/widgets/section_header.dart';
import '../../manage/views/prayer_management_screen.dart';
import '../view_models/home_view_model.dart';
import 'greeting_header.dart';
import 'hero_stats_card.dart';
import 'reminder_list.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final vm = sl<HomeViewModel>();

  @override
  void initState() { super.initState(); vm.load(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: vm, builder: (context, _) {
      if (vm.loading) return const SafeArea(child: Center(child: CircularProgressIndicator()));
      return SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GreetingHeader(),
          const SizedBox(height: AppTheme.spaceXl),
          HeroStatsCard(today: vm.today!, agg: vm.agg!),
          const SizedBox(height: AppTheme.spaceXxl),
          SectionHeader(title: 'صلوات اليوم', action: 'إدارة', onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerManagementScreen()))),
          const SizedBox(height: AppTheme.spaceLg),
          _PrayerGrid(today: vm.today!, times: vm.times!),
          const SizedBox(height: AppTheme.spaceXxl),
          SectionHeader(title: 'تذكيرات', action: 'عرض الكل'),
          const SizedBox(height: AppTheme.spaceLg),
          ReminderList(today: vm.today!),
          const SizedBox(height: AppTheme.spaceXxl),
        ]),
      ));
    });
  }
}
```

- [ ] **Create greeting_header.dart** — Same visual as current `_GreetingHeader`, now public
- [ ] **Create hero_stats_card.dart** — Same visual as current `_HeroStatsCard` + `_HeroStat`, now public; include `_PrayerGrid` and `_PrayerCard` inline
- [ ] **Create reminder_list.dart** — Same as current `_ReminderList`, now public

- [ ] **Run `flutter analyze`**

---

### Task 17: Rewrite Prayer Management screen

**Files:**
- Create `lib/ui/features/manage/views/prayer_management_screen.dart`
- Create `lib/ui/features/manage/views/date_strip.dart`
- Create `lib/ui/features/manage/views/toggle_tile.dart`

- [ ] **Create prayer_management_screen.dart**

```dart
import 'package:flutter/material.dart';
import '../../../../di/locator.dart';
import '../../../../theme/app_theme.dart';
import '../view_models/manage_view_model.dart';
import 'date_strip.dart';
import 'toggle_tile.dart';

class PrayerManagementScreen extends StatefulWidget {
  const PrayerManagementScreen({super.key});
  @override
  State<PrayerManagementScreen> createState() => _PrayerManagementScreenState();
}

class _PrayerManagementScreenState extends State<PrayerManagementScreen> {
  final vm = sl<ManageViewModel>();

  @override
  void initState() { super.initState(); vm.loadDay(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: vm, builder: (context, _) {
      return Scaffold(
        appBar: AppBar(title: const Text('إدارة الصلوات', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 19, fontWeight: FontWeight.w700))),
        body: ListView(padding: const EdgeInsets.all(AppTheme.spaceLg), children: [
          DateStrip(selected: vm.selectedDay, dates: vm.dates, onSelect: (i) => vm.selectDay(i)),
          const SizedBox(height: AppTheme.spaceXl),
          Text('اختر الصلوات التي قضيتها', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8))),
          const SizedBox(height: AppTheme.spaceLg),
          if (vm.loading) const Center(child: Padding(padding: EdgeInsets.all(AppTheme.spaceXxl), child: CircularProgressIndicator()))
          else ...allPrayers.map((p) => ToggleTile(
            key: ValueKey('prayer_${vm.selectedDay}_${p.name}'),
            name: p.arName, time: vm.times?.forPrayer(p) ?? '--:--',
            completed: vm.dayLog?.isCompleted(p) ?? false,
            onToggle: () => vm.toggle(p),
          )),
          const SizedBox(height: AppTheme.spaceXxl),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('حفظ'))),
          const SizedBox(height: AppTheme.spaceXl),
        ]),
      );
    });
  }
}
```

- [ ] **Create date_strip.dart** — horizontal scroll of day labels (copied from current `_DateStrip`)
- [ ] **Create toggle_tile.dart** — animated check circle + prayer name + time (copied from current `_ToggleTile`)

- [ ] **Run `flutter analyze`**

---

### Task 18: Rewrite Stats screen

**Files:**
- Create `lib/ui/features/stats/views/stats_screen.dart`
- Create `lib/ui/features/stats/views/weekly_chart.dart`

- [ ] **Create stats_screen.dart**

```dart
import 'package:flutter/material.dart';
import '../../../../di/locator.dart';
import '../../../../theme/app_theme.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../../core/widgets/stat_card.dart';
import '../view_models/stats_view_model.dart';
import 'weekly_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final vm = sl<StatsViewModel>();

  @override
  void initState() { super.initState(); vm.load(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: vm, builder: (context, _) {
      if (vm.loading) return const SafeArea(child: Center(child: CircularProgressIndicator()));
      return SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.only(left: AppTheme.spaceSm, right: AppTheme.spaceSm, top: AppTheme.spaceMd), child: Text('الإحصائيات', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.onSurface, letterSpacing: -0.3))),
          const SizedBox(height: AppTheme.spaceXl),
          Wrap(spacing: AppTheme.spaceMd, runSpacing: AppTheme.spaceMd, children: [
            StatCard(label: 'هذا الأسبوع', value: '${vm.agg!['week_done']}', sub: 'صلاة مقضية', icon: Icons.date_range_rounded, color: AppTheme.primary),
            StatCard(label: 'هذا الشهر', value: '${vm.agg!['month_done']}', sub: 'صلاة مقضية', icon: Icons.calendar_month_rounded, color: AppTheme.secondary),
            StatCard(label: 'الإجمالي', value: '${vm.agg!['all_done']}', sub: 'صلاة مقضية', icon: Icons.assignment_turned_in_rounded, color: AppTheme.tertiary),
            StatCard(label: 'معدل الإنجاز', value: _pct(vm.agg!['all_done']!, vm.agg!['all_total']!), sub: 'نسبة التقدم', icon: Icons.trending_up_rounded, color: AppTheme.primaryFixedDim),
          ]),
          const SizedBox(height: AppTheme.spaceXxl),
          const Padding(padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceSm), child: Text('توزيع الصلوات', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurface, letterSpacing: -0.2))),
          const SizedBox(height: AppTheme.spaceLg),
          _DistributionSection(dist: vm.dist!),
          const SizedBox(height: AppTheme.spaceXxl),
          const Padding(padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceSm), child: Text('آخر ٧ أيام', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurface, letterSpacing: -0.2))),
          const SizedBox(height: AppTheme.spaceLg),
          WeeklyChart(weekLogs: vm.weekLogs!),
        ]),
      ));
    });
  }

  String _pct(int done, int total) => total == 0 ? '0%' : '${(done / total * 100).round()}%';
}
```

- [ ] **Create weekly_chart.dart** — Same as current `_WeeklyChart`, now public
- [ ] **Include `_DistributionSection`** in the stats_screen.dart file

- [ ] **Run `flutter analyze`**

---

### Task 19: Move Content and Settings screens

**Files:**
- Create `lib/ui/features/content/views/content_screen.dart`
- Create `lib/ui/features/settings/views/settings_screen.dart`

- [ ] **Move content_screen.dart** — same content, just relocate
- [ ] **Create settings_screen.dart** — uses SettingsViewModel

```dart
// Key pattern: wraps in ListenableBuilder with sl<SettingsViewModel>()
// Same visual layout as current but reads from vm state and calls vm methods
```

- [ ] **Run `flutter analyze`**

---

### Task 20: Move Onboarding screen

**Files:**
- Create `lib/ui/features/onboarding/views/onboarding_screen.dart`

- [ ] **Move onboarding_screen.dart** — same content, just relocate

---

### Task 21: Update app.dart and main.dart

**Files:** Modify `lib/main.dart`, `lib/app.dart`

- [ ] **Update main.dart**

```dart
import 'package:flutter/material.dart';
import 'di/locator.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();
  runApp(const QadaaApp());
}
```

- [ ] **Update app.dart import** — change `import 'screens/onboarding_screen.dart';` to `import 'ui/features/onboarding/views/onboarding_screen.dart';`

---

### Task 22: Remove old files

**Files:** Delete old structure

- [ ] **Delete** `lib/models/` directory (all files moved to `lib/domain/models/` or replaced by `lib/data/models/`)
- [ ] **Delete** `lib/screens/` directory (all files moved to `lib/ui/features/*/views/`)
- [ ] **Run `flutter analyze`** — fix any remaining import errors

---

### Task 23: Final verification

- [ ] **Run `flutter analyze`** — 0 issues
- [ ] **Run `flutter test`** — 1/1 passes

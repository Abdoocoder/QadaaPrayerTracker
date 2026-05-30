import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../data/repositories/prayer_log_repository.dart';
import '../../../../services/database_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/prayer_time_service.dart';
import '../../../../services/qadaa_service.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/supabase_sync_service.dart';
import '../../../../di/locale_notifier.dart';
import '../../../../di/theme_notifier.dart';

class SettingsViewModel extends ChangeNotifier {
  final PrayerLogRepository _logRepo;
  final NotificationService _notifService;
  final DatabaseService _db;
  final PrayerTimeService _prayerTimeService;
  final QadaaService _qadaaService;
  final LocaleNotifier _localeNotifier;
  final ThemeNotifier _themeNotifier;
  final SupabaseService _supabase;
  final SupabaseSyncService _syncService;

  bool notificationsEnabled = false;
  bool vibrationEnabled = true;
  bool loading = true;
  String? error;

  String _city = 'Amman';
  String _country = 'Jordan';
  int _method = 3;
  String _localeCode = 'ar';
  ThemeMode _themeMode = ThemeMode.light;

  String get city => _city;
  String get country => _country;
  int get method => _method;
  String get localeCode => _localeCode;
  ThemeMode get themeMode => _themeMode;
  String get methodName => PrayerTimeService.calculationMethods[_method] ?? 'Muslim World League';
  String get locationDisplay => '$_city، $_country';
  int get qadaaYears => _qadaaService.getYears();

  bool get isSignedIn => _supabase.isSignedIn;
  String? get userEmail => _supabase.userEmail;

  SettingsViewModel({
    required PrayerLogRepository logRepo,
    required NotificationService notifService,
    required DatabaseService db,
    required PrayerTimeService prayerTimeService,
    required QadaaService qadaaService,
    required SupabaseService supabase,
    required SupabaseSyncService syncService,
    required LocaleNotifier localeNotifier,
    required ThemeNotifier themeNotifier,
  }) : _logRepo = logRepo, _notifService = notifService, _db = db,
       _prayerTimeService = prayerTimeService, _qadaaService = qadaaService,
       _supabase = supabase, _syncService = syncService,
       _localeNotifier = localeNotifier, _themeNotifier = themeNotifier {
    _supabase.addAuthListener(notifyListeners);
  }

  @override
  void dispose() {
    _supabase.removeAuthListener(notifyListeners);
    super.dispose();
  }

  Future<void> loadSettings() async {
    error = null;
    try {
      final notif = await _db.getSetting('notifications_enabled');
      final vibrate = await _db.getSetting('vibration_enabled');
      final savedCity = await _db.getSetting('city');
      final savedCountry = await _db.getSetting('country');
      final savedMethod = await _db.getSetting('method');
      final savedLocale = await _db.getSetting('locale');
      final savedTheme = await _db.getSetting('theme_mode');

      notificationsEnabled = notif == 'true';
      vibrationEnabled = vibrate != 'false';
      _city = savedCity ?? 'Amman';
      _country = savedCountry ?? 'Jordan';
      _method = int.tryParse(savedMethod ?? '') ?? 3;
      _localeCode = savedLocale ?? 'ar';
      _themeMode = _parseThemeMode(savedTheme ?? 'light');

      _prayerTimeService.city = _city;
      _prayerTimeService.country = _country;
      _prayerTimeService.method = _method;
      _localeNotifier.setLocale(Locale(_localeCode));
      _themeNotifier.setThemeMode(_themeMode);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'dark': return ThemeMode.dark;
      case 'system': return ThemeMode.system;
      default: return ThemeMode.light;
    }
  }

  Future<void> toggleNotifications(bool v) async {
    try {
      notificationsEnabled = v;
      notifyListeners();
      await _db.setSetting('notifications_enabled', v ? 'true' : 'false');
      if (v) {
        final model = await _prayerTimeService.fetchTimes(DateTime.now());
        await _notifService.schedulePrayerReminders(model.toDomain());
      } else {
        await _notifService.cancelAll();
      }
    } catch (e) {
      notificationsEnabled = !v;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleVibration(bool v) async {
    vibrationEnabled = v;
    notifyListeners();
    await _db.setSetting('vibration_enabled', v ? 'true' : 'false');
  }

  Future<void> setLocale(String code) async {
    try {
      _localeCode = code;
      await _db.setSetting('locale', code);
      _localeNotifier.setLocale(Locale(code));
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      await _db.setSetting('theme_mode', mode.name);
      _themeNotifier.setThemeMode(mode);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setLocation(String newCity, String newCountry) async {
    try {
      _city = newCity;
      _country = newCountry;
      _prayerTimeService.city = newCity;
      _prayerTimeService.country = newCountry;
      await _db.setSetting('city', newCity);
      await _db.setSetting('country', newCountry);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setMethod(int newMethod) async {
    try {
      _method = newMethod;
      _prayerTimeService.method = newMethod;
      await _db.setSetting('method', newMethod.toString());
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setQadaaYears(int years) async {
    try {
      await _qadaaService.resetFromYears(years);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<String> exportCsv() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT date, prayer_name, completed, created_at FROM prayer_logs ORDER BY date DESC, prayer_name',
    );

    final buffer = StringBuffer();
    buffer.writeln('date,prayer_name,completed,created_at');
    for (final row in rows) {
      buffer.writeln(
        '${row['date']},${row['prayer_name']},${row['completed']},${row['created_at']}',
      );
    }
    return buffer.toString();
  }

  Future<String> exportJson() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT date, prayer_name, completed, created_at FROM prayer_logs ORDER BY date DESC, prayer_name',
    );
    return const JsonEncoder.withIndent('  ').convert(rows);
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _supabase.signIn(email, password);
      await _syncService.syncAll();
      notifyListeners();
      return null;
    } catch (e) {
      return SupabaseService.friendlyError(e);
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _supabase.signUp(email, password);
      notifyListeners();
      return null;
    } catch (e) {
      return SupabaseService.friendlyError(e);
    }
  }

  Future<String?> signOut() async {
    try {
      await _supabase.signOut();
      notifyListeners();
      return null;
    } catch (e) {
      return SupabaseService.friendlyError(e);
    }
  }

  Future<void> resetData() async {
    try {
      await _logRepo.clearAll();
      await _notifService.cancelAll();
      await _db.setSetting('notifications_enabled', 'false');
      notificationsEnabled = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

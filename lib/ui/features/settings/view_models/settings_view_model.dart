import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../data/repositories/prayer_log_repository.dart';
import '../../../../services/database_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/prayer_time_service.dart';
import '../../../../di/locale_notifier.dart';

class SettingsViewModel extends ChangeNotifier {
  final PrayerLogRepository _logRepo;
  final NotificationService _notifService;
  final DatabaseService _db;
  final PrayerTimeService _prayerTimeService;
  final LocaleNotifier _localeNotifier;

  bool notificationsEnabled = false;
  bool vibrationEnabled = true;
  bool loading = true;

  String _city = 'Amman';
  String _country = 'Jordan';
  int _method = 3;
  String _localeCode = 'ar';

  String get city => _city;
  String get country => _country;
  int get method => _method;
  String get localeCode => _localeCode;
  String get methodName => PrayerTimeService.calculationMethods[_method] ?? 'Muslim World League';
  String get locationDisplay => '$_city، $_country';

  SettingsViewModel({
    required PrayerLogRepository logRepo,
    required NotificationService notifService,
    required DatabaseService db,
    required PrayerTimeService prayerTimeService,
    required LocaleNotifier localeNotifier,
  }) : _logRepo = logRepo, _notifService = notifService, _db = db,
       _prayerTimeService = prayerTimeService, _localeNotifier = localeNotifier;

  Future<void> loadSettings() async {
    final notif = await _db.getSetting('notifications_enabled');
    final vibrate = await _db.getSetting('vibration_enabled');
    final savedCity = await _db.getSetting('city');
    final savedCountry = await _db.getSetting('country');
    final savedMethod = await _db.getSetting('method');
    final savedLocale = await _db.getSetting('locale');

    notificationsEnabled = notif == 'true';
    vibrationEnabled = vibrate != 'false';
    _city = savedCity ?? 'Amman';
    _country = savedCountry ?? 'Jordan';
    _method = int.tryParse(savedMethod ?? '') ?? 3;
    _localeCode = savedLocale ?? 'ar';

    _prayerTimeService.city = _city;
    _prayerTimeService.country = _country;
    _prayerTimeService.method = _method;
    _localeNotifier.setLocale(Locale(_localeCode));

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

  Future<void> setLocale(String code) async {
    _localeCode = code;
    await _db.setSetting('locale', code);
    _localeNotifier.setLocale(Locale(code));
    notifyListeners();
  }

  Future<void> setLocation(String newCity, String newCountry) async {
    _city = newCity;
    _country = newCountry;
    _prayerTimeService.city = newCity;
    _prayerTimeService.country = newCountry;
    await _db.setSetting('city', newCity);
    await _db.setSetting('country', newCountry);
    notifyListeners();
  }

  Future<void> setMethod(int newMethod) async {
    _method = newMethod;
    _prayerTimeService.method = newMethod;
    await _db.setSetting('method', newMethod.toString());
    notifyListeners();
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

  Future<void> resetData() async {
    await _logRepo.clearAll();
    await _notifService.cancelAll();
    await _db.setSetting('notifications_enabled', 'false');
    notificationsEnabled = false;
    notifyListeners();
  }
}

import '../../domain/models/prayer_times.dart';

class PrayerTimesModel {
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String timezone;

  PrayerTimesModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.timezone,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json, String date) {
    final timings = json['timings'] as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;

    String clean(String raw) {
      final space = raw.indexOf(' ');
      return space > 0 ? raw.substring(0, space) : raw;
    }

    return PrayerTimesModel(
      date: date,
      fajr: clean(timings['Fajr'] as String),
      sunrise: clean(timings['Sunrise'] as String),
      dhuhr: clean(timings['Dhuhr'] as String),
      asr: clean(timings['Asr'] as String),
      maghrib: clean(timings['Maghrib'] as String),
      isha: clean(timings['Isha'] as String),
      timezone: meta['timezone'] as String? ?? 'Asia/Amman',
    );
  }

  Map<String, dynamic> toMap() => {
    'date': date,
    'fajr': fajr,
    'sunrise': sunrise,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
    'timezone': timezone,
  };

  factory PrayerTimesModel.fromMap(Map<String, dynamic> map) => PrayerTimesModel(
    date: map['date'] as String,
    fajr: map['fajr'] as String,
    sunrise: map['sunrise'] as String,
    dhuhr: map['dhuhr'] as String,
    asr: map['asr'] as String,
    maghrib: map['maghrib'] as String,
    isha: map['isha'] as String,
    timezone: (map['timezone'] as String?) ?? 'Asia/Amman',
  );

  PrayerTimes toDomain() => PrayerTimes(
    fajr: fajr,
    sunrise: sunrise,
    dhuhr: dhuhr,
    asr: asr,
    maghrib: maghrib,
    isha: isha,
    timezone: timezone,
  );
}

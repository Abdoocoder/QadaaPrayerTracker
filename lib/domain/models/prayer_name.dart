enum PrayerName {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get arName {
    switch (this) {
      case PrayerName.fajr:
        return 'الفجر';
      case PrayerName.dhuhr:
        return 'الظهر';
      case PrayerName.asr:
        return 'العصر';
      case PrayerName.maghrib:
        return 'المغرب';
      case PrayerName.isha:
        return 'العشاء';
    }
  }

  int get rakah {
    switch (this) {
      case PrayerName.fajr:
        return 2;
      case PrayerName.dhuhr:
        return 4;
      case PrayerName.asr:
        return 4;
      case PrayerName.maghrib:
        return 3;
      case PrayerName.isha:
        return 4;
    }
  }
}

const allPrayers = PrayerName.values;

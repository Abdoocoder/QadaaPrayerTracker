<div align="center">
  <img src="https://img.icons8.com/color/96/000000/mosque.png" alt="Qadaa Prayer Tracker" width="80"/>
  <h1 align="center">Qadaa Prayer Tracker</h1>
  <p align="center">Track and make up missed Islamic prayers with ease</p>
  <p align="center">
    <a href="#features">Features</a> •
    <a href="#screenshots">Screenshots</a> •
    <a href="#getting-started">Getting Started</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#tech-stack">Tech Stack</a>
  </p>
</div>

## Overview

Qadaa Prayer Tracker helps Muslims track, manage, and make up missed prayers (صلوات قادئة). Record daily prayers, monitor progress with statistics, configure prayer times based on your location and calculation method, and receive reminders — all with a clean, modern interface in Arabic and English.

## Features

- **Prayer Tracking** — Log completed make-up prayers for each of the 5 daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha)
- **Dashboard** — Daily overview with completion status, streak tracking, and quick-access prayer grid
- **Prayer Management** — Browse the past 7 days and toggle prayer completion with animated feedback
- **Statistics** — Weekly, monthly, and all-time aggregates with prayer distribution charts
- **Smart Reminders** — Local push notifications scheduled at prayer times to remind you of make-up prayers
- **Onboarding** — 3-page introduction with smooth animations
- **Islamic Content** — Curated supplications, verses, hadith, and tips for making up prayers
- **Dynamic Location** — Configure city and country for accurate prayer time calculation
- **Calculation Methods** — 22 supported methods (Muslim World League, Umm Al-Qura, ISNA, etc.)
- **Bilingual** — Full Arabic and English localization, switchable in settings
- **Data Export** — Export prayer logs as CSV or JSON
- **Dark Theme Ready** — Material Design 3 color system, designed for future dark mode

## Screenshots

| Onboarding | Dashboard | Prayer Management | Stats | Settings |
|:---:|:---:|:---:|:---:|:---:|
| 3-page intro | Daily overview | 7-day history | Charts & aggregates | Preferences |

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.5
- Dart SDK ^3.11.5

### Installation

```bash
# Clone the repository
git clone https://github.com/Abdoocoder/QadaaPrayerTracker.git

# Navigate to the project
cd QadaaPrayerTracker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

## Architecture

The app follows the **MVVM + Repository** pattern with feature-based folder organization:

```
lib/
├── app.dart                  # App entry point with locale management
├── main.dart                 # App bootstrap with DI initialization
├── di/                       # Dependency injection
│   ├── locator.dart          # GetIt service locator setup
│   └── locale_notifier.dart  # Locale change notifier
├── data/                     # Data layer
│   ├── models/               # Data models (fromJson/toMap)
│   └── repositories/         # Repository implementations
├── domain/                   # Domain layer
│   └── models/               # Pure domain models
├── services/                 # Services (database, API, notifications)
│   ├── database_service.dart # SQLite database
│   ├── prayer_time_service.dart # Aladhan.com API client
│   └── notification_service.dart # Local push notifications
├── theme/                    # App theme (colors, spacing, typography)
├── l10n/                     # Localization (AR/EN)
└── ui/
    ├── core/widgets/         # Shared widgets
    └── features/             # Feature-based modules
        ├── onboarding/
        ├── home/             # Dashboard tab
        ├── manage/           # Prayer management screen
        ├── stats/            # Statistics tabs
        ├── content/          # Islamic content screen
        └── settings/         # Settings screen
```

### Data Flow

```
UI (View) → ViewModel (ChangeNotifier) → Repository → Service (DB / API)
                ↕
          Domain Models
```

- **Views** observe ViewModels via `ListenableBuilder`
- **ViewModels** expose immutable state and call repository methods
- **Repositories** transform data models to domain models
- **Services** handle raw I/O (SQLite, HTTP, notifications)

## Tech Stack

| Package | Purpose |
|---------|---------|
| `sqflite` | Local SQLite database |
| `http` | Prayer times API (Aladhan.com) |
| `flutter_local_notifications` | Local push notifications |
| `timezone` | Timezone-aware notification scheduling |
| `get_it` | Service locator / DI |
| `share_plus` | Data export sharing |
| `intl` | Internationalization |
| `path_provider` | File system paths |
| `flutter_lints` | Linting rules |

## Localization

Switch between Arabic and English in Settings. The app defaults to Arabic with RTL layout support.

## Contributing

Contributions are welcome. Please open an issue first to discuss what you'd like to change.

## License

This project is for personal and educational use.

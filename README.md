<div align="center">
  <img src="https://img.icons8.com/color/96/000000/mosque.png" alt="Qadaa Prayer Tracker" width="80"/>
  <h1 align="center">Qadaa Prayer Tracker</h1>
  <p align="center">Track and make up missed Islamic prayers with ease</p>
  <p align="center">
    <a href="#features">Features</a> •
    <a href="#screenshots">Screenshots</a> •
    <a href="#getting-started">Getting Started</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#testing">Testing</a> •
    <a href="#tech-stack">Tech Stack</a>
  </p>
  <p align="center">
    <code>flutter analyze</code> — 0 issues &nbsp;&nbsp;·&nbsp;&nbsp;
    <code>flutter test</code> — 210/210 passing
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
- **Cloud Sync** — Sign in with email/password to sync prayer logs and settings across devices via Supabase
- **Account Management** — Sign-in, sign-up (with email confirmation), and sign-out from the Settings screen
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
- Supabase project (for cloud sync & prayer time edge function)

### Installation

```bash
# Clone the repository
git clone https://github.com/Abdoocoder/QadaaPrayerTracker.git

# Navigate to the project
cd QadaaPrayerTracker

# Install dependencies
flutter pub get

# Set up Supabase (optional — local mode works without it)
cp .env.example .env   # Add your Supabase project URL and anon key
supabase start         # Or use an existing project

# Apply database migrations
supabase db push

# Deploy the prayer times edge function
supabase functions deploy fetch-prayer-times

# Run the app (defaults work for local development)
flutter run

# Run with custom Supabase credentials (overrides defaults)
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-anon-key
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
│   ├── locator.dart          # GetIt service locator (idempotent setup)
│   └── locale_notifier.dart  # Locale change notifier
├── data/                     # Data layer
│   ├── models/               # Data models (fromJson/toMap)
│   └── repositories/         # Repository implementations
├── domain/                   # Domain layer
│   └── models/               # Pure domain models (PrayerName, DayLog, PrayerTimes)
├── services/                 # Services (database, API, notifications, sync)
│   ├── database_service.dart # SQLite database
│   ├── prayer_time_service.dart # Aladhan.com API client → Supabase edge function
│   ├── notification_service.dart # Local push notifications
│   ├── supabase_service.dart # Supabase client (auth, REST, edge functions)
│   └── supabase_sync_service.dart # Cloud sync (upload/download prayer logs & settings)
├── theme/                    # App theme (colors, spacing, typography)
├── l10n/                     # Localization (AR/EN)
└── ui/
    ├── core/widgets/         # Shared widgets (StatCard, SectionHeader, etc.)
    └── features/             # Feature-based modules
        ├── onboarding/       # Welcome screens
        ├── home/             # Dashboard with greeting, hero card, prayer grid, reminders
        ├── manage/           # 7-day prayer management with toggle tiles
        ├── stats/            # Statistics with charts and distribution
        ├── content/          # Islamic content screen
        └── settings/         # Preferences, export, data reset

test/
├── data/models/              # Data model unit tests
├── domain/models/            # Domain model unit tests
├── features/                 # Feature-based test modules
│   ├── home/
│   │   ├── view_models/      # HomeViewModel tests
│   │   ├── dashboard_tab_test.dart
│   │   └── home_screen_test.dart
│   ├── manage/
│   │   ├── view_models/      # ManageViewModel tests
│   │   └── manage_screen_test.dart
│   ├── stats/
│   │   ├── view_models/      # StatsViewModel tests
│   │   └── stats_screen_test.dart
│   ├── settings/
│   │   ├── view_models/      # SettingsViewModel tests
│   │   └── settings_screen_test.dart
│   └── onboarding_test.dart
├── widgets/                  # Generic widget tests
├── helpers/
│   ├── mocks.dart            # Shared mock implementations (incl. MockSupabaseService)
│   └── test_setup.dart       # testSetupDi() helper
├── services/
│   └── supabase_sync_service_test.dart # Cloud sync tests (11)
└── widget_test.dart
```

### Data Flow

```
UI (View) → ViewModel (ChangeNotifier) → Repository → Service (DB / API / Edge Function)
                ↕
          Domain Models
```

- **Views** observe ViewModels via `ListenableBuilder`
- **ViewModels** expose immutable state and call repository methods
- **Repositories** transform data models to domain models
- **Services** handle raw I/O (SQLite, HTTP, Supabase)
- **Authentication** — `SupabaseService` manages sign-in/sign-up/sign-out via Supabase Auth; `SettingsViewModel` exposes auth state and triggers `syncAll()` after login
- **Cloud Sync** — `SupabaseSyncService` synchronizes local SQLite data with Supabase when signed in, using a progress stream for UI updates

### State Management

Each ViewModel extends `ChangeNotifier` and is registered as a factory in GetIt. Screens retrieve their ViewModel via `sl<ViewModel>()` and rebuild through `ListenableBuilder`. The `LocaleNotifier` propagates language changes globally.

## Testing

The project maintains **210 passing tests** with **0 analysis issues**.

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/features/home/dashboard_tab_test.dart

# Run by name
flutter test --name "SettingsViewModel"

# Static analysis
flutter analyze
```

### Test Coverage

| Test File | Tests | Scope |
|-----------|-------|-------|
| `data/models/prayer_log_model_test.dart` | 12 | `toMap`, `fromMap`, `dateToStr`, `strToDate` |
| `data/models/prayer_times_model_test.dart` | 9 | `fromJson`, `toMap`, `fromMap`, `toDomain` |
| `domain/models/prayer_name_test.dart` | 13 | Enum values, `arName`, `rakah`, `allPrayers` |
| `domain/models/day_log_test.dart` | 13 | Constructor, `total`, `completed`, `percentage` |
| `domain/models/prayer_times_test.dart` | 8 | Fields, `forPrayer`, const constructor |
| `features/home/view_models/home_view_model_test.dart` | 8 | Load, error, listener notifications |
| `features/stats/view_models/stats_view_model_test.dart` | 6 | Aggregates, distribution, error handling |
| `features/manage/view_models/manage_view_model_test.dart` | 8 | `loadDay`, `selectDay`, `toggle` |
| `features/settings/view_models/settings_view_model_test.dart` | 26 | Settings CRUD, export, reset, error rollback, auth (sign-in/sign-up/sign-out/error) |
| `features/onboarding_test.dart` | 5 | Page navigation, skip, CTA |
| `features/home/home_screen_test.dart` | 4 | Tab navigation between all 4 tabs |
| `features/home/dashboard_tab_test.dart` | 7 | Greeting, hero stats, prayer grid, reminders, error, null states |
| `features/stats/stats_screen_test.dart` | 8 | Stat cards, distribution, weekly chart, error, null states |
| `features/settings/settings_screen_test.dart` | 14 | Switches, nav items, dialogs (language, export), auth UI (account section, sign-in/sign-up dialog, sign-out) |
| `features/manage/manage_screen_test.dart` | 5 | Title, prayer toggles, save, date strip |
| `widgets/core_widgets_test.dart` | 14 | `StatCard`, `SectionHeader`, `GreetingHeader`, `ToggleTile`, `DateStrip` |
| `widgets/data_display_test.dart` | 11 | `HeroStatsCard`, `WeeklyChart`, `ReminderList` |
| `widgets/content_screen_test.dart` | 3 | Title, cards, content presence |
| `services/supabase_sync_service_test.dart` | 11 | Sync, upload, download, concurrency, progress stream, error handling |
| **Total** | **210** | |

### Environment

- Supabase credentials are loaded from `--dart-define` (or fall back to defaults in source for local development); see `.env.example` for the template
- The app runs in **local-only mode** if Supabase is not configured — no crash on missing credentials
- **Test isolation** — `DatabaseService` accepts a `dbName` parameter (`'qadaa.db'` default) to avoid file-system conflicts during parallel test execution
- **`testSetupDi()`** — a single helper in `test/helpers/test_setup.dart` that wraps `SharedPreferences.setMockInitialValues({})` + `setupDi()`, keeping test setup DRY

### Testing Approach

- **Unit tests** for domain models and ViewModels with manual mock classes (no mockito dependency)
- **Widget tests** for screens and components using `testWidgets` and `pump`
- **Shared mocks** in `test/helpers/mocks.dart` provide reusable `MockLogRepo`, `MockTimeRepo`, `MockDatabaseService`, `MockNotificationService`, `MockSupabaseService`, `MockPrayerTimeService`, and `MockLocaleNotifier` with failure flags and callbacks
- **Idempotent DI** — `setupDi()` checks `isRegistered` before registering, allowing safe re-entry across test files
- **`sl.allowReassignment = true`** in `setUp` to override ViewModel factory registrations with mock instances

## Backend (Supabase)

The app uses **Supabase** for cloud sync, authentication, and the prayer times edge function.

### Authentication

The app uses **Supabase Auth** with email/password. Users can sign up, sign in, sign out, and reset their password — all from the Settings screen. Cloud sync triggers automatically after sign-in.

- **State management** — `onAuthStateChange` listener in `SupabaseService` notifies registered listeners on session changes; `SettingsViewModel` uses `addAuthListener` to keep the UI in sync
- **Error handling** — `SupabaseService.friendlyError()` maps `AuthException` codes to user-friendly Arabic messages (invalid credentials, already registered, network issues, rate limiting)
- **Navigation** — After sign-in, the app navigates to the Home screen with a fade transition; sign-up shows a confirmation SnackBar (email verification)
- **Secrets** — Supabase URL and anon key use `String.fromEnvironment()` with defaults; override via `--dart-define`

### Schema: `qadaa`

| Table | Purpose | RLS |
|-------|---------|-----|
| `prayer_logs` | User prayer completion records (user-owned) | `SELECT`/`INSERT`/`UPDATE`/`DELETE` own |
| `prayer_times` | Cached Aladhan.com prayer times (global read) | `SELECT` all, insert via service role |
| `settings` | Key-value user preferences synced to cloud (user-owned) | `SELECT`/`INSERT`/`UPDATE`/`DELETE` own |

### Edge Function: `fetch-prayer-times`

Located at `supabase/functions/fetch-prayer-times/`.

- **Cache-first** — checks `qadaa.prayer_times` via an RPC function before calling Aladhan.com
- **Cache miss** — fetches from `https://api.aladhan.com/v1/timings`, inserts result into `qadaa.prayer_times`
- **JWT-gated** — requires a valid Supabase auth token
- **Parameters** — `date`, `lat`, `lng`, `method` (query params)
- Uses raw REST API with `Accept-Profile`/`Content-Profile` headers for `qadaa` schema access

### Migrations

All database migrations live in `supabase/migrations/20260529_create_qadaa_schema_and_tables.sql`.

## Tech Stack

### Dependencies

| Package | Purpose |
|---------|---------|
| `sqflite` | Local SQLite database |
| `supabase_flutter` | Supabase client (auth, REST API, edge functions) |
| `http` | Prayer times API (Aladhan.com) |
| `flutter_local_notifications` | Local push notifications |
| `timezone` | Timezone-aware notification scheduling |
| `get_it` | Service locator / DI |
| `share_plus` | Data export sharing |
| `intl` | Internationalization |
| `path_provider` | File system paths |
| `flutter_lints` | Linting rules |

### Dev Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_test` | Widget and unit testing framework |
| `sqflite_common_ffi` | In-memory SQLite for tests (Linux/macOS/Windows) |

## Localization

Switch between Arabic and English in Settings. The app defaults to Arabic with RTL layout support.

## Contributing

Contributions are welcome. Please open an issue first to discuss what you'd like to change.

1. Ensure `flutter analyze` passes with 0 issues
2. Ensure `flutter test` passes (all 210+ tests)
3. Update tests for any new features or changes
4. For backend changes, update the migration and re-deploy the edge function

## License

This project is for personal and educational use.

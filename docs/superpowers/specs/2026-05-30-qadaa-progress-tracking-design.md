# Qadaa Progress Tracking — Design Spec

## Overview
Replace the existing day-by-day prayer tracker with a **qadaa (makeup) focused** system. The user enters the number of years they missed prayers, the app calculates the total missed per prayer type (Fajr/Dhuhr/Asr/Maghrib/Isha), and the user logs qadaa prayers during each prayer time, deducting from the per-prayer balance.

## Core Concepts

### Data Model

**Table: `qadaa_progress`** (local SQLite + remote Supabase `qadaa.qadaa_progress`)

| Column | Type | Description |
|--------|------|-------------|
| `prayer_name` | TEXT (PK) | `fajr`, `dhuhr`, `asr`, `maghrib`, `isha` |
| `total_missed` | INTEGER | Total owed = years × 365 |
| `completed` | INTEGER | How many have been made up so far |
| `updated_at` | TEXT | Last modified timestamp |

**Table: `qadaa_logs`** (local SQLite + remote Supabase `qadaa.qadaa_logs`)

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `prayer_name` | TEXT | Which prayer was made up |
| `count` | INTEGER | How many were performed in this session |
| `created_at` | TEXT | Timestamp of the log entry |

**Settings key added:** `qadaa_years` — stores the number of years of missed prayers.

### Calculation
- `remaining = total_missed - completed`
- Total per prayer = `years × 365`
- Grand total = `5 × years × 365`
- Progress % = `sum(completed) / sum(total_missed) × 100`

## Flows

### 1. Onboarding — Years Input
After the existing 3-page carousel, a new page appears:

- Title: "كم سنة فاتتك من الصلوات؟"
- Number input with +/- buttons, range 1-50
- Displays summary: "المطلوب: 5 صلوات × 365 يوم × X سنة = Y صلاة"
- "ابدأ" button creates 5 `qadaa_progress` rows and navigates to home

### 2. Home Screen — Qadaa Tracking
The current day-by-day home screen is replaced with:

- **AppBar:** "القضاء" with notification bell + settings icons
- **Current prayer banner:** Shows the current prayer time (based on local calculation, aligned with the existing prayer time service)
- **Focused prayer card:** Large card for the current prayer, showing remaining count, with quick-add buttons: `+1`, `+5`, `+10`, and a custom number input
- **Other prayers strip:** Smaller cards for the other 4 prayers showing remaining count only (tappable to switch focus)
- **Overall progress bar:** Grand total progress bar with fractional display (e.g., "1430 / 1825 صلاة")

### 3. Logging a Qadaa Prayer
- User taps `+1`, `+5`, `+10`, or enters a custom number
- `qadaa_progress.completed` for that prayer increases by the count
- A row is inserted into `qadaa_logs` with the prayer name, count, and timestamp
- The UI updates optimistically (local state), then persists to SQLite

### 4. Settings — Edit Years
A new "القضاء" section in Settings:

- Shows current years value
- Editable number input
- Warning dialog: "سيتم إعادة تعيين التقدم بالكامل"
- On confirm: recalculates all `total_missed` values, resets `completed` to 0, clears `qadaa_logs`

### 5. Supabase Sync
Existing `SupabaseSyncService` extended to sync `qadaa_progress` and `qadaa_logs` tables:

- `uploadQadaaProgress()`: Upserts local rows to Supabase
- `downloadQadaaProgress()`: Pulls remote rows and merges (last-write-wins by `updated_at`)
- Same concurrency guard and progress stream pattern as existing sync

### 6. Supabase Schema Migration
New tables under `qadaa` schema:

```sql
CREATE TABLE qadaa.qadaa_progress (
  prayer_name TEXT NOT NULL,
  total_missed INTEGER NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (prayer_name)
);

CREATE TABLE qadaa.qadaa_logs (
  id BIGSERIAL PRIMARY KEY,
  prayer_name TEXT NOT NULL,
  count INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

Row-Level Security: users can only access their own rows (via `auth.uid()`).

## Architecture

### New/Modified Files

| File | Type | Purpose |
|------|------|---------|
| `lib/data/models/qadaa_progress_model.dart` | New | Model for `qadaa_progress` rows |
| `lib/data/models/qadaa_log_model.dart` | New | Model for `qadaa_logs` rows |
| `lib/domain/models/qadaa_progress.dart` | New | Domain model with computed `remaining` |
| `lib/services/qadaa_service.dart` | New | Business logic: CRUD, calculation, years management |
| `lib/services/supabase_service.dart` | Modified | Add `qadaa_progress` / `qadaa_logs` CRUD methods |
| `lib/services/supabase_sync_service.dart` | Modified | Add sync for new tables |
| `lib/services/database_service.dart` | Modified | Add `qadaa_progress` / `qadaa_logs` table creation in `_onCreate` |
| `lib/ui/features/onboarding/views/years_input_page.dart` | New | 4th onboarding page |
| `lib/ui/features/onboarding/views/onboarding_screen.dart` | Modified | Add years input page to flow |
| `lib/ui/features/home/view_models/home_view_model.dart` | Modified | Fetch qadaa progress instead of daily logs |
| `lib/ui/features/home/views/qadaa_tracker_screen.dart` | New | Main qadaa tracking home screen |
| `lib/ui/features/home/views/qadaa_prayer_card.dart` | New | Per-prayer card with add buttons |
| `lib/ui/features/settings/views/settings_screen.dart` | Modified | Add qadaa years section |
| `lib/ui/features/settings/view_models/settings_view_model.dart` | Modified | Handle years change + reset logic |
| `lib/di/locator.dart` | Modified | Register `QadaaService` |
| `lib/l10n/app_en.arb` | Modified | Add qadaa-related strings |
| `lib/l10n/app_ar.arb` | Modified | Add qadaa-related strings |
| `supabase/migrations/YYYYMMDD_create_qadaa_progress_tables.sql` | New | Migration for new tables |
| `test/...` | Various | Tests for all new services, models, view models, and screens |

### Service Dependencies
```
HomeViewModel → QadaaService → DatabaseService (local)
                              → SupabaseService (remote)
SettingsViewModel → QadaaService
QadaaService → DatabaseService (read/write progress + logs)
            → SupabaseSyncService (trigger sync after log)
```

## State & UX Details

### Home Screen State
- `prayerProgress: Map<PrayerName, QadaaProgress>` — all 5 progress records
- `currentPrayer: PrayerName` — determined by current time
- `selectedPrayer: PrayerName` — which card is focused (defaults to current prayer time)
- `addCount: int` — the count being entered

### Loading / Error / Empty States
- **Loading:** Skeleton cards while `QadaaService` loads progress from DB
- **Empty (no years set):** Redirect to onboarding or show prompt to set years
- **Error:** Inline error text on the card
- **Completed prayer:** When `remaining == 0`, show green checkmark and "تم القضاء" badge instead of add buttons

### Confirmation Dialogs
- **Reset warning:** When changing years in settings, dialog warns progress will be reset
- **Bulk add:** If entering > 50, confirmation dialog

## Edge Cases
- **Midnight crossover:** Current prayer time should handle Isha → Fajr transition correctly
- **Re-entering onboarding:** If user resets data, they go through years input again
- **Years = 0 or empty:** Treated as not set — show prompt to configure
- **Large numbers:** UI handles up to 50 years × 365 = 18,250 per prayer, formatted with commas
- **Decimal years:** Not supported — integer only
- **Offline:** Works entirely locally, syncs when online (existing pattern)

## Testing

### Unit Tests
- `QadaaService` — CRUD, calculation, years update + reset
- `QadaaProgress` model — `remaining` computed correctly
- `HomeViewModel` — loads progress, handles add, dedup logic
- `SettingsViewModel` — years update triggers reset

### Widget Tests
- `QadaaPrayerCard` — shows remaining, buttons work, empty/completed states
- `QadaaTrackerScreen` — full layout renders, current prayer highlighted
- `YearsInputPage` — input validation, summary display

### Integration Tests
- Sync flow: `QadaaService.addLog()` → triggers `SupabaseSyncService.syncAll()`
- Full cycle: onboarding → home → add logs → sync → reopen → data persists

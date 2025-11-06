# Together – two-person recovery companion (Flutter)

This app implements the first milestone of "Together": a calm, trust-centered daily companion for two linked users (Arne & Cecilie) to support recovery through simple check-ins and gentle transparency.

## What’s in this milestone

- Daily Check-In screen (mood, on-track status, notes, gratitude, share toggle)
- Partner View with simplified shared summaries + supportive quick notes (demo)
- Shared Reflection tab placeholder (future weekly summaries etc.)
- Local persistence via SharedPreferences with seeded mock data
- Simple streak indicator and trend placeholder
- Provider-based state management and a clean app theme
- Optional JSON schema: `assets/schemas/checkin.schema.json`

## Project structure

- `lib/src/app.dart` – App bootstrap, DI for repository
- `lib/src/theme.dart` – Calm Material 3 theme
- `lib/src/models/` – Data models (check-in, user)
- `lib/src/data/` – Repositories (shared_prefs, in-memory)
- `lib/src/state/app_state.dart` – App state (Provider/ChangeNotifier)
- `lib/src/ui/` – Pages: Home (tabs), Check-In, Partner, Shared (placeholder)

## Run locally

1) Install Flutter and run a device/emulator.
2) Fetch packages and run the app.

Optional commands:

```powershell
flutter pub get
flutter run
```

Run tests:

```powershell
flutter test
```

## Notes on privacy & next steps

- Today’s build is offline-first; cloud sync and E2E encryption are not yet implemented.
- Pairing/auth is stubbed at the architecture level (repository injection) and will be wired to Supabase/Nextcloud in a later milestone.
- Next steps: weekly summaries, anchor messages automation, QR pairing, encrypted sync, and a read-only "Support Mode" for the partner.

## Deliverables mapping

- Flutter project structure – added under `lib/src/...`
- Example mock data – seeded in `SharedPreferencesCheckInRepository.bootstrap()`
- Authentication + sync logic – interface prepared (`CheckInRepository`); cloud impl TBD
- Two UI mockups – Check-In and Partner View are implemented as working mock UIs
- JSON schema – `assets/schemas/checkin.schema.json`

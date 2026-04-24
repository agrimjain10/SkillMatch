# SkillMatch

SkillMatch is a Flutter + Supabase campus collaboration app for discovering talent, matching users, chatting after mutual match, joining projects, earning badges, and tracking progress through lightweight gamification.

## Features

- Email OTP auth with onboarding flow
- Discover talent and mutual match flow
- Chat unlocked after both users match
- Project archive with collaboration requests
- Profile editing, photo upload, badges, streaks, leaderboard
- Admin dashboard for `agrimjain056@gmail.com`
- Web + Android support

## Stack

- Flutter
- Riverpod
- GoRouter
- Supabase Auth / Database / Storage

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

Web server mode:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8085
```

## Supabase setup

Run the SQL in:

`supabase/skillmatch_schema.sql`

This creates or repairs the required tables, policies, badges, streak support, project members, and storage rules.

## Build

```bash
flutter build web --debug
flutter build apk --release
```

## Repo notes

- Generated logs and local analysis artifacts are ignored.
- Current release APK is debug-key signed unless release signing is configured separately.

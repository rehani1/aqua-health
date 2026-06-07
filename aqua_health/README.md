# Aqua Health

Note: Aqua Health was originally created as part of UVA’s CS 4971 capstone course under Professor Mark Sherriff, in collaboration with my Blue-05 teammates Owen Badgley and Bryan Katuari. This repository is my fork of the project, which I am continuing to develop independently as a personal project.

Aqua Health is a local-first Android Flutter app that turns daily Health Connect activity into an aquarium habit loop.

Version 1.0.0 provides an egg hatcher interface where sleep can spawn eggs, steps hatch them, and animals can be kept in the aquarium or stored locally in a PC-style collection. Health data stays on the device and there is no hosted backend.

## Features

- Android Health Connect sync for steps and sleep.
- Sleep-goal rewards that spawn eggs into three local egg slots.
- Step-based hatch progress for active eggs.
- Hatch reveal flow with animal naming.
- Animated aquarium view with locally persisted animals.
- Animal rename, store to PC, withdraw from PC, and release actions.
- PC access button with local stored-animal management.
- Egg deletion for clearing unwanted eggs.
- Hive-backed local persistence for settings, animals, and eggs.
- Demo health controls for debug and non-Android development.

## Requirements

- Flutter SDK and Dart.
- Android Studio or Android SDK command-line tools.
- An Android device or emulator with Health Connect support.
- A Health Connect data source that writes steps and sleep records.

## Development

Install dependencies:

```sh
flutter pub get
```

Run the app:

```sh
flutter run
```

Run checks:

```sh
dart format .
flutter analyze --no-pub
flutter test
```

Run with demo health controls:

```sh
flutter run --dart-define=aquaHealth.useDemoHealthData=true
```

## Android Release

The Android application id is `com.rehani.aquahealth`.

Create `android/key.properties` from `android/key.properties.example` and point `storeFile` at a private release keystore. The real `key.properties` file and keystores are ignored by git.

Build an Android App Bundle:

```sh
flutter build appbundle --release
```

Without `android/key.properties`, release builds fall back to debug signing for local smoke testing only. Store deployment should use a real release keystore.

## Architecture

The active app starts in `lib/main.dart` at `EggHatcherScreen`. It owns the visible egg hatcher UI, health refresh controls, aquarium view, PC panel, rename/release actions, and egg deletion actions.

Game state lives in `lib/controller/backend.dart`. Hive boxes store settings, aquarium animals, and egg holders locally as `settings`, `aquarium`, and `eggHolders`.

Health Connect integration lives in `lib/health_service.dart`. It requests read access for steps and sleep, reads today's steps, merges sleep intervals from the last 24 hours, and returns zero when data or permissions are unavailable.

Android Health Connect permissions and rationale/onboarding activities are declared in `android/app/src/main/AndroidManifest.xml`, with Kotlin activities under `android/app/src/main/kotlin/com/rehani/aquahealth`.

## Release

This repository is prepared for Aqua Health 1.0.0.

See `CHANGELOG.md` for release notes.

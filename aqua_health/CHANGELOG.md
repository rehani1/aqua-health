# Changelog

All notable changes to Aqua Health will be documented in this file.

## 1.0.0 - 2026-06-07

### Added

- Android-first egg hatcher flow backed by local Health Connect steps and sleep data.
- Sleep-goal rewards that spawn eggs into three egg slots.
- Step-based hatch progress for every active egg.
- Hatch reveal flow with naming before the new animal joins the aquarium.
- Local aquarium with animated animals, rename actions, PC storage, PC withdrawal, and release actions.
- Egg deletion for clearing unwanted or blocked egg slots.
- Local Hive persistence for settings, aquarium animals, and eggs.
- Demo health controls for debug/non-Android development without Health Connect.

### Changed

- Prepared Android package metadata for deployment with the `com.rehani.aquahealth` application id.
- Updated the Android launcher label to `Aqua Health`.
- Removed unused template dependencies and cleaned the package manifest.

### Deployment

- Added release signing configuration that reads ignored local values from `android/key.properties`.
- Added `android/key.properties.example` as the template for release signing setup.

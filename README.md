# My Flutter Base

An opinionated Flutter project template for multi-flavor mobile apps. It ships a
main app, shared core package, data-source module, reusable UI/theme/media
plugins, code generation tooling, localization generation, agent guidance, and
distribution scaffolding.

## Current template identity

- **App name**: My Flutter Base
- **Base package / bundle ID**: `com.pbh.myflutterbase`
- **Default locale**: English (`en`)
- **Secondary locale**: Vietnamese (`vi`)
- **Primary app**: `apps/main`

## What's included

```text
├── apps/main/                   Main Flutter app and native flavor config
├── core/                        Shared utilities, services, base UI, theme and locale helpers
├── modules/
│   └── data_source/             Shared data-source module and codegen plumbing
├── plugins/
│   ├── fl_ui/                   Reusable controls and UI helpers
│   ├── fl_utils/                Extensions, formatters, date and utility helpers
│   ├── fl_theme/                AppTheme, ScreenTheme, ThemeColor and text-theme extensions
│   ├── fl_media/                Media picking, viewing, cropper, video and media l10n helpers
│   └── fl_navigation/           Navigation utilities
├── tools/module_generator/      Generators for modules, assets, exports and localization helpers
├── .agents/                     Project-local skills for AI coding agents
├── scripts + *.sh               Build, clean, deploy, localization and identifier scripts
├── fvm_pubspec.yaml             Flutter SDK version used by the makefile when FVM is installed
└── makefile                     Project task runner; use `make help`
```

## Toolchain

The template is currently aligned to:

| Area | Version / setting |
| --- | --- |
| Flutter SDK | `3.41.7` from `fvm_pubspec.yaml` |
| Dart SDK | `3.11.5` with Flutter 3.41.7 |
| Package constraints | Dart `>=3.8.0 <4.0.0`; Flutter mostly `>=3.32.0` |
| Android | AGP `8.9.1`, Kotlin `2.1.0`, Gradle `8.12`, Java `17` |
| Android SDK | `minSdkVersion 26`, `targetSdkVersion 35`, NDK `27.0.12077973` |
| iOS | Minimum platform `13.0` |
| Codegen | `freezed 3.2.3`, `retrofit_generator 10.2.3`, `json_serializable ^6.11.1`, `hive_ce_generator ^1.9.3`, `injectable_generator ^2.6.2` |

The makefile auto-detects `fvm` and runs `fvm flutter` / `fvm dart` when
available; otherwise it falls back to the system `flutter` / `dart` commands.

## Quickstart

```bash
# 1. Seed local environment and Android signing config from templates.
cp apps/main/.env.example apps/main/.env
cp apps/main/android/keystores/keystore.properties.example \
   apps/main/android/keystores/keystore.properties
# Fill in the placeholder values in both files.

# 2. Pull dependencies and regenerate localization, assets and generated Dart.
make setup

# 3. Run the dev app on a device, simulator or emulator.
cd apps/main
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=./.env
```

Useful make targets:

| Target | Purpose |
| --- | --- |
| `make help` | Show every available target |
| `make setup` | `clean` + `pub_get` + `lang` + `asset` + `gen_all` |
| `make reset` | Clean and regenerate language files, assets and generated code |
| `make pub_get` | Run `flutter pub get` for plugins, `core`, and `apps/main` |
| `make gen` | Interactive code generation menu |
| `make gen_all` | Run generation for `core`, `modules/data_source`, and `apps/main` |
| `make gen_core` / `make gen_data_source` / `make gen_main` | Run scoped generation |
| `make asset` | Generate `apps/main` asset references |
| `make lang` | Regenerate localization outputs for app, core, and `fl_media` |
| `make gen_translation` / `make apply_translation` | Round-trip app translations through a status-tracked CSV |
| `make app_identifier` | Regenerate app identifiers from `apps/main/app_identifier.yaml` |
| `make run_module_generator` | Run the interactive module generator |
| `make build` | Interactive Android/iOS distribution wrapper |
| `make run_web_dev` / `make run_web_staging` | Run web server on port 3000 for dev/staging |
| `make build_web` | Interactive web build wrapper |
| `make coverage_main` | Generate coverage for `apps/main` |
| `make format` | Run `dart format .` |
| `make clean` / `make clean_force` | Clean project build outputs |

## App identity and flavors

App identity is sourced from `apps/main/app_identifier.yaml` and generated into:

- `apps/main/android/app_specific.properties`
- `apps/main/ios/Flutter/AppSpecific.xcconfig`

The native Android/iOS flavor identifiers currently include:

| Flavor | Package / bundle ID | Display name |
| --- | --- | --- |
| `dev` | `com.pbh.myflutterbase.dev` | My Flutter Base DEV |
| `staging` | `com.pbh.myflutterbase.staging` | My Flutter Base STAGING |
| `sandbox` | `com.pbh.myflutterbase.sandbox` | My Flutter Base SANDBOX |
| `prod` | `com.pbh.myflutterbase` | My Flutter Base |

Dart entry points currently present in `apps/main/lib/`:

| Entry point | App config |
| --- | --- |
| `main_dev.dart` | `AppEnv.devEnv` |
| `main_staging.dart` | `AppEnv.stagingEnv` |
| `main.dart` | `AppEnv.prodEnv` |

The Android product flavors and iOS identifiers include `sandbox`, but this
codebase does not currently include `apps/main/lib/main_sandbox.dart`. Add the
missing entry point and update `apps/main/dist_config.sh` before relying on a
scripted sandbox distribution flow.

When changing app identity, update `apps/main/app_identifier.yaml`, regenerate
identifiers, and keep the Android namespace/package path aligned at:

- `apps/main/android/app/build.gradle`
- `apps/main/android/app/src/main/kotlin/com/pbh/myflutterbase/MainActivity.kt`

## Architecture

The app follows clean architecture:

- **`data/`** — data sources, DTOs, repositories, local storage
- **`domain/`** — entities, use cases, repository contracts
- **`presentation/`** — UI, BLoCs, routes, widgets

Primary libraries and patterns:

- **State management**: BLoC + Freezed `_StateData` classes
- **Dependency injection**: Injectable + GetIt
- **Networking**: Retrofit + Dio through `modules/data_source`
- **Local storage**: Hive CE, SharedPreferences, secure storage
- **Routing**: `IRoute` / `CustomRouter` abstractions from `core`
- **Localization**: CSV source files -> ARB -> generated localizations

Dependency flow:

```text
apps/main -> core -> modules/data_source -> plugins
```

## Presentation modules

Feature modules live under `apps/main/lib/presentation/modules/`.

Simple modules use the standard shape:

```text
<feature>/
├── <feature>.dart
├── <feature>_route.dart
├── <feature>_coordinator.dart
├── bloc/
└── views/
```

For multi-screen features, use a parent module for the barrel, coordinator and
route aggregation, then place each non-trivial child screen in its own sub-module
with `bloc/` and `views/`.

Prefer `make run_module_generator` before hand-writing a module.

## Code generation

Generated files are committed, but should be regenerated instead of hand-edited.
Common generated outputs include:

- `*.g.dart`
- `*.freezed.dart`
- `*.config.dart`
- `apps/main/lib/generated/assets.dart`
- `*/lib/l10n/intl_*.arb`
- `*/lib/l10n/generated/*localizations*.dart`
- generated export barrels from `module_generator:generate_export`

Use scoped generation when possible:

```bash
make gen_core
make gen_data_source
make gen_main
make gen_all
```

## Localization

CSV files are the source of truth for localized strings:

- `apps/main/lib/l10n/localizations.csv`
- `core/lib/l10n/localizations.csv`
- `plugins/fl_media/lib/src/l10n/localizations.csv`

The current CSV header is `key,en,vi`. After editing any CSV, run:

```bash
make lang
```

Do not edit generated `intl_*.arb` or `*_localizations*.dart` files directly.
Use positional placeholders such as `{0}` and `{1}`.

## Distribution and signing

Android signing starts from:

- `apps/main/android/keystores/keystore.properties.example`
- `apps/main/android/app/signing.gradle`

Copy the example to `keystore.properties` and fill in real values. Generate or
provide the referenced `.jks` files in `apps/main/android/keystores/` before
building release flavors. Debug builds fall back to the Android SDK debug
keystore when release keystores are missing.

Distribution and CI/CD related files live in:

- `distribution.sh`
- `build_web.sh`
- `deploy.sh`
- `apps/main/dist_config.sh`
- `apps/main/fastlane/`
- `apps/main/CICD_SECRETS_SETUP.md`
- `apps/main/ios/QUICK_START.md`
- `apps/main/ios/PROVISIONING_PROFILE_SETUP.md`
- `apps/main/ios/CICD_PROVISIONING_GUIDE.md`
- `apps/main/ios/signing_res/my_flutter_base/`

`apps/main/dist_config.sh` currently defines dev and staging distribution values.
Extend it before using scripted sandbox or prod distribution targets.

## Customizing the template

When forking this template for a real app:

1. Update `apps/main/app_identifier.yaml` with the new names and package IDs.
2. Regenerate native identifiers with `make app_identifier`.
3. Update Android namespace/package paths if the base package changes.
4. Replace assets under `apps/main/assets/images/` and Android launcher icons
   under `apps/main/android/app/src/main/res/mipmap-*`.
5. Update `apps/main/flutter_native_splash.yaml` and regenerate splash assets.
6. Add brand fonts to `apps/main/assets/fonts/` and declare them in
   `apps/main/pubspec.yaml`.
7. Update Fastlane, Firebase, Apple Developer, provisioning, and CI CD secrets
   docs before distributing builds.

## AI agent guidance

The repo includes project-local agent guidance:

- `AGENTS.md` — top-level conventions for AI coding agents
- `.agents/README.md` — skill bundle overview
- `.agents/INDEX.md` — one-line summary of every skill
- `.agents/skills/*/SKILL.md` — task-specific guidance for modules, BLoC,
  routing, localization, data layer, testing, reviews, and theme usage

## License

MIT. See the `LICENSE` files in package/plugin directories.

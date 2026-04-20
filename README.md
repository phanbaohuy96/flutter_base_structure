# Flutter Base Structure

An opinionated Flutter project template with multi-flavor builds, codegen, a
curated plugin set, and distribution scaffolding — ready to fork into a new
app.

## What's included

```
├── apps/main/                   Main Flutter app (dev / staging / sandbox / prod flavors)
├── core/                        Shared library: utilities, services, theming, base widgets
├── modules/
│   └── data_source/             Retrofit + hive_ce + json_serializable plumbing
├── plugins/
│   ├── fl_ui/                   Common widgets (inputs, dropdowns, RadioButtonWithTitle, …)
│   ├── fl_utils/                Extensions, date utils, formatters, currency/weight helpers
│   ├── fl_theme/                AppTheme / ScreenTheme / ThemeColor with checkbox + chip theming
│   ├── fl_media/                Image cropper, media viewer, pick_file_helper, video widgets
│   └── fl_navigation/           go_router-based routing utilities
├── tools/module_generator/      Code generators (modules, assets, localizations, translations)
├── apps/main/fastlane/          iOS + Android distribution, CI-CD-friendly Fastfile
├── apps/main/android/keystores/ Per-flavor signing config (keystore.properties.example)
└── makefile                     `make help` lists every task
```

Stack: Flutter **3.41.7**, Dart **3.11.5**, Kotlin **2.1.0**, AGP **8.9.1**,
Gradle **8.12**. Codegen: `freezed 3.2.3`, `retrofit_generator 10.2.3`,
`json_serializable ^6.11.1`, `hive_ce_generator ^1.9.3`,
`injectable_generator ^2.6.2`.

Pin the Flutter version however you prefer — the `makefile` auto-detects
[fvm](https://fvm.app) if it's on PATH (using `fvm_pubspec.yaml` to resolve
the version) and falls back to the system `flutter` otherwise.

## Quickstart

```bash
# 1. Seed env + keystore config from the templates
cp apps/main/.env.example apps/main/.env
cp apps/main/android/keystores/keystore.properties.example \
   apps/main/android/keystores/keystore.properties
# Fill in the placeholder values in both files.

# 2. Pull deps + run code generators across all packages
make pub_get
make gen_all

# 3. Run on a device / emulator
cd apps/main
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=./.env

# or build an APK:
flutter build apk --debug --flavor dev -t lib/main_dev.dart \
    --dart-define-from-file=./.env
```

The full task list is in `make help`. Highlights:

| Task | Purpose |
| --- | --- |
| `make setup` | Clean + pub_get + lang + asset + gen_all + gen_env |
| `make pub_get` | Flutter pub get across core, data_source, apps/main, all plugins |
| `make gen_all` | Run build_runner across core, data_source, apps/main |
| `make lang` | Regenerate `.arb` files from `localizations.csv` |
| `make gen_translation` / `make apply_translation` | Round-trip translations through a status-tracked CSV |
| `make build` | Interactive build picker (env × platform) |
| `make coverage_main` | Test coverage for `apps/main` |
| `make format` | `dart format .` |

## Making it yours

When forking this template for a real app, rename the template identity:

1. **Bundle IDs / package names.** Edit:
   - `apps/main/app_identifier.yaml`
   - `apps/main/ios/Flutter/AppSpecific.xcconfig`
   - `apps/main/android/app_specific.properties`
   - `apps/main/android/app/build.gradle` (`namespace`)
   - `apps/main/android/app/src/main/kotlin/com/pbh/baseflutter/MainActivity.kt`
     — move the file under a new path (e.g. `com/yourorg/yourapp/`) and update
     the `package` declaration to match.
2. **App icons & splash.** Replace everything under `apps/main/assets/images/`
   and `apps/main/android/app/src/main/res/mipmap-*`. Regenerate launch assets
   via `flutter_native_splash` (see `apps/main/flutter_native_splash.yaml`).
3. **Brand font.** The `fonts:` block in `apps/main/pubspec.yaml` is a
   commented stub — add the family and drop the `.woff2` files into
   `apps/main/assets/fonts/`.
4. **Distribution.** Update `apps/main/fastlane/Fastfile` and the
   `apps/main/ios/*.md` provisioning guides with your own Apple Developer
   team ID and Firebase app IDs. `apps/main/fastlane/.env.example` lists
   every CI-CD secret the lanes consume.

## Architecture

Clean architecture across three layers:

- **`data/`** — data sources (REST, hive_ce local storage), DTO models, repositories
- **`domain/`** — entities, use cases, repository contracts
- **`presentation/`** — BLoC (flutter_bloc + bloc_concurrency), widgets, routing

`core/` exposes everything shared. `modules/data_source/` hosts generic
retrofit clients. `apps/main/` wires the three layers together with
`injectable` DI.

## Environments

Four flavors wired through dart-defines, Android flavors, and iOS xcconfigs:

- `dev` — local / staging backend, debug signing
- `staging` — pre-prod, staging keystore
- `sandbox` — customer sandbox, sandbox keystore
- `prod` — production, prod keystore

Each has its own entry point (`apps/main/lib/main_{dev,staging,sandbox,prod}.dart`)
and Firebase app registration slot.

## License

MIT. See `LICENSE` in each plugin directory.

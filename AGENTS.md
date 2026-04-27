# AGENTS.md

Guidance for AI coding agents working in this Flutter base template.

## Project Overview

This repository is an opinionated Flutter project template for building multi-flavor mobile apps. It includes a main Flutter app, shared core package, data-source module, reusable UI/theme/media/navigation plugins, code generation tooling, localization generation, and distribution scaffolding.

**Current template identity**: My Flutter Base  
**Default locale**: English (`en`)  
**Secondary locale**: Vietnamese (`vi`)  
**Base package ID**: `com.pbh.myflutterbase`

**Stack**: Flutter 3.41.7, Dart 3.11.5, Kotlin 2.1.0, AGP 8.9.1, Gradle 8.12, Java 17.

## Architecture

The app follows clean architecture:

- `data/` - data sources, DTOs, repositories, local storage
- `domain/` - entities, use cases, repository contracts
- `presentation/` - UI, BLoCs, routes, widgets

Primary libraries and patterns:

- **State management**: BLoC + Freezed
- **DI**: Injectable + GetIt (`apps/main/lib/di/di.dart`)
- **Networking**: Retrofit + Dio via `modules/data_source`
- **Local storage**: Hive, SharedPreferences, secure storage
- **Routing**: project route abstractions under `presentation/route`
- **Localization**: CSV source files -> ARB -> generated localizations

Dependency flow:

```text
apps/main -> core -> modules/data_source -> plugins
```

## Project Structure

```text
apps/main/           # Main Flutter app entry point and flavors
core/                # Shared package: utilities, services, base widgets, app locale/theme helpers
modules/
  data_source/       # Retrofit, Hive, JSON, and repository plumbing
plugins/
  fl_ui/             # Reusable UI widgets
  fl_theme/          # ThemeColor, ScreenTheme, app theme extensions
  fl_media/          # Media picking/viewing helpers and localization
  fl_navigation/     # Navigation utilities
  fl_utils/          # Extensions, date/format helpers
scripts + *.sh       # Build, clean, deploy, profile, identifier, localization helpers
tools/
  module_generator/  # Code generators for modules, assets, identifiers, l10n, exports
.agents/             # Skill bundle for AI coding agents
```

## Entry Points and Flavors

- `apps/main/lib/main.dart` - Production
- `apps/main/lib/main_dev.dart` - Development
- `apps/main/lib/main_staging.dart` - Staging
- `apps/main/lib/main_sandbox.dart` - Sandbox

App initialization starts from `AppDelegate.run(AppConfig)`.

Flavor identity is configured in:

- `apps/main/app_identifier.yaml` - source of truth
- `apps/main/android/app_specific.properties` - generated Android display names/application IDs
- `apps/main/ios/Flutter/AppSpecific.xcconfig` - generated iOS display names/bundle IDs
- `apps/main/android/app/build.gradle` - Android namespace/flavor config
- `apps/main/android/app/src/main/kotlin/.../MainActivity.kt` - Android Kotlin package path

When changing app identity, edit `app_identifier.yaml`, update Android namespace/package path if needed, then regenerate identifiers.

## Operating Principles

These generic agent rules come before implementation details. For the full checklist, use `.agents/skills/behavioral-guardrails/SKILL.md`.

1. **Think before coding**: do not silently choose an interpretation when the request is ambiguous. State assumptions, surface tradeoffs, and ask before changing identifiers, signing, CI/CD, generated workflows, or broad formatting.
2. **Simplicity first**: write the minimum code that solves the current request. Reuse existing repo patterns, widgets, helpers, and skills before adding new abstractions.
3. **Surgical changes**: every changed line should trace to the request or required generated output. Do not refactor adjacent code, reformat unrelated files, or delete unrelated dead code unless asked.
4. **Goal-driven execution**: for multi-step work, define success criteria before coding, then verify with concrete checks such as `rg`, generation commands, analyzer, tests, or UI smoke tests.

## Generalized implementation guidance

- When the user names an existing architecture or pattern, follow that structure directly; ask before substituting a lighter-weight shortcut.
- For multi-screen features, keep parent modules responsible for route/coordinator aggregation and give non-trivial child screens their own module state.
- Reuse existing project widgets, helpers, and abstractions before creating new ones.
- Design reusable row/list components so trailing content aligns consistently and can accept widgets when needed.
- Add concise Dartdoc to newly introduced public APIs in reusable or cross-layer surfaces.
- When a child flow mutates data that a caller needs, return the updated result instead of forcing an immediate duplicate read.
- Keep storage operations behind the existing data/domain boundaries and prefer stable table/row operations over replacing storage infrastructure.
- Remove stale source-of-truth entries and regenerated outputs when a feature surface is removed.
- For user-facing UI changes, run an available smoke test before reporting completion, or state why it could not be run.

## Command Priority

Prefer project-standard commands over ad-hoc direct commands.

1. **Dart/Flutter MCP tools** if available in the current agent harness
2. **Make commands** from the root `makefile`
3. **Direct Flutter/Dart commands** only when there is no make target or MCP tool

Useful make targets:

```bash
make setup       # Clean + pub_get + lang + asset + gen_all
make pub_get     # Dependencies across plugins, core, and main app
make gen_all     # Code generation for core, data_source, and main app
make gen_core    # Code generation for core only
make gen_main    # Code generation for apps/main only
make lang        # Regenerate all localization outputs
make format      # dart format .
make test        # Run tests when available
make coverage_main
make analyze     # If present in this branch; otherwise use flutter analyze directly
make help        # Show available commands
```

Do not run broad generation unless a relevant generated source changed. For example, only run `make gen_core` after changing `@JsonSerializable`, Freezed, Injectable, route/export inputs, or generated code inputs in `core`.

## Code Generation Rules

Never hand-edit generated files unless the user explicitly asks and there is no generator path.

Generated files include:

- `*.g.dart`
- `*.freezed.dart`
- `*.config.dart`
- `lib/generated/assets.dart`
- `lib/l10n/generated/*localizations*.dart`
- `intl_*.arb` generated from localization CSVs
- generated export barrels from `module_generator:generate_export`

Common generation commands:

```bash
make lang          # CSV -> ARB -> localization Dart for app/core/fl_media
make gen_core      # build_runner + export generation in core
make gen_main      # build_runner in apps/main
make gen_all       # core + data_source + apps/main
sh gen_app_identifier.sh apps/main
```

## Localization

Localization source files are CSV files, not generated Dart files.

Current supported locales:

- English: `en` (default/primary)
- Vietnamese: `vi`

Source files:

- `apps/main/lib/l10n/localizations.csv`
- `core/lib/l10n/localizations.csv`
- `plugins/fl_media/lib/src/l10n/localizations.csv`

CSV format:

```csv
key,en,vi
welcome,Welcome,Chào mừng
greeting,"Hello, {name}!","Xin chào, {name}!"
```

Rules:

- Update CSV first.
- Run `make lang` after CSV changes.
- Use existing keys before adding new ones.
- Keep key names stable unless the rename improves stale branding or semantics.
- Generated localization APIs use positional parameters, not named parameters.
- In widgets, use the project localization helper, for example `final trans = translate(context);`.

Locale wiring lives primarily in:

- `core/lib/common/constants/locale/app_locale.dart`
- `apps/main/lib/app_delegate.dart`
- `core/lib/common/calendar.dart`
- `core/lib/presentation/extentions/context_extention.dart`

## Presentation Module Architecture

### Simple module

For modules with one screen, use a flat structure:

```text
module_name/
  bloc/
    module_bloc.dart
    module_event.dart
    module_state.dart
  views/
    widgets/               # Optional module widgets
    module_screen.dart
    module.action.dart      # Optional screen logic extension
  module_route.dart
  module.dart               # Barrel export
```

### Compound module

When a feature has multiple screens, each screen should be a sub-module with its own BLoC:

```text
parent_module/
  parent_module.dart
  parent_module_route.dart
  parent_module_coordinator.dart
  sub_module_a/
    bloc/
    views/
    sub_module_a.dart
  sub_module_b/
    bloc/
    views/
    sub_module_b.dart
  shared/
```

Rules:

- Every non-trivial sub-module gets its own BLoC.
- Parent route files aggregate child routes.
- Navigation extensions belong in `*_coordinator.dart`.
- Barrel exports should chain from parent to child modules.

## Screen and Action Pattern

Prefer keeping screens declarative and moving action logic into same-directory action extensions when logic grows.

Rules:

- Create `*.action.dart` in the same directory as the screen.
- Start the action file with `part of 'original_screen.dart';`.
- Extension target should be the private state class.
- Action methods should usually be private.

Example:

```dart
// settings_screen.dart
part 'settings.action.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends StateBase<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final trans = translate(context);
    return ThemeButton.primary(
      title: trans.confirm,
      onPressed: _handleConfirm,
    );
  }
}

// settings.action.dart
part of 'settings_screen.dart';

extension SettingsScreenAction on _SettingsScreenState {
  void _handleConfirm() {}
}
```

## BLoC Standards

Follow the repository `bloc-pattern` skill. This template does **not** use the typical Freezed union shape for BLoC events/states.

Rules:

- Bloc extends `AppBlocBase<E, S>` and is annotated `@Injectable()`.
- Events are hand-written subclasses of one abstract `<Feature>Event`; do not use Freezed unions for events.
- States are hand-written subclasses of one abstract `<Feature>State`; do not use `FeatureState.loading()` / `.loaded()` Freezed unions.
- State subclasses share one Freezed `_StateData` class.
- The abstract state exposes `copyWith<T extends FeatureState>({_StateData? data})` backed by a `_factories` map.
- Every concrete state class must be registered in `_factories` in the same edit.
- Use `package:core/core.dart` for BLoC exports instead of importing `flutter_bloc` directly.
- Run the relevant generator after changing `_StateData`, events, states, or bloc annotations.

Reference shape:

```dart
@Injectable()
class FeatureBloc extends AppBlocBase<FeatureEvent, FeatureState> {
  final FeatureUsecase _usecase;

  FeatureBloc(@factoryParam Item? initial, this._usecase)
      : super(FeatureInitial(data: _StateData(initial: initial))) {
    on<GetFeatureEvent>(_onGet);
  }

  Future<void> _onGet(GetFeatureEvent event, Emitter<FeatureState> emit) async {
    final detail = await _usecase.getById(event.id);
    emit(state.copyWith<FeatureLoaded>(data: state.data.copyWith(detail: detail)));
  }
}

@freezed
sealed class _StateData with _$StateData {
  const factory _StateData({
    Item? detail,
    @Default([]) List<Item> items,
  }) = __StateData;
}

abstract class FeatureState {
  final _StateData data;

  FeatureState(this.data);

  T copyWith<T extends FeatureState>({_StateData? data}) {
    return _factories[T == FeatureState ? runtimeType : T]!(data ?? this.data);
  }

  Item? get detail => data.detail;
  List<Item> get items => data.items;
}

class FeatureInitial extends FeatureState {
  FeatureInitial({required _StateData data}) : super(data);
}

class FeatureLoaded extends FeatureState {
  FeatureLoaded({required _StateData data}) : super(data);
}

final _factories = <Type, Function(_StateData data)>{
  FeatureInitial: (data) => FeatureInitial(data: data),
  FeatureLoaded: (data) => FeatureLoaded(data: data),
};

abstract class FeatureEvent {}

class GetFeatureEvent extends FeatureEvent {
  final String id;
  GetFeatureEvent(this.id);
}
```

Loading/error handling:

- `StateBase<T>` registers screen loading/error handlers with the bloc delegate.
- Bloc handlers may call `showLoading()` / `hideLoading()` from `CoreDelegate`; pair them with `finally`.
- Throw or rethrow errors unless a handler fully consumes them; `CoreBlocBase.onError` routes thrown errors to the screen.

## UI and Theme Rules

Before creating a new widget, check existing reusable widgets in this order:

1. `plugins/fl_ui/`
2. `core/lib/presentation/common_widget/`
3. `apps/main/lib/presentation/common_widget/`
4. Current module `views/widgets/`
5. Exports from `package:core/core.dart`

Theme rules:

- Prefer `context.themeColor` for semantic colors.
- Prefer project text tokens/extensions over raw Material text styles.
- Use `ScreenForm` for standard screens when available.
- Avoid custom `ButtonStyle` unless the default `ThemeButton` parameters cannot express the design.

## Import Ordering

Use this order:

1. Dart SDK imports
2. External package imports
3. Project/package imports
4. Relative imports
5. `part` directives / generated files where Dart requires them

Example:

```dart
import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../di/di.dart';
import '../bloc/feature_bloc.dart';

part 'feature.action.dart';
```

## Distribution and Signing

Distribution-related files:

- `apps/main/dist_config.sh`
- `distribution.sh`
- `deploy.sh`
- `apps/main/fastlane/Fastfile`
- `apps/main/ios/Flutter/AppSpecific.xcconfig`
- `apps/main/ios/signing_res/my_flutter_base/`
- `apps/main/android/keystores/`

Do not change package IDs, bundle IDs, signing paths, CI secrets, provisioning docs, or Fastlane lanes casually. These changes affect external systems such as Firebase, Apple Developer, Play Console, and CI/CD.

## Testing and Verification

For code changes, prefer the narrowest useful verification first, then broader checks:

```bash
make format
make lang          # If localization CSV changed
make gen_core      # If core generated inputs changed
make gen_main      # If app generated inputs changed
flutter analyze    # From the relevant package if no make target is available
flutter test       # From the relevant package if tests exist
```

For UI changes, run the app and smoke-test the affected flow before reporting completion whenever possible. If you cannot run the UI in this environment, say so explicitly.

## Final Reminders

1. Check existing implementations before writing new code.
2. Prefer reusable widgets and helpers over new abstractions.
3. Keep screens clean; move growing action logic to `*.action.dart`.
4. Add/update English and Vietnamese localization through CSV files.
5. Never edit generated files when a generator exists.
6. Use make targets for generation and localization.
7. Keep technical identifier changes deliberate and consistent across Android, iOS, docs, and CI scripts.
8. Do not add speculative abstractions, fallback logic, or comments unless they are needed for the current task.

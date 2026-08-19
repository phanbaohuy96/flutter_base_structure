# Module Generator

Utilities for generating projects, feature modules, exports, localization helpers, and asset accessors in this Flutter template.

## Feature modules

Run the generator from inside the package you are scaffolding into:

```bash
make run_module_generator      # prompts for the package, then shows the menu
# or
sh run_module_generator.sh apps/main
```

The menu covers `common` / `listing` / `detail` modules, plus standalone
repository, usecase, and model templates.

### What a module run emits

For `--type listing --name product_list --entity Product`:

```text
lib/domain/entities/product/product.entity.dart          # freezed, if absent
lib/domain/entities/product/product_filter.entity.dart   # listing only
lib/presentation/modules/product_list/
  bloc/product_list_bloc.dart | _event.dart | _state.dart
  views/product_list_screen.dart | product_list.action.dart
  product_list_route.dart
  product_list_coordinator.dart
  product_list.dart                                      # barrel
lib/domain/usecases/product_list/
  product_list_usecase.dart | product_list_usecase.impl.dart
```

Emitted files are run through `dart format`, so they land inside the repo's
80-column and trailing-comma lints regardless of how long the names are.

### Coordinators

Every module template emits a `<module>_coordinator.dart` — a `BuildContext`
extension that is the module's single entry point, so callers never spell out a
route path. What it owns depends on the template:

| Template | Coordinator |
|---|---|
| `common` | `goTo<Feature>()` — pre-nav guard seam, marked `TODO(template)` |
| `listing` | `goTo<Feature>({filter})` — turns an `<Entity>Filter` into `<Feature>Args`, so `/product-list?keyword=shoes` and an in-app push land on the same filtered view |
| `detail` | `goTo<Feature>({object})` / `goTo<Feature>ById({id})` — in-app vs deep-link entry |

The `common` one starts as a bare forwarder. If the module never grows entry
logic, delete the file and its barrel export and push `Screen.routeName`
directly — a forwarding-only coordinator is indirection without leverage.

Two rules worth knowing:

- **The entity is a first-class input.** The state declares `List<Product>` /
  `Product?`, so the module cannot compile without it. The generator scaffolds
  the entity when it is missing and leaves an existing one untouched. Skip it
  with `--no-entity-scaffold`.
- **`detail` suffixes both the module and its usecase.** Input `product`
  produces `product_detail` and `ProductDetailUsecase.getProductDetailById`.
  Nothing here is renamed independently — the bloc imports the usecase by that
  exact path.

The generated usecase impl deliberately has no repository dependency: it
returns an empty result behind a `TODO(template)` so the module compiles and
registers in DI immediately. Generate a repository (menu option 4) and wire it
in when you have an endpoint.

### Non-interactive use

```bash
cd apps/main
dart run module_generator \
  --type listing \
  --name product_list \
  --entity Product \
  --non-interactive
```

| Flag | Effect |
|---|---|
| `--type` | `common` \| `listing` \| `detail` \| `usecase` \| `repository` \| `model` |
| `--name` | Module / usecase / repository name |
| `--dir` | Output directory (package-relative) |
| `--entity` | Domain entity the module is typed against |
| `--no-entity-scaffold` | Do not write the entity file |
| `--force` | Overwrite an existing module |
| `--non-interactive` | Never prompt; fail on a missing required value |

With no flags the interactive menu runs exactly as before.

### After generating

```bash
make gen_main   # freezed + injectable + route provider registry
make check      # analyze + format_check + test
```

The route needs no manual registration: `@FlRouteProvider()` is picked up by
the `fl_navigation` builder into `lib/presentation/route/route_providers.config.dart`.

## Project creation

Create a new project folder from this template and rewrite the copied app identity:

```bash
dart run module_generator:create_project \
  --destination ../acme_mobile \
  --display-name "Acme Mobile" \
  --slug acme_mobile \
  --base-package com.acme.mobile \
  --non-interactive
```

Omit the flags to run interactively, or add `--dry-run` to preview the planned copy
and rewrite operations. The command keeps this template checkout unchanged,
excludes local cache/VCS folders, updates source-of-truth identity files, moves
the Android Kotlin package path, refreshes generated app identifier files, and
attempts to run Flutter localization generation in the copied project.


## Asset generation

Asset generation reads Flutter assets from `pubspec.yaml` and generator settings from `assets.yaml`, then writes committed Dart accessors to the configured `assets_generated` directory.

Minimal app config:

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

```yaml
# assets.yaml
flutter:
  assets_generated: lib/generated/
  asset_generation:
    structure: tree
    recursive: true
```

Run generation from a package directory:

```bash
dart run module_generator:generate_asset --project-dir . --root apps/main
```

The default `tree` structure follows the physical folder path under `assets/`:

```text
assets/icons/ic_en.svg              -> Assets.icons.icEn
assets/images/native_splash_icon.png -> Assets.images.nativeSplashIcon
assets/images/png/logo.png          -> Assets.images.png.logo
```

Tree mode writes a single `lib/generated/assets.dart` file and removes stale type-bucket generated files.

### Flat compatibility mode

If a package still needs the old type-bucket API, set `structure: flat`:

```yaml
flutter:
  assets_generated: lib/generated/
  asset_generation:
    structure: flat
    fail_on_duplicates: true
```

Flat mode keeps accessors such as `Assets.image.logo`, `Assets.svg.icUserAvatar`, and `Assets.audio.submitSuccessSound`. Duplicate generated names fail with a report listing the colliding source paths.

### Resolution variants

The generator scans recursively by default and skips Flutter-native scale folders such as `2x/` and `3.0x/` when emitting accessors:

```text
assets/images/logo.png
assets/images/2x/logo.png
assets/images/3.0x/logo.png
```

Filename variants such as `logo@2x.png` are reported as warnings because Flutter does not treat them as native resolution variants.

### Semantic tree groups

Semantic groups are optional aliases for tree mode. They expose selected folders under a configured root without changing asset file paths.

```yaml
flutter:
  assets_generated: lib/generated/
  asset_generation:
    structure: tree
    semantic_groups:
      animation:
        - assets/lotties/
      data:
        - assets/data/
```

Example output:

```text
assets/lotties/onboarding/intro.json -> Assets.animation.onboarding.intro
assets/data/countries.json           -> Assets.data.countries
```

If a semantic group name already matches the physical folder root, the generator avoids duplicating the same tree.

## Removing unused assets

`remove_unused_asset` is dry-run by default:

```bash
dart run module_generator:remove_unused_asset --project-dir . --dry-run
```

Apply deletion only after reviewing the candidates:

```bash
dart run module_generator:remove_unused_asset --project-dir . --apply
```

By default it scans `lib/`. Add more roots when needed:

```bash
dart run module_generator:remove_unused_asset \
  --project-dir . \
  --scan-root lib \
  --scan-root test
```

The scanner keeps assets referenced by:

- raw paths such as `'assets/images/logo.png'`
- flat accessors such as `Assets.image.logo`
- tree accessors such as `Assets.images.png.logo`
- semantic aliases such as `Assets.animation.onboarding.intro`

It also conservatively keeps assets when it sees dynamic raw-path construction, for example:

```dart
'assets/images/durians/$name.png'
"assets/images/icons/${icon}.svg"
'assets/images/icons/' + name + '.svg'
```

Dynamic matches print warnings and intentionally keep matching assets instead of risking false deletion.

## Benchmarking

A manual benchmark command creates a temporary synthetic project, generates tree assets, runs unused-asset dry-run, and prints timings:

```bash
cd tools/module_generator
dart bin/benchmark_assets.dart 1000
```

The optional numeric argument controls the number of generated image assets. The benchmark is intentionally not part of the normal test suite.

## Validation

Useful checks while editing the generator:

```bash
fvm dart analyze tools/module_generator
fvm flutter test tools/module_generator
make verify_module_generator
make asset_all

dart run module_generator:create_project \
  --destination /private/tmp/acme_mobile \
  --display-name "Acme Mobile" \
  --slug acme_mobile \
  --base-package com.acme.mobile \
  --non-interactive
```

### Module generator smoke gate

`make verify_module_generator` is the end-to-end gate: it generates one module
of each type into `apps/main`, runs `generate_build_runner_config` +
`build_runner`, checks `flutter analyze` and `dart format`, asserts the routes
were registered, then deletes what it created and restores the three files
build_runner rewrites. It refuses to start unless `apps/main/build.yaml`,
`lib/di/di.config.dart`, and `lib/presentation/route/route_providers.config.dart`
are clean in git.

It is deliberately outside `make check`: it needs the Flutter toolchain and it
mutates the working tree. The template tests in `test/` cover the same ground
statically and do run under `make check`.

For package-level smoke testing:

```bash
cd apps/main
dart run module_generator:remove_unused_asset --project-dir . --dry-run
```

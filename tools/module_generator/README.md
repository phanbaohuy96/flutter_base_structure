# Module Generator

Utilities for generating projects, feature modules, exports, localization helpers, and asset accessors in this Flutter template.

## Feature modules

```bash
make run_module_generator                             # pick the package, then the menu
make run_module_generator ARGS="modules/data_source"  # skip the package menu
```

The generator scans the workspace and asks which package to generate into
before anything else, because the target package decides both where files land
and what can be generated at all — a repository is a retrofit client, and the
menu marks which packages can host one:

```text
  PACKAGES
     1  core                   retrofit
     2  apps/main              no retrofit (current)
     3  modules/data_source    retrofit
```

The type menu that follows is grouped by layer — `common` / `listing` /
`detail` modules under presentation, and repository / usecase / model under
data & domain — with a one-line description per entry. Both menus drop their
colour and box drawing when stdout is not a terminal, so piped output and CI
logs stay greppable.

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
registers in DI immediately. Generate a repository (menu option 4, or
`--type repository`) and wire it in when you have an endpoint.

### Repositories

**A repository here is a retrofit client.** Retrofit generates the
implementation from the annotations, so there is no contract-plus-impl pair to
write — the same shape `RestApiRepository`, `StorageRepository` and
`DataSourceRestApiRepository` already have. The seam that keeps transport out
of `domain/` is the use case above it, not a second interface beside it.

```bash
cd modules/data_source
dart run module_generator --type repository --name product --transport graphql
```

| Transport | Emits | Shape |
|---|---|---|
| `rest` (default) | `product_repository.dart` | `@RestApi()` abstract class with one annotated endpoint returning `ApiResponse<ProductModel>` |
| `graphql` | the same, plus `product_fragment.dart` | A one-method `@RestApi()` transport plus an `@injectable` repository that composes documents and checks `errors` |

**One endpoint, not a CRUD set.** The template used to emit five verbs against
paths no real API has, so the first thing anyone did was delete four of them.
What is left is one worked endpoint — verb, path template, `@Path`, the
envelope — with a comment saying to add the rest the same way.

GraphQL routes by document rather than by path, which is why its client has a
single `execute` and a hand-written class above it: the composition and the
error check are work no annotation can express. The fragment file declares the
field selection once and `request` appends it to every document, because a
server resolves `...ProductFields` only when the fragment travels with the
operation. Documents are raw strings (`r'''…'''`) so GraphQL's own `$variable`
syntax survives instead of being interpolated away at compile time. And the
rule worth memorising: **a failed GraphQL operation still answers HTTP 200**,
so `errors` — not the status code — decides whether the call succeeded.

#### The payload model comes with it

A client typed against `Map<String, dynamic>` is not much of a client, so the
run also scaffolds the model its endpoint returns and imports it. One prompt
picks the template — the opt-out is on the same menu:

```
  MODEL
     1  Freezed              Immutable class with copyWith and fromJson/toJson
     2  Json Serializable    Plain class with `@JsonKey` fields
  OTHER
     0  none                 Type the endpoint against `Map<String, dynamic>`
Select model [0-2] (default: 1):
Model class name (default: ProductModel):
```

The suffix goes on the class and not on the file — `ProductModel` is declared
in `models/product.dart`, matching `UserModel` in `user.dart` here and
`FarmCycle` in `farm_cycle.dart` in apps built from this template. The
directory follows the package (`lib/src/data/models` or `lib/data/models`);
override it with `--model-dir`.

An existing model is **never overwritten**: two repositories can legitimately
share one, so a second run prints `[skip] … left untouched` and leaves the
fields you filled in alone.

#### Where a repository can go

The target package must declare `retrofit`, `dio` and `core` as **runtime**
dependencies. `apps/main` carries `retrofit_generator` as a dev dependency
only, so a client generated there would build and then fail
`depend_on_referenced_packages`; the generator refuses and names the packages
that qualify. In this template that is `modules/data_source`.

#### DI is wired for you

A retrofit client's implementation is a private class, so `@Injectable` cannot
be applied to it — a `@module` provider is the only way to bind one. The
generator finds the package's module, appends the provider and adds the import:

```dart
@module
abstract class DataSourceOverrideModule {
  @injectable
  ProductRepository productRepository(Dio dio) => ProductRepository(dio);
}
```

Re-running over an existing repository leaves the module alone rather than
registering the type twice.

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
| `--package` | Workspace package to generate into (eg. `modules/data_source`); skips the package menu |
| `--name` | Module / usecase / repository name |
| `--dir` | Output directory (package-relative) |
| `--entity` | Domain entity the module is typed against |
| `--transport` | `rest` \| `graphql` — repository transport (default `rest`) |
| `--model` | `freezed` \| `json_serializable` \| `none` — payload model for a repository (default `freezed`) |
| `--model-name` | Model class name (default `<name>Model`) |
| `--model-dir` | Model output directory (default: the package's model folder) |
| `--no-entity-scaffold` | Do not write the entity file |
| `--force` | Overwrite files the run would otherwise refuse to replace |
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

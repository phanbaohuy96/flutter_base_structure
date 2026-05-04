# Module Generator

Utilities for generating feature modules, exports, localization helpers, and asset accessors in this Flutter template.

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
make asset_all
```

For package-level smoke testing:

```bash
cd apps/main
dart run module_generator:remove_unused_asset --project-dir . --dry-run
```

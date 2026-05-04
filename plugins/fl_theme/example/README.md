# fl_theme JSON playground

This example is a web-friendly playground for `fl_theme` theme configuration.

It demonstrates:

- building `AppTheme` from `ThemeJsonConfig`
- previewing FlexColorScheme-backed Material component themes
- editing the full JSON v1 schema for colors, typography, decoration, components, and screen chrome
- exporting/importing the same JSON used by the runtime design-system factory
- preview-only device frames that do not change exported theme JSON

## Run

```bash
flutter run -d chrome
```

or:

```bash
flutter run -d web-server --web-port 3000
```

## JSON flow

```dart
final config = ThemeJsonConfig.decode(jsonSource);
final designSystem = AppDesignSystem.fromJsonConfig(config);
final appTheme = AppTheme.create(
  AppThemeConfig(designSystem: designSystem),
);
```

The JSON panel accepts `#RRGGBB` and `#AARRGGBB` colors. Invalid JSON or invalid token values stay in the editor and show the parser error, so the current preview theme is not lost.

## Preview options

The device-frame controls are example-only. They wrap the preview screen with `device_frame` to show safe areas, platform density, and common device sizes, but they are intentionally not included in `ThemeJsonConfig.encode()`.

## Smoke checklist

When changing the playground, run a browser smoke check:

- open the playground on web
- switch presets and confirm controls update
- change color, radius, typography, component, and screen controls
- apply valid JSON and verify the title/preview update
- apply invalid JSON and verify an error appears without crashing
- copy or restore the current theme JSON
- toggle device frame and switch devices/orientation
- resize to narrow and wide layouts
- check the browser console for warnings/errors

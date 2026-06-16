---
name: flutter-widget-preview
description: Creates and runs previews with Flutter's official Widget Previewer using `@Preview` from `package:flutter/widget_previews.dart`. Use when the user asks to preview, showcase, inspect, or smoke-test a Flutter widget in the Widget Previewer.
license: MIT
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: widget-preview
---

# Flutter Widget Preview Skill

## When to use

- Previewing a new or changed Flutter widget interactively.
- Adding `@Preview` coverage for reusable UI, theme, or core widgets.
- Smoke-testing visual states without launching the full app.

## Tooling model

Flutter Widget Previewer renders widgets in Chrome, separate from the app. It requires Flutter 3.35+; IDE support requires Flutter 3.38+. The API is experimental, so verify https://docs.flutter.dev/tools/widget-previewer before broad preview infrastructure changes.

Do not introduce Widgetbook, Storybook, or custom preview apps unless the user explicitly asks.

## Add a preview

Import the preview API in the package that owns the widget:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Feature card')
Widget featureCardPreview() => const FeatureCard();
```

`@Preview` can annotate top-level functions, static methods, and public `Widget` constructors/factories with no required arguments. Functions and methods must return `Widget` or `WidgetBuilder`.

Use deterministic, non-secret preview data. Keep preview-only state outside production config and generated files.

## Configure previews

Use `@Preview` parameters instead of new infrastructure:

- `name` and `group` for discoverability.
- `size` for realistic constraints, especially mobile widths and unconstrained widgets.
- `textScaleFactor` for accessibility checks.
- `brightness` for light/dark variants.
- `wrapper` for required ancestors such as `MaterialApp`, localization, providers, or inherited state.
- `theme` and `localizations` for Material/Cupertino theme and locale configuration.

Apply multiple `@Preview` annotations to one function for state variants. Use custom `Preview` or `MultiPreview` annotations only when repeated configuration is already noisy.

## Project wrapper guidance

Match enough production context for the widget to render honestly:

- Add `MaterialApp`/`Scaffold` for Material widgets.
- Add app localization delegates and supported locales when the widget reads translations.
- Apply the project theme path when the widget uses `context.themeColor`, `context.textTheme`, or `ScreenForm`.
- Provide the same BLoC/provider shape the screen expects; prefer focused fake data over broad mocks.

All callback values passed to preview annotations must be public and constant so previewer code generation can read them.

## Run the previewer

From the Flutter package root that contains the previews:

```bash
fvm flutter widget-preview start
```

Check `.fvm_cache`; if `USING_FVM=1`, use `fvm flutter`, otherwise use `flutter`. IDEs expose a "Flutter Widget Preview" tab when supported.

Run the previewer yourself when the local Flutter toolchain is available. Ask the user only for setup you cannot perform.

## Limitations and verification

- Native plugins and `dart:io` / `dart:ffi` APIs are unsupported because the previewer uses Flutter Web.
- Asset loading through `dart:ui` `fromAsset` APIs must use package-based paths such as `packages/my_package/assets/foo.png`.
- Apply `size` when constraints matter; default unconstrained behavior is not stable.
- Preview default, loading, empty, error, disabled, long-text, overflow, light/dark, and text-scale states as applicable.
- Use the previewer controls for zoom, brightness, and hot restart.
- If E2E/spec verification is requested, use the `testing` skill and `flutter_skill` guidance separately.
- If you cannot run the previewer, report the exact blocker.

## Related

- [`theme-usage`](../theme-usage/SKILL.md)
- [`testing`](../testing/SKILL.md)
- [`behavioral-guardrails`](../behavioral-guardrails/SKILL.md)

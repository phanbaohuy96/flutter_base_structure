---
name: theme-usage
description: Applies the fl_theme design system via context.themeColor and context.textTheme without hard-coded colors or Material text-style names
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: theming
---

# Theme Usage Skill

## When to use

- Styling a new widget or screen.
- Picking colors, typography, button defaults, dividers, or borders.

## What this template uses

`fl_theme` (in `plugins/fl_theme/`) registers three `ThemeExtension`s on `MaterialApp`'s `ThemeData`:

- `ThemeColorExtension` → semantic palette, accessed via `context.themeColor`.
- `AppTextThemeExtension` → typography, accessed via `context.textTheme`. It extends Flutter's `TextTheme` with extra slots for inputs/buttons.
- `ScreenTheme` → screen-form + main-page defaults, accessed via `context.screenTheme`.

`fl_theme` also exports `ThemeButton.primary(context)` etc. for consistent button styling.

There is **no `BrandColor`** in this template. Always go through `context.themeColor`.

## Color usage

```dart
final colors = context.themeColor;

Container(
  color: colors.surface,
  decoration: BoxDecoration(
    border: Border.all(color: colors.borderColor),
  ),
  child: Text('Hi', style: TextStyle(color: colors.onBackground)),
);
```

`ThemeColor` exposes ~50 fields grouped roughly as:

- Brand: `primary` / `primaryVariant` / `secondary` / `themePrimary` (+ light/dark) and their `on*` pairs
- Surfaces: `surface`, `background`, `cardBackground`, `canvasColor`, `scaffoldBackgroundColor`
- Feedback: `error` / `onError`
- Chrome: `appbarBackgroundColor`, `appbarForegroundColor`, `shadowColor`, `splashColor`
- Lines: `borderColor`, `dividerColor`
- State: `disableColor`, `selected`, `selectedLabelColor`, `unselectedLabelColor`
- Buttons: `textButtonColor`, `elevatedBtn*`, `outlineButton*` (+ disabled variants)
- Form components: `checkbox*`, `chip*`, `deleteIconColor`
- Text-on-bg: `displayText`, `headlineText`, `titleText`, `bodyText`, `labelText`, `warningText`, `hyperLink`

The full list with doc comments lives in `plugins/fl_theme/lib/src/theme_color.dart`. Use IDE autocomplete on `context.themeColor.` instead of memorizing.

## Typography

`context.textTheme` returns an `AppTextTheme` (subclass of Flutter's `TextTheme`). Use the **Material 3 slot names** plus the custom inputs/buttons slots:

| Slot family | Names |
|---|---|
| Display | `displayLarge`, `displayMedium`, `displaySmall` |
| Headline | `headlineLarge`, `headlineMedium`, `headlineSmall` |
| Title | `titleLarge`, `titleMedium`, `titleSmall`, **`titleTiny`** (`titleSmall * 0.85`) |
| Body | `bodyLarge`, `bodyMedium`, `bodySmall` |
| Label | `labelLarge`, `labelMedium`, `labelSmall` |
| Inputs | `textInput`, `inputTitle`, `inputRequired`, `inputHint`, `inputError`, `helper` |
| Buttons | `buttonText` |

```dart
Text('Heading', style: context.textTheme.titleMedium);
Text('Body',    style: context.textTheme.bodyMedium);
Text('Caption', style: context.textTheme.bodySmall);
TextField(decoration: InputDecoration(
  labelStyle: context.textTheme.inputTitle,
  hintStyle:  context.textTheme.inputHint,
));
```

Customize with `copyWith`, never replace from scratch:

```dart
Text(
  'Emphasis',
  style: context.textTheme.bodyMedium?.copyWith(
    fontWeight: FontWeight.w600,
    color: context.themeColor.primary,
  ),
);
```

## Screen wrapper

Use `ScreenForm` (`core/lib/presentation/common_widget/forms/screen_form.dart`) instead of raw `Scaffold + AppBar` — it picks up `context.screenFormTheme` automatically.

```dart
ScreenForm(
  title: trans.featureTitle,
  child: ...,
);
```

`MainPageForm` is the corresponding wrapper for main-tab pages.

## Buttons

Lean on `ThemeButton` defaults rather than constructing `ButtonStyle` from scratch:

```dart
ElevatedButton(
  style: ThemeButton.primary(context),
  onPressed: _handleSubmit,
  child: Text(trans.submit),
);
```

When you do override, scope changes to `style: ButtonStyle(...)` rather than mixing `style:` with separate `textStyle:` (the latter is silently ignored).

## Checklist

- [ ] No `BrandColor.*` references — that class does not exist here.
- [ ] No raw `Colors.white`/`Colors.black` for surfaces or text — use `context.themeColor.*`.
- [ ] No invented text tokens (`titleMd`, `bodyXs`, `labelXs`) — use Material 3 names plus the input/button slots.
- [ ] Screens use `ScreenForm`/`MainPageForm`, not raw `Scaffold`.
- [ ] Buttons reuse `ThemeButton.*` defaults where possible.

## Common mistakes

- Mixing `Theme.of(context).textTheme` with `context.textTheme` — they return different types here. Stick with `context.textTheme`.
- Calling `context.themeColor` inside `initState` — extensions need a built `BuildContext`; resolve in `build`/`didChangeDependencies` only.
- Over-customizing button styling per call instead of extending `ThemeButton` once.

## Related

- [`extension-action`](../extension-action/SKILL.md)
- [`module-scaffold`](../module-scaffold/SKILL.md)

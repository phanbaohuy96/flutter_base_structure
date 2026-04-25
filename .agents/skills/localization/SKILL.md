---
name: localization
description: Adds and updates app strings through the CSV → ARB → generated AppLocalizations workflow
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: localization
---

# Localization Skill

## When to use

- Adding a translatable string to a screen.
- Renaming or removing existing keys.
- Adding a new locale.

## Workflow

The CSV is the source of truth — **never** hand-edit the generated ARB or Dart files.

```
apps/main/lib/l10n/
├── localizations.csv        # source of truth
├── intl_en.arb              # generated from CSV
├── intl_th.arb              # generated from CSV
├── localization_ext.dart    # context.l10n extension
└── generated/
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_th.dart
```

`l10n.yaml` (in `apps/main/`) wires the generation step. After editing `localizations.csv`:

```bash
make lang
```

That regenerates `intl_*.arb` and the `AppLocalizations` Dart files.

## CSV format

The header is `key,en,th` (extend with more locale columns as locales are added). One row per string.

```csv
key,en,th
inform,Inform,แจ้งเตือน
ok,Ok,ตกลง
loginRequired,Please login to continue,กรุณาเข้าสู่ระบบเพื่อดำเนินการต่อ
welcomeMessage,"Welcome, {0}!","สวัสดี {0}!"
```

Rules:

- Key names: lowerCamelCase, descriptive of meaning (`loginRequired`, not `auth_msg_2`). No prefix conventions — namespace via the key itself.
- Quote the value if it contains a comma. Quote both columns if you quote one, to keep the diff readable.
- Parameters are **positional** (`{0}`, `{1}`, …) — the generator does not support named placeholders here.
- Keep keys flat across the whole app. If two screens need slightly different copy, give them distinct keys.

## Using strings in the UI

The screen-state `StateBase` already exposes `trans` via the generator template:

```dart
class _FeatureScreenState extends StateBase<FeatureScreen> {
  late AppLocalizations trans;

  @override
  Widget build(BuildContext context) {
    trans = translate(context);
    return ScreenForm(title: trans.featureTitle, child: ...);
  }
}
```

Outside a `StateBase` (or in a child widget), use the `BuildContext` extension:

```dart
import '<path>/l10n/localization_ext.dart';

@override
Widget build(BuildContext context) {
  return Text(context.l10n.welcomeMessage('Huy'));
}
```

`core/` shipped strings sit in `core/lib/l10n/` and are reached the same way (`coreL10n` for non-context callers; see `core/lib/l10n/`).

## Adding a new locale

1. Add the column header to `localizations.csv` (e.g. `key,en,th,vi`).
2. Fill in the column for every existing row — empty cells fall back to `en`.
3. Run `make lang`. A new `intl_<locale>.arb` and `app_localizations_<locale>.dart` are produced.
4. Add the locale to `MaterialApp.supportedLocales` (already wired from `AppLocalizations.supportedLocales` in `app_delegate.dart`).

## Translation round-trip

For sending strings out to translators and folding the result back, the template ships:

- `make gen_translation` — emits a CSV with status columns ready for translators.
- `make apply_translation` — folds the completed CSV back into `localizations.csv`.

See `tools/module_generator/bin/generate_translation_csv.dart` and `apply_translation.dart` for behavior.

## Checklist

- [ ] Key added to `localizations.csv` with values for every existing locale column.
- [ ] No translation entered into the generated `*.arb` or `app_localizations_*.dart` files.
- [ ] `make lang` run; generated files staged.
- [ ] Use site reaches strings via `trans.<key>` or `context.l10n.<key>`, never a hardcoded `Text('...')`.
- [ ] Parameters use positional `{0}`, `{1}`.

## Common mistakes

- Editing `intl_en.arb` directly — the next `make lang` overwrites it.
- Using `{name}` placeholders — they aren't supported; use `{0}`.
- Sneaking in raw `Text('Save')` — pull it through the CSV.
- Trying to namespace by file path; just give the key a precise name.

## Related

- [`module-scaffold`](../module-scaffold/SKILL.md)
- [`theme-usage`](../theme-usage/SKILL.md)

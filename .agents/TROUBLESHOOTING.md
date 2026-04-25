# Troubleshooting

Common failure modes when working in this template, with the smallest
fix that gets you unstuck.

---

## Code generation

### "Could not find part of"

The `part 'foo.freezed.dart';` directive does not match the file name.
Fix: ensure each source file declares `part '<basename>.freezed.dart';`
and `part '<basename>.g.dart';` exactly matching its own filename.

### "Missing concrete implementation" (freezed)

You used `class` instead of `sealed class`.

```dart
// wrong
@freezed
class FooModel with _$FooModel { ... }

// right
@freezed
sealed class FooModel with _$FooModel { ... }
```

### "Non-nullable field must have a default value"

Add `@Default(...)`:

```dart
@Default([]) List<String> roles,
@Default(false) bool isActive,
```

### Build cache stale / "Conflicting outputs"

Clean and regenerate the affected scope:

```bash
fvm dart run build_runner clean   # inside apps/main, core, or modules/data_source
make gen_all
```

The makefile already passes `--delete-conflicting-outputs`; only worry
about this when invoking `dart run build_runner` directly.

---

## Bloc / state

### `Null check operator used on a null value` from `copyWith<T>`

You added a new concrete state class and forgot to register it in
`_factories` inside `<feature>_state.dart`. Add the matching entry:

```dart
final _factories = <Type, Function(_StateData data)>{
  FeatureInitial: (data) => FeatureInitial(data: data),
  FeatureLoaded:  (data) => FeatureLoaded(data: data),  // ← add this
};
```

### Loading spinner never disappears

`_blocListener` in the action file is missing `hideLoading()`, or a
handler called `showLoading()` (CoreDelegate fan-out) and didn't pair it with `hideLoading()` in `finally`.
Both fixes apply:

```dart
void _blocListener(BuildContext context, FeatureState state) {
  hideLoading();
  // … other reactions …
}
```

### Bloc handler swallows an error

Don't wrap the whole handler in `try { ... } catch (_) {}` — the screen
won't show a dialog. Either:

1. Let the error propagate (default path; `CoreBlocBase.onError` routes
   it via `ErrorType`).
2. Catch only the specific exception you can recover from and rethrow
   the rest.

See [`error-handling`](./skills/error-handling/SKILL.md).

---

## Navigation

### `BlocProvider.of() called with a context that does not contain a BLoC`

The route builder didn't wrap the screen in `BlocProvider`. Fix the
route file:

```dart
CustomRouter<FeatureArgs>(
  path: FeatureScreen.routeName,
  builder: (context, uri, extra) => BlocProvider<FeatureBloc>(
    create: (_) => injector.get(param1: extra),
    child: FeatureScreen(args: extra),
  ),
)
```

### "Route not found"

`routeName` is missing the leading `/`, has uppercase letters, or the
route module wasn't spread into the parent `IRoute`. Both must hold.

### Deep link query params don't reach the screen

The route is missing `extraFromUrlQueries: <Args>.fromUrlParams`. The
`buildExtra` helper in `CustomRouter` only pulls from the URI when that
hook is provided.

---

## Theming

### Reference to `BrandColor.*` won't compile

`BrandColor` does not exist in this template. Use `context.themeColor.*`
instead — see [`theme-usage`](./skills/theme-usage/SKILL.md) for the
mapping.

### `context.textTheme.titleMd` undefined

Tokens like `titleMd` / `bodyXs` / `labelXs` don't exist here. Use the
Material 3 slot names plus the `AppTextTheme` extras:

```dart
context.textTheme.titleMedium  // not titleMd
context.textTheme.bodySmall    // not bodyXs
context.textTheme.labelLarge   // not labelLg
context.textTheme.titleTiny    // extra: ~85% of titleSmall
context.textTheme.inputTitle   // extra
```

---

## Localization

### Keys don't appear in the UI

You edited `intl_en.arb` or a generated `app_localizations*.dart` file
directly — those are regenerated on `make lang` and your edits get
overwritten. Edit `apps/main/lib/l10n/localizations.csv` instead, then
run `make lang`.

### `{name}` placeholder is rendered literally

Parameters are positional in this generator — use `{0}`, `{1}`, …, then
call `trans.welcomeMessage('Huy')` with the same number of positional
arguments.

---

## Git / commit

### Pre-commit hook fails

Run the relevant target before retrying:

```bash
make format        # dart format
make gen_all       # if codegen output is stale
```

### Generated files are diff-noisy

That's expected — generated files **are** committed. Stage them with the
matching source change in the same commit so reviewers can see them.

---

## Performance

### Janky scroll / rebuilds on every frame

- Use `ListView.builder` (or `Sliver*Builder`) instead of
  `ListView(children: items.map(...).toList())`.
- Add `const` to constructors with constant arguments.
- Pull child widgets out of large `build` methods so they only rebuild
  when they need to.
- Wrap independently-animating subtrees in `RepaintBoundary`.

---

## Quick command reference

Run `make help` for the canonical list. The targets you'll most often
need: `pub_get`, `gen_all`, `lang`, `format`, `coverage_main`,
`run_module_generator`, `build`.

---
name: flutter-reviewer
description: Reviews UI-layer changes — screens, blocs, widgets, routes — against the template's StateBase + AppBlocBase + fl_theme conventions
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: code-review
---

# Flutter UI Reviewer Skill

## When to use

- A diff touches files under `presentation/`, including screens, blocs, routes, coordinators, and shared widgets.

## What to check

### Bloc shape

- [ ] Bloc extends `AppBlocBase<E, S>` (not `Bloc`/`Cubit` directly) and is `@Injectable()`.
- [ ] `<feature>_bloc.dart` has the three `part` directives (freezed/event/state) in the right order.
- [ ] `_StateData` is `@freezed sealed class` with `@Default(...)` on collections.
- [ ] Concrete state classes are `extends FeatureState` (abstract base), **not** a freezed union — and every concrete class is registered in `_factories`.
- [ ] Events extend the abstract `<X>Event` — no freezed unions for events either.
- [ ] Long handlers call `showLoading()` / `hideLoading()` (the CoreDelegate fan-out) inside `try/finally`; no ad-hoc spinners.
- [ ] Errors thrown / rethrown rather than silently caught (see `error-handling`).

### Screen widget

- [ ] Screen extends `StatefulWidget`; state extends `StateBase<T>` (not raw `State<T>`).
- [ ] `bloc` getter overridden to `BlocProvider.of(context)`.
- [ ] `static String routeName` declared, leading slash, lowercase.
- [ ] Wraps in `ScreenForm` / `MainPageForm` rather than raw `Scaffold + AppBar` unless there's a reason.
- [ ] Translates via `trans = translate(context)` or `context.l10n`; no hardcoded user-facing strings.
- [ ] Action file (`<feature>.action.dart`) is a `part of` the screen and holds `_blocListener`, `onRefresh`, etc.

### Routing

- [ ] Route extends `IRoute` and exposes `List<CustomRouter>` from `routers()`.
- [ ] `CustomRouter<Args>` (typed) when extras are non-null.
- [ ] Builder wraps the screen in `BlocProvider`; bloc created via `injector.get(...)`.
- [ ] `extraFromUrlQueries` set when the screen should be deep-linkable.
- [ ] Coordinator extension on `BuildContext` exposes typed `goToX`, all taking a `PushBehavior`.
- [ ] No direct `package:go_router/go_router.dart` imports in feature code.

### Theming

- [ ] No `BrandColor.*` references (it doesn't exist here).
- [ ] No raw `Colors.white`/`Colors.black` for surfaces or text — use `context.themeColor.*`.
- [ ] Typography uses Material 3 slot names (`titleMedium`, `bodySmall`, …) plus the `AppTextTheme` extras (`titleTiny`, `inputTitle`, `buttonText`, …) — not invented tokens like `titleMd`/`bodyXs`.
- [ ] Buttons reuse `ThemeButton.*` defaults; per-call `style:` overrides are scoped, not redundant.

### Performance

- [ ] `const` constructors used wherever inputs are constant.
- [ ] Long lists use `ListView.builder` / `Sliver*` — not `ListView(children: items.map(...).toList())`.
- [ ] Heavy subtrees consider `RepaintBoundary` when independently animating.
- [ ] No `setState` inside `build`.

### Style

- [ ] No trailing dead code, no commented-out blocks.
- [ ] Comments explain *why*, not *what*.
- [ ] `final` over `var` where the variable is not reassigned.
- [ ] Imports grouped (dart, flutter, package, project relative) and trimmed.

## Output format

Reply with:

1. **Verdict** — Approve / Minor changes / Blocking issues.
2. **Blocking issues** — file:line citations with corrected snippets.
3. **Suggestions** — non-blocking improvements.
4. **Praise** — what's done right.

## Red flags

- A new state class added to `<feature>_state.dart` without a matching `_factories` entry (runtime crash on first `copyWith<T>()`).
- A screen whose `_blocListener` doesn't call `hideLoading()` on every state — the loading indicator can stick.
- A coordinator method built with literal route paths instead of `<Screen>.routeName`.
- A `Text(...)` with a literal English string anywhere in production code.
- `setState` inside a `BlocBuilder.builder` (rebuild loop).

## Related

- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`extension-action`](../extension-action/SKILL.md)
- [`route-config`](../route-config/SKILL.md)
- [`theme-usage`](../theme-usage/SKILL.md)
- [`data-reviewer`](../data-reviewer/SKILL.md)

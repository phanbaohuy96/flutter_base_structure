---
name: extension-action
description: Extracts screen handlers and bloc listeners into a part-of "*.action.dart" extension file
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: extension-action
---

# Extension Action Skill

## When to use

- A screen file has grown past ~100 lines mixing UI + handlers.
- You need to add `_blocListener`, `onRefresh`, navigation handlers, or form callbacks to an existing screen.
- Generator output is the canonical shape — every generated module already comes with this split.

## File pair

```
<feature>_screen.dart   // UI + state controllers + part 'feature.action.dart';
<feature>.action.dart   // part of '<feature>_screen.dart';
                        // extension on _<Feature>ScreenState { ... }
```

`feature.action.dart` (note: dot, not underscore — matches generator output) is one library with the screen, so it can call private members of `_<Feature>ScreenState`.

## Reference

`<feature>_screen.dart`:

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../base/base.dart';
import '../bloc/<feature>_bloc.dart';

part '<feature>.action.dart';

class FeatureScreen extends StatefulWidget {
  static String routeName = '/feature';
  const FeatureScreen({super.key, this.args});

  final FeatureArgs? args;

  @override
  State<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends StateBase<FeatureScreen> {
  final _refreshController = RefreshController(initialRefresh: true);

  @override
  FeatureBloc get bloc => BlocProvider.of(context);

  late ThemeData _themeData;
  TextTheme get textTheme => _themeData.textTheme;
  late AppLocalizations trans;

  @override
  Widget build(BuildContext context) {
    _themeData = context.theme;
    trans = translate(context);

    return BlocListener<FeatureBloc, FeatureState>(
      listener: _blocListener,
      child: ScreenForm(
        title: trans.featureTitle,
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: onRefresh,
          child: const FeatureBody(),
        ),
      ),
    );
  }
}
```

`<feature>.action.dart`:

```dart
part of '<feature>_screen.dart';

extension on _FeatureScreenState {
  void _blocListener(BuildContext context, FeatureState state) {
    hideLoading();
    _refreshController.refreshCompleted();
  }

  void onRefresh() {
    final id = widget.args?.id ?? widget.args?.initial?.id;
    if (id != null) {
      bloc.add(GetFeatureEvent(id));
    }
  }
}
```

## What goes where

Action file (extension):
- `_blocListener(BuildContext, State)` — side effects from state changes (hide loading, complete refresh, show dialog/snackbar, navigate).
- `onRefresh`, `onLoadMore`, `onSubmit` — handlers passed to widgets.
- Form validation that dispatches events.
- Coordinator calls (`context.goToX(...)`).

Screen file:
- `build`, sub-`Widget _buildX()` helpers.
- `initState` / `dispose`.
- `TextEditingController`, `GlobalKey`, `RefreshController` declarations.
- `bloc` getter override.

## Conventions

- Extension is anonymous (`extension on _FeatureScreenState`) in generated code; if you prefer a name, use `<Feature>Action` for greppability.
- Methods can be public (`onRefresh`) when the screen passes them as callbacks, or private (`_handleX`) when only used inside the action file.
- The `part of` line MUST be the first non-comment line of the action file.

## Checklist

- [ ] `part 'feature.action.dart';` (note: dot) directive in `<feature>_screen.dart`.
- [ ] `part of '<feature>_screen.dart';` is the first line of the action file.
- [ ] `_blocListener` calls `hideLoading()` early so the screen-level loading delegate is unstuck on every state change.
- [ ] No widget `build` logic in the action file.
- [ ] No coordinator/`context.goToX` calls inside `build` — keep them in the action file.

## Related

- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`module-scaffold`](../module-scaffold/SKILL.md)
- [`route-config`](../route-config/SKILL.md)

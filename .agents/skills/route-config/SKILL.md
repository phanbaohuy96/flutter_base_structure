---
name: route-config
description: Configures routes with the IRoute / CustomRouter abstractions in core and exposes navigation via a BuildContext coordinator
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: navigation
---

# Route Configuration Skill

## When to use

- Adding a new screen to the route tree.
- Wiring sub-module routes into a parent module.
- Exposing typed navigation entry points to callers.

## What this template uses

Defined in `core/lib/presentation/route/route.dart` and re-exported via `package:core/core.dart`:

- `IRoute` — module-level provider; implements `routers()` returning `List<CustomRouter>`.
- `CustomRouter<T>` — one route entry, parameterized on the type of `extra`. Supports `path`, `builder`, `extraFromUrlQueries`, and `pathVerify`.

Navigation is invoked via `PushBehavior` strategies (`PushNamedBehavior`, `GoBehavior`, etc.) over a `BuildContext` extension — the "coordinator" pattern.

The plugin `plugins/fl_navigation/` ships a richer variant (with `routes:`, `redirect:`, `toGoRoute()` bridges) but is **not** imported by `apps/` or `core/` here — feature code uses the core variant only.

Do **not** import `package:go_router/go_router.dart` directly from feature code. Go through `IRoute`/`CustomRouter`.

## Reference: route file

```dart
import 'package:core/core.dart';

import '../../../di/di.dart';
import 'bloc/feature_bloc.dart';
import 'views/feature_screen.dart';

class FeatureRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter<FeatureArgs>(
        path: FeatureScreen.routeName,
        builder: (context, uri, extra) {
          final args = asOrNull<FeatureArgs>(extra);
          return BlocProvider<FeatureBloc>(
            create: (context) => injector.get(param1: args?.initial),
            child: FeatureScreen(args: args),
          );
        },
        extraFromUrlQueries: FeatureArgs.fromUrlParams,
      ),
    ];
  }
}
```

The `routeName` lives on the screen as `static String routeName = '/feature';`. `injector.get(param1: ...)` flows the `@factoryParam` from the bloc constructor.

## Compound modules

A parent `IRoute` aggregates child `IRoute`s with the spread operator:

```dart
class DashboardRoute extends IRoute {
  @override
  List<CustomRouter> routers() => [
    ...HomeRoute().routers(),
    ...AnalyticsRoute().routers(),
    ...SettingsRoute().routers(),
  ];
}
```

The app's top-level route registry (e.g. `apps/main/lib/presentation/route/route.dart`) does the same to bring every module into the router.

## Args + URL params

Detail-style screens use a typed `Args` class so navigation can be either object-driven or deep-link-driven:

```dart
class FeatureArgs {
  final Item? initial;
  final String? id;

  FeatureArgs({this.initial, this.id});

  factory FeatureArgs.fromUrlParams(Map<String, dynamic> queryParameters) =>
      FeatureArgs(id: asOrNull(queryParameters['id']));

  // For web, flatten to a query map; for native, pass the rich object.
  dynamic get adaptive {
    if (kIsWeb) {
      return {'id': initial?.id ?? id}..removeWhere((_, v) => v.isNullOrEmpty);
    }
    return this;
  }
}
```

`CustomRouter.buildExtra` resolves either path: a real `Args` object passed via `arguments`, or query params on a deep link.

## Coordinator (navigation extension)

Every module exposes its routes through a `BuildContext` extension so callers don't typo route paths:

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'feature.dart';

extension FeatureCoordinator on BuildContext {
  Future<T?> goToFeature<T>({
    required Item object,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      FeatureScreen.routeName,
      arguments: FeatureArgs(initial: object).adaptive,
    );
  }

  Future<T?> goToFeatureById<T>({
    required String id,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      FeatureScreen.routeName,
      arguments: FeatureArgs(id: id).adaptive,
    );
  }
}
```

Callers: `context.goToFeature(object: item)` or `context.goToFeatureById(id: '42')`.

## Checklist

- [ ] Screen has `static String routeName` starting with `/`.
- [ ] Route extends `IRoute` and uses `CustomRouter<Args>` (typed) when extras are non-null.
- [ ] Builder wraps the screen in `BlocProvider` and creates the bloc via `injector.get(...)`.
- [ ] `extraFromUrlQueries` provided when the screen should be deep-linkable.
- [ ] Coordinator extension exposes typed `goToX` methods, all taking `PushBehavior`.
- [ ] New `IRoute` registered in the parent / app-level `IRoute`.
- [ ] No direct `package:go_router/go_router.dart` imports in feature code.

## Common mistakes

- Hard-coding route paths in callers instead of going through a coordinator.
- Forgetting to spread sub-module `routers()` into the parent.
- Using `extra` without an `Args` type, then casting in the screen — it loses URL-param support.

## Related

- [`module-scaffold`](../module-scaffold/SKILL.md)
- [`extension-action`](../extension-action/SKILL.md)
- [`bloc-pattern`](../bloc-pattern/SKILL.md)

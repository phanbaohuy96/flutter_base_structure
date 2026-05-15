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

Navigation primitives live in `plugins/fl_navigation/` and are re-exported by `core/lib/presentation/route/route.dart` and `package:core/core.dart`:

- `IRoute` — module-level provider; implements `routers()` returning `List<CustomRouter>` and can expose GoRouter routes through `toGoRoutes()`.
- `FlRouteProvider` — annotation consumed by the `fl_navigation` build_runner builder for app-level provider registration.
- `CustomRouter<T>` — one route entry, parameterized on the type of `extra`. Supports `path`, `name`, `builder`, `pageBuilder`, `parentNavigatorKey`, `extraFromUrlQueries`, `pathVerify`, nested `routes`, and `redirect`.
- `buildFlGoRouter` — app-level adapter that combines generated `IRoute` providers, optional `routeProviderInterceptors`, standalone `CustomRouter`s, and raw `RouteBase`s into a `GoRouter`.
- `RouteProviderInterceptor` — runtime hook for role, platform, feature-flag, or business restrictions. It can skip an entire `IRoute` provider or replace/filter the provider's `CustomRouter` list before GoRoute conversion.
- `buildRequiredRouteExtra<T>` — core helper for screens that require a typed `extra`; it returns `UnsupportedPage` instead of scattering unsafe casts.

Navigation is invoked via `PushBehavior` strategies (`PushNamedBehavior`, `PushReplacementNamedBehavior`, `PushNamedAndRemoveUntilBehavior`, etc.) over a `BuildContext` extension — the coordinator pattern.

GoRouter-backed pushes default to path/location navigation. Set `goRouterNavigationTarget: GoRouterNavigationTarget.name` only when the route has a `name` and named navigation is required.

Do **not** import `package:go_router/go_router.dart` directly from feature code. Go through `IRoute`/`CustomRouter` and the `fl_navigation`/`core` exports.

## Reference: route file

```dart
import 'package:core/core.dart';

import '../../../di/di.dart';
import 'bloc/feature_bloc.dart';
import 'views/feature_screen.dart';

@FlRouteProvider()
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

For routes that cannot render without a typed extra, use the shared helper instead of repeating casts:

```dart
CustomRouter<FeatureArgs>(
  path: FeatureScreen.routeName,
  builder: (context, uri, extra) {
    return buildRequiredRouteExtra<FeatureArgs>(
      extra,
      (args) => FeatureScreen(args: args),
    );
  },
)
```

## Compound modules

A parent `IRoute` aggregates child `IRoute`s with the spread operator:

```dart
@FlRouteProvider(isRoot: true)
class DashboardRoute extends IRoute {
  @override
  List<CustomRouter> routers() => [
    ...HomeRoute().routers(),
    ...AnalyticsRoute().routers(),
    ...SettingsRoute().routers(),
  ];
}
```

App-level providers use `@FlRouteProvider()`. Dependency aggregators that should be included by an app use `@FlRouteProvider(isRoot: true)`. Run `make gen_main` to let build_runner update `route_providers.config.dart`, then pass `buildAppRouteProviders()` into `buildFlGoRouter` so registration stays generated.

## Runtime route restrictions

Do not manually compose generated provider accessors for role, platform, feature-flag, or business-rule gating. Keep `buildAppRouteProviders()` as the source of all generated providers and pass runtime `routeProviderInterceptors` to `buildFlGoRouter`.

Provider-level filtering removes a whole `IRoute`:

```dart
class AppRouteProviderInterceptor extends RouteProviderInterceptor {
  const AppRouteProviderInterceptor(this.currentUser);

  final UserAccount? currentUser;

  @override
  void onResolve(
    RouteProviderResolution resolution,
    RouteProviderInterceptorHandler handler,
  ) {
    if (resolution.provider is FarmRoute && currentUser?.identityId == null) {
      handler.skip();
      return;
    }

    handler.next(resolution);
  }
}
```

Router-level filtering keeps a provider but removes selected `CustomRouter`s:

```dart
if (resolution.provider is AuthenticationRoute) {
  handler.next(
    resolution.copyWith(
      routers: resolution.routers.where((router) {
        return router.path != RegisterScreen.routeName;
      }).toList(),
    ),
  );
  return;
}
```

Use `handler.next(...)` to continue the chain, `handler.resolve(...)` to stop with a final resolution, `handler.skip()` to remove the provider, and `handler.reject(...)` to fail route construction.

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
- [ ] Route/coordinator methods have concise Dartdoc when they are newly introduced public APIs.
- [ ] New top-level `IRoute` has `@FlRouteProvider()` and `make gen_main` was run to refresh the generated provider registry.
- [ ] Route restrictions use runtime `routeProviderInterceptors`, not manual generated-provider lists.
- [ ] Required extras use `buildRequiredRouteExtra<T>` or another shared guard instead of repeated unsafe casts.
- [ ] Web-deep-linkable routes have `extraFromUrlQueries`; when the user requests E2E, verify them with a browser smoke check.
- [ ] No direct `package:go_router/go_router.dart` imports in feature code.

## Common mistakes

- Hard-coding route paths in callers instead of going through a coordinator.
- Forgetting to spread sub-module `routers()` into the parent.
- Adding a top-level route provider without `@FlRouteProvider()` or without regenerating `route_providers.config.dart`.
- Manually composing generated provider accessors for route restrictions instead of using `routeProviderInterceptors`.
- Using `extra` without an `Args` type, then casting in the screen — it loses URL-param support.
- Adding a GoRouter named push without setting `name` on the matching `CustomRouter`.

## Related

- [`module-scaffold`](../module-scaffold/SKILL.md)
- [`extension-action`](../extension-action/SKILL.md)
- [`bloc-pattern`](../bloc-pattern/SKILL.md)

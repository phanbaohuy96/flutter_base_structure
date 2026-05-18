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

  const FeatureArgs({this.initial, this.id});

  factory FeatureArgs.fromUrlParams(Map<String, dynamic> queryParameters) =>
      FeatureArgs(id: asOrNull(queryParameters['id']));

  // For web, flatten to a query map; for native, pass the rich object.
  // The canonical getter name is `adaptiveArguments` (never `adaptive`).
  dynamic get adaptiveArguments {
    if (kIsWeb) {
      return {'id': initial?.id ?? id}..removeWhere((_, v) => v.isNullOrEmpty);
    }
    return this;
  }

  /// String form for `GoRoute.redirect` callbacks (and interceptors that
  /// wrap them) that can't pass a typed `extra`.
  String toRouteLocation() {
    return Uri(
      path: FeatureScreen.routeName,
      queryParameters: id == null ? null : {'id': id},
    ).toString();
  }
}
```

`CustomRouter.buildExtra` resolves either path: a real `Args` object passed via `arguments`, or query params on a deep link. Coordinators and interceptors should pick the right Args output for their consumer — `adaptiveArguments` for `pushBehavior.push(arguments: ...)`, `toRouteLocation()` for `redirect` callbacks that must return a string URL.

## Coordinator (navigation extension)

Coordinators are not free. Add one only for **compound modules** or modules with non-trivial entry logic (parameter translation, pre-nav guards, post-nav handling). A one-line `pushBehavior.push(context, FeatureScreen.routeName)` wrapper is shallow — call the screen route directly from feature code instead. See `CONTEXT.md`.

When a coordinator exists, it owns:

1. `*Args` construction (`adaptiveArguments` for the platform-correct payload).
2. Pre-nav guards — e.g. signin's coordinator reads the storage seam and short-circuits to the post-login destination when a valid token is already present.
3. Post-nav handling — refreshing parent state if the child mutated something the caller needs.

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../di/di.dart';
import '../../../../data/data_source/local/local_data_manager.dart';
import 'feature.dart';

extension FeatureCoordinator on BuildContext {
  Future<T?> goToFeature<T>({
    required Item object,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      FeatureScreen.routeName,
      arguments: FeatureArgs(initial: object).adaptiveArguments,
    );
  }
}
```

The authentication coordinator is the canonical pre-nav-guard example — it consults `injector<LocalDataManager>().token` before deciding whether to push signin or jump straight to the post-login destination.

## Auth-gate interceptor

See `CONTEXT.md` §Auth-gate interceptor for the definition. The shipped example lives at `apps/main/lib/presentation/route/auth_gate_route_interceptor.dart` and wraps each protected `CustomRouter`'s `redirect` so token enforcement stays at the plumbing level — feature screens never check auth state in `build`.

```dart
class AuthGateRouteInterceptor extends RouteProviderInterceptor {
  static bool _defaultIsProtected(IRoute provider) =>
      provider is! AuthenticationRoute;

  CustomRouter _guardRouter(CustomRouter router) {
    final existingRedirect = router.redirect;
    return router.copyWith(
      redirect: (context, state) {
        if (localDataManager.isAuthenticated) {
          return existingRedirect?.call(context, state);
        }
        return SigninRouteArgs(redirectTo: state.uri.toString())
            .toRouteLocation();
      },
    );
  }
}
```

Token presence is read via the **synchronous** `isAuthenticated` getter on the storage seam — `GoRoute.redirect` cannot await. That means the seam's async `token` getter must be warmed once during app init so the in-memory cache is populated before the first navigation (see `data-layer`).

## Checklist

- [ ] Screen has `static String routeName` starting with `/`.
- [ ] Route extends `IRoute` and uses `CustomRouter<Args>` (typed) when extras are non-null.
- [ ] Builder wraps the screen in `BlocProvider` and creates the bloc via `injector.get(...)`.
- [ ] `extraFromUrlQueries` provided when the screen should be deep-linkable.
- [ ] Coordinator added only for compound modules or modules with non-trivial entry logic — simple modules call `pushBehavior.push(context, routeName)` directly.
- [ ] When a coordinator exists, it exposes typed `goToX` methods, all taking `PushBehavior`, and passes `Args(...).adaptiveArguments` (not the older `adaptive`).
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

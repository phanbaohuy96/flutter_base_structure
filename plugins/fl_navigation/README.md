# fl_navigation

Navigation utilities for this Flutter template, built on top of `go_router`.

## Runtime router

Use `buildFlGoRouter` to combine generated route providers, standalone `CustomRouter`s, and raw `RouteBase`s:

```dart
final router = buildFlGoRouter(
  routeProviders: buildAppRouteProviders(),
  routeProviderInterceptors: const [AppRouteProviderInterceptor()],
  initialLocation: '/signin',
);
```

`CustomRouter` wraps route metadata, extra parsing, page builders, nested routes, redirects, and GoRouter named navigation. Set both `path` and `name` when a route should support `GoRouterNavigationTarget.name`.

## Route-provider generation

Annotate app-local route providers with `@FlRouteProvider()`:

```dart
@FlRouteProvider()
class AuthenticationRoute extends IRoute {
  @override
  List<CustomRouter> routers() => [...];
}
```

Dependency packages should expose only root aggregators with `@FlRouteProvider(isRoot: true)`:

```dart
@FlRouteProvider(isRoot: true)
class CoreRoute extends IRoute {
  @override
  List<CustomRouter> routers() => [...];
}
```

Enable the builder in the consuming package `build.yaml`:

```yaml
targets:
  $default:
    builders:
      fl_navigation:route_provider_builder:
        generate_for:
          - lib/$lib$
```

The generated registry is written to `lib/presentation/route/route_providers.config.dart` by default.

Supported builder options:

```yaml
options:
  function_name: buildAppRouteProviders
  registry_class_name: AppRouteProviders
  include_path_dependencies: true
  extra_scan_paths:
    - ../shared_routes
```

## Route-provider interceptors

Use `routeProviderInterceptors` for runtime restrictions such as flavor, role, platform, or feature flags. Interceptors can continue, replace, skip, or reject a provider resolution:

```dart
class AppRouteProviderInterceptor extends RouteProviderInterceptor {
  const AppRouteProviderInterceptor();

  @override
  void onResolve(
    RouteProviderResolution resolution,
    RouteProviderInterceptorHandler handler,
  ) {
    handler.next(resolution);
  }
}
```

Generated registration should stay automatic; prefer interceptors over manually composing generated provider accessors.

## Navigation helpers

`PushNamedBehavior`, `PushReplacementNamedBehavior`, and `PushNamedAndRemoveUntilBehavior` prefer GoRouter when available and fall back to Flutter `Navigator` APIs otherwise. On web, map arguments are mirrored into query parameters for URL-friendly navigation.

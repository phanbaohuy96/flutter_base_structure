import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route.dart';

/// Builds a [GoRouter] from fl_navigation route providers and custom routes.
///
/// [optionURLReflectsImperativeAPIs] keeps browser URLs in sync when callers
/// use imperative navigation such as `push`, `pushReplacement`, or `go`.
GoRouter buildFlGoRouter({
  List<IRoute> routeProviders = const [],
  List<RouteProviderInterceptor> routeProviderInterceptors = const [],
  List<CustomRouter> routers = const [],
  List<RouteBase> routes = const [],
  Codec<Object?, Object?>? extraCodec,
  GoExceptionHandler? onException,
  GoRouterPageBuilder? errorPageBuilder,
  GoRouterWidgetBuilder? errorBuilder,
  GoRouterRedirect? redirect,
  Listenable? refreshListenable,
  int redirectLimit = 5,
  bool routerNeglect = false,
  String? initialLocation,
  bool overridePlatformDefaultLocation = false,
  Object? initialExtra,
  List<NavigatorObserver>? observers,
  bool debugLogDiagnostics = false,
  GlobalKey<NavigatorState>? navigatorKey,
  String? restorationScopeId,
  bool requestFocus = true,
  bool optionURLReflectsImperativeAPIs = true,
}) {
  GoRouter.optionURLReflectsImperativeAPIs = optionURLReflectsImperativeAPIs;

  final goRoutes = <RouteBase>[
    ...routeProviders.expand(
      (routeProvider) =>
          _resolveRouteProviderRoutes(routeProvider, routeProviderInterceptors),
    ),
    ...routers.map((router) => router.toGoRoute()),
    ...routes,
  ];

  return GoRouter(
    routes: goRoutes,
    extraCodec: extraCodec,
    onException: onException,
    errorPageBuilder: errorPageBuilder,
    errorBuilder: errorBuilder,
    redirect: redirect,
    refreshListenable: refreshListenable,
    redirectLimit: redirectLimit,
    routerNeglect: routerNeglect,
    initialLocation: initialLocation,
    overridePlatformDefaultLocation: overridePlatformDefaultLocation,
    initialExtra: initialExtra,
    observers: observers,
    debugLogDiagnostics: debugLogDiagnostics,
    navigatorKey: navigatorKey,
    restorationScopeId: restorationScopeId,
    requestFocus: requestFocus,
  );
}

Iterable<GoRoute> _resolveRouteProviderRoutes(
  IRoute routeProvider,
  List<RouteProviderInterceptor> interceptors,
) {
  final resolution = _resolveRouteProvider(
    RouteProviderResolution(
      provider: routeProvider,
      routers: routeProvider.routers(),
    ),
    interceptors,
    0,
  );

  if (resolution == null) {
    return const <GoRoute>[];
  }
  return resolution.routers.map((router) => router.toGoRoute());
}

RouteProviderResolution? _resolveRouteProvider(
  RouteProviderResolution resolution,
  List<RouteProviderInterceptor> interceptors,
  int index,
) {
  if (index >= interceptors.length) {
    return resolution;
  }

  RouteProviderResolution? result;
  final handler = _RouteProviderInterceptorChainHandler(
    onNext: (nextResolution) {
      result = _resolveRouteProvider(nextResolution, interceptors, index + 1);
    },
    onResolve: (resolvedResolution) {
      result = resolvedResolution;
    },
    onSkip: () {
      result = null;
    },
  );

  interceptors[index].onResolve(resolution, handler);
  if (!handler.isCompleted) {
    throw StateError('RouteProviderInterceptor must call handler.');
  }
  return result;
}

class _RouteProviderInterceptorChainHandler
    implements RouteProviderInterceptorHandler {
  _RouteProviderInterceptorChainHandler({
    required this.onNext,
    required this.onResolve,
    required this.onSkip,
  });

  final ValueSetter<RouteProviderResolution> onNext;
  final ValueSetter<RouteProviderResolution> onResolve;
  final VoidCallback onSkip;
  bool isCompleted = false;

  @override
  void next(RouteProviderResolution resolution) {
    _complete(() => onNext(resolution));
  }

  @override
  void resolve(RouteProviderResolution resolution) {
    _complete(() => onResolve(resolution));
  }

  @override
  void skip() {
    _complete(onSkip);
  }

  @override
  void reject(Object error, [StackTrace? stackTrace]) {
    _complete(() {
      Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
    });
  }

  void _complete(VoidCallback action) {
    if (isCompleted) {
      throw StateError('RouteProviderInterceptorHandler completed twice.');
    }
    isCompleted = true;
    action();
  }
}

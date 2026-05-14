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
    ...routeProviders.expand((routeProvider) => routeProvider.toGoRoutes()),
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

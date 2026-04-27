import 'dart:developer';

import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Function signature for verifying if a URI path matches a route's
/// requirements.
/// Returns true if the URI is valid for the route, false otherwise.
typedef RoutePathVerify = bool Function(Uri);

/// Function signature for building a widget from route data.
///
/// Parameters:
/// - [BuildContext]: The build context
/// - [Uri]: The URI of the route
/// - [dynamic extra]: Additional data passed to the route
typedef CoreRouteBuilder = Widget Function(BuildContext, Uri, dynamic extra);

/// Function signature for extracting extra data from URL query parameters.
///
/// This function converts URL query parameters into a strongly-typed object
/// that can be used by the route.
typedef ExtraFromUrlQueries<T> =
    T? Function(Map<String, dynamic> queryParameters);

/// A custom router implementation for handling navigation in the application.
///
/// The [CustomRouter] class provides functionality for routing to specific
/// screens based on URI paths, handling extra data, and verifying route
/// compatibility. It also supports integration with GoRouter.
///
/// Type parameter [T] specifies the type of extra data expected by this route.
class CustomRouter<T> {
  /// The base path that this router handles.
  /// Routes will match if the URI path starts with this value or if a custom
  /// [pathVerify] function returns true.
  final String path;

  /// The function that builds the widget for this route.
  final CoreRouteBuilder _builder;

  /// Optional function to extract extra data from URL query parameters.
  /// This allows routes to accept parameters via URL query strings.
  final ExtraFromUrlQueries<T>? extraFromUrlQueries;

  /// Optional custom function to verify if a URI path is valid for this route.
  /// If provided, this overrides the default path matching behavior.
  final RoutePathVerify? pathVerify;

  /// Optional list of sub-routes for GoRouter integration.
  final List<CustomRouter>? routes;

  /// Optional redirect function for GoRouter integration.
  final String? Function(BuildContext, GoRouterState)? redirect;

  /// Creates a new [CustomRouter] instance.
  ///
  /// Parameters:
  /// - [path]: The base path this router handles
  /// - [builder]: Function to build the widget for this route
  /// - [extraFromUrlQueries]: Optional function to extract extra data from URL
  ///   queries
  /// - [pathVerify]: Optional custom function to verify URI path validity
  /// - [routes]: Optional list of sub-routes for nested routing
  /// - [redirect]: Optional redirect function for GoRouter
  const CustomRouter({
    required this.path,
    required CoreRouteBuilder builder,
    this.extraFromUrlQueries,
    this.pathVerify,
    this.routes,
    this.redirect,
  }) : _builder = builder;

  Widget build(BuildContext context, Uri uri, dynamic extra) {
    return _builder(context, uri, buildExtra(uri, extra));
  }

  /// Converts this CustomRouter to a GoRoute for use with GoRouter.
  ///
  /// This method creates a GoRoute that integrates with the existing
  /// CustomRouter functionality while providing GoRouter compatibility.
  ///
  /// Returns a [GoRoute] configured with this router's settings.
  GoRoute toGoRoute() {
    return GoRoute(
      path: path,
      builder: (context, state) {
        final uri = state.uri;
        final extra = buildExtra(uri, state.extra);
        return _builder(context, uri, extra);
      },
      redirect: redirect,
      routes: routes?.map((route) => route.toGoRoute()).toList() ?? [],
    );
  }

  /// Builds the extra data for this route based on the URI and provided extra
  /// parameter.
  ///
  /// This method determines what extra data to use based on the following
  /// logic:
  /// 1. If extra data is not null:
  ///    a. If it's a Map, process it through [extraFromUrlQueries] if available
  ///    b. Otherwise, return the extra data as is
  /// 2. If extra data is null and [extraFromUrlQueries] is defined, construct
  ///    extra data from URI query parameters
  /// 3. Otherwise, returns the original extra data (which may be null)
  ///
  /// Parameters:
  /// - [uri]: The URI that may contain query parameters.
  /// - [extra]: The original extra data passed to the route.
  ///
  /// Returns:
  /// The processed extra data to be used by the route.
  dynamic buildExtra(Uri uri, dynamic extra) {
    // Case 1: Extra data is provided
    if (extra != null) {
      // Case 1a: If extra is a Map, try to convert it using extraFromUrlQueries
      if (extra is Map) {
        return extraFromUrlQueries?.call(Map.from(extra)) ?? extra;
      }

      // Case 1b: Extra is not a Map, return it as is
      return extra;
    }

    // Case 2: No extra data provided, try to extract from URI query parameters
    return extraFromUrlQueries?.call(uri.queryParameters) ?? extra;
  }

  /// Checks if a given [uri] can be launched with the current route
  /// configuration.
  ///
  /// The method validates two conditions:
  /// 1. The URI must be valid for this route (using [canLaunchUri]).
  /// 2. If [T] is a specific type (not dynamic), the [extra] parameter
  ///    must be convertible to that type using [buildExtra].
  ///
  /// Parameters:
  /// - [uri]: The URI to check for launch compatibility.
  /// - [extra]: Additional data to be passed to the route, which will be
  ///   converted using [buildExtra].
  ///
  /// Returns:
  /// - `true` if the URI can be launched with this route.
  /// - `false` otherwise.
  ///
  /// In debug mode, logs a warning if the extra parameter type doesn't match
  /// the expected type [T].
  bool canLaunch(Uri uri, dynamic extra) {
    if (!canLaunchUri(uri)) {
      return false;
    }

    if (identical(T, dynamic)) {
      return true;
    }

    final extraBuilt = buildExtra(uri, extra);

    final check = extraBuilt is T;

    if (kDebugMode && !check) {
      log('''Access to [$path] required extra as $T but found $extraBuilt''');
    }

    return check;
  }

  /// Verifies if the given URI is valid for this route.
  ///
  /// This method checks if the URI is compatible with this route based on
  /// the following logic:
  /// 1. If a custom [pathVerify] function is provided, uses that for validation
  /// 2. Otherwise, checks if the URI path starts with this route's [path].
  ///
  /// Parameters:
  /// - [uri]: The URI to check for compatibility with this route.
  ///
  /// Returns:
  /// - `true` if the URI is valid for this route.
  /// - `false` otherwise.
  bool canLaunchUri(Uri uri) {
    if (pathVerify != null) {
      return pathVerify!(uri);
    }

    return uri.path.isNotEmpty && uri.path.paramCase.startsWith(path.paramCase);
  }
}

/// Interface for route providers with GoRouter support.
///
/// Classes implementing this interface are responsible for defining
/// the available routes for a specific module or feature, with support
/// for both CustomRouter and GoRouter integration.
abstract class IRoute {
  /// Returns a list of [CustomRouter] objects that define the routes
  /// available in this module or feature.
  List<CustomRouter> routers();

  /// Converts the routers to GoRoutes for GoRouter integration.
  ///
  /// This method provides a convenient way to get GoRoute objects
  /// from the CustomRouter definitions.
  List<GoRoute> toGoRoutes() {
    return routers().map((router) => router.toGoRoute()).toList();
  }
}

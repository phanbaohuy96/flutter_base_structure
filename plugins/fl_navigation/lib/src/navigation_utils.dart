import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Controls how GoRouter interprets destination strings.
enum GoRouterNavigationTarget { location, name }

/// Rebuilds [uri] with [mutate] applied to its query parameters.
///
/// `Uri.replace(queryParameters: {})` keeps `hasQuery == true` for an
/// explicit-but-empty map, which leaves a dangling `?` in `toString()`
/// (e.g. `/orders?` instead of `/orders`) — only omitting `queryParameters`
/// entirely drops the `?`. Route redirects that strip query params (locale,
/// tracking params, etc.) should go through this helper instead of calling
/// `Uri.replace` directly, so that mistake can't be reintroduced per call site.
Uri withQueryParameters(
  Uri uri,
  Map<String, String> Function(Map<String, String> query) mutate,
) {
  final nextQueryParameters = mutate(
    Map<String, String>.from(uri.queryParameters),
  );
  if (nextQueryParameters.isNotEmpty) {
    return uri.replace(queryParameters: nextQueryParameters);
  }
  // Uri.replace can't clear a query outright (a `null` query/queryParameters
  // means "keep the existing one"), so the empty case has to be rebuilt from
  // scratch — but every other component must be copied across explicitly,
  // or an absolute uri would silently lose its scheme/authority here.
  return Uri(
    scheme: uri.hasScheme ? uri.scheme : null,
    userInfo: uri.hasAuthority && uri.userInfo.isNotEmpty ? uri.userInfo : null,
    host: uri.hasAuthority ? uri.host : null,
    port: uri.hasAuthority ? uri.port : null,
    path: uri.path,
    fragment: uri.hasFragment ? uri.fragment : null,
  );
}

abstract class PushBehavior {
  const PushBehavior({
    this.rootNavigator = false,
    this.useGoRouter = true,
    this.goRouterNavigationTarget = GoRouterNavigationTarget.location,
  });

  final bool rootNavigator;
  final bool useGoRouter;
  final GoRouterNavigationTarget goRouterNavigationTarget;

  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  });

  Uri buildUri(String routeName, Object? arguments) {
    // routeName may already be a full "path?query" location (e.g. a resolved
    // sign-in redirect target), so parse it instead of forcing it into
    // `path:`, which would percent-encode any embedded "?" into "%3F". Only
    // do this for absolute (leading "/") route names: a bare name containing
    // a colon before any slash (e.g. "settings:advanced") would otherwise be
    // misparsed by Uri.tryParse as having a URI scheme.
    final base = routeName.startsWith('/')
        ? (Uri.tryParse(routeName) ?? Uri(path: routeName))
        : Uri(path: routeName);
    final extraQueryParameters = arguments?.let((it) {
      if (it is Map<String, dynamic> && kIsWeb) {
        return Map<String, dynamic>.from(it);
      }
      return null;
    });
    if (extraQueryParameters == null || extraQueryParameters.isEmpty) {
      return base;
    }
    return base.replace(
      queryParameters: {...base.queryParameters, ...extraQueryParameters},
    );
  }

  String buildLocation(String routeName, Object? arguments) {
    return buildUri(routeName, arguments).toString();
  }

  Map<String, String> buildQueryParameters(Object? arguments) {
    return buildUri('', arguments).queryParameters;
  }

  GoRouter? _maybeGoRouter(BuildContext context) {
    try {
      return GoRouter.of(context);
    } catch (_) {
      return null;
    }
  }

  Future<T?> _goRouterPush<T extends Object?>(
    GoRouter router,
    String routeName, {
    Object? arguments,
  }) {
    switch (goRouterNavigationTarget) {
      case GoRouterNavigationTarget.location:
        return router.push<T>(
          buildLocation(routeName, arguments),
          extra: arguments,
        );
      case GoRouterNavigationTarget.name:
        return router.pushNamed<T>(
          routeName,
          queryParameters: buildQueryParameters(arguments),
          extra: arguments,
        );
    }
  }

  Future<T?> _goRouterPushReplacement<T extends Object?>(
    GoRouter router,
    String routeName, {
    Object? arguments,
  }) {
    switch (goRouterNavigationTarget) {
      case GoRouterNavigationTarget.location:
        return router.pushReplacement<T>(
          buildLocation(routeName, arguments),
          extra: arguments,
        );
      case GoRouterNavigationTarget.name:
        return router.pushReplacementNamed<T>(
          routeName,
          queryParameters: buildQueryParameters(arguments),
          extra: arguments,
        );
    }
  }

  Future<T?> _goRouterGo<T extends Object?>(
    GoRouter router,
    String routeName, {
    Object? arguments,
  }) {
    switch (goRouterNavigationTarget) {
      case GoRouterNavigationTarget.location:
        router.go(buildLocation(routeName, arguments), extra: arguments);
      case GoRouterNavigationTarget.name:
        router.goNamed(
          routeName,
          queryParameters: buildQueryParameters(arguments),
          extra: arguments,
        );
    }
    return Future<T?>.value();
  }
}

/// Provide the wrapper as a push behavior
///
/// Ref: [Navigator.pushNamed] or [GoRouter.push]
class PushNamedBehavior extends PushBehavior {
  const PushNamedBehavior({
    super.rootNavigator = false,
    super.useGoRouter = true,
    super.goRouterNavigationTarget = GoRouterNavigationTarget.location,
  });

  @override
  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    if (useGoRouter) {
      final router = _maybeGoRouter(context);
      if (router != null) {
        return _pushWithGoRouter<T>(router, routeName, arguments: arguments);
      }
    }

    final uri = buildUri(routeName, arguments);

    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushNamed(uri.toString(), arguments: arguments).then(asOrNull);
  }

  Future<T?> _pushWithGoRouter<T extends Object?>(
    GoRouter router,
    String routeName, {
    Object? arguments,
  }) {
    return _goRouterPush<T>(router, routeName, arguments: arguments);
  }
}

/// Provide the wrapper as a push behavior
///
/// Ref: [Navigator.pushReplacementNamed] or [GoRouter.pushReplacement]
class PushReplacementNamedBehavior<TO extends Object?> extends PushBehavior {
  const PushReplacementNamedBehavior({
    this.result,
    super.rootNavigator = false,
    super.useGoRouter = true,
    super.goRouterNavigationTarget = GoRouterNavigationTarget.location,
  });

  /// If non-null, `result` will be used as the result of the route that is
  /// removed; the future that had been returned from pushing that old route
  /// will complete with `result`. Routes such as dialogs or popup menus
  /// typically use this mechanism to return the value selected by the user to
  /// the widget that created their route. The type of `result`, if provided,
  /// must match the type argument of the class of the old route (`TO`).
  ///
  /// Ref: [Navigator.pushReplacementNamed.result]
  final TO? result;

  @override
  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    if (useGoRouter) {
      final router = _maybeGoRouter(context);
      if (router != null) {
        return _pushReplacementWithGoRouter<T>(
          router,
          routeName,
          arguments: arguments,
        );
      }
    }

    final uri = buildUri(routeName, arguments);

    return Navigator.of(context, rootNavigator: rootNavigator)
        .pushReplacementNamed(
          uri.toString(),
          arguments: arguments,
          result: result,
        )
        .then(asOrNull);
  }

  Future<T?> _pushReplacementWithGoRouter<T extends Object?>(
    GoRouter router,
    String routeName, {
    Object? arguments,
  }) {
    return _goRouterPushReplacement<T>(router, routeName, arguments: arguments);
  }
}

/// Provide the wrapper as a push behavior
///
/// Ref: [Navigator.pushNamedAndRemoveUntil] or [GoRouter.go]
class PushNamedAndRemoveUntilBehavior<TO extends Object?> extends PushBehavior {
  const PushNamedAndRemoveUntilBehavior(
    this.predicate, {
    super.rootNavigator = false,
    super.useGoRouter = true,
    super.goRouterNavigationTarget = GoRouterNavigationTarget.location,
  }) : removeAll = false;

  const PushNamedAndRemoveUntilBehavior._removeAll({
    super.rootNavigator = false,
    super.useGoRouter = true,
    super.goRouterNavigationTarget = GoRouterNavigationTarget.location,
  }) : predicate = _removeAllPredicate,
       removeAll = true;

  factory PushNamedAndRemoveUntilBehavior.removeAll({
    bool rootNavigator = false,
    bool useGoRouter = true,
    GoRouterNavigationTarget goRouterNavigationTarget =
        GoRouterNavigationTarget.location,
  }) => PushNamedAndRemoveUntilBehavior._removeAll(
    rootNavigator: rootNavigator,
    useGoRouter: useGoRouter,
    goRouterNavigationTarget: goRouterNavigationTarget,
  );

  /// The predicate may be applied to the same route more than once if
  /// [Route.willHandlePopInternally] is true.
  ///
  /// Ref: [Navigator.pushNamedAndRemoveUntil.predicate]
  final RoutePredicate predicate;

  /// Whether this behavior should replace the current GoRouter stack.
  final bool removeAll;

  @override
  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    if (useGoRouter && removeAll) {
      final router = _maybeGoRouter(context);
      if (router != null) {
        return _goRouterGo<T>(router, routeName, arguments: arguments);
      }
    }

    final uri = buildUri(routeName, arguments);
    return Navigator.of(context, rootNavigator: rootNavigator)
        .pushNamedAndRemoveUntil(
          uri.toString(),
          predicate,
          arguments: arguments,
        )
        .then(asOrNull);
  }
}

bool _removeAllPredicate(Route<dynamic> route) => false;

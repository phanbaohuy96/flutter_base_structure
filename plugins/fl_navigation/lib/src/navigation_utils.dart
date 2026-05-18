import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Controls how GoRouter interprets destination strings.
enum GoRouterNavigationTarget { location, name }

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
    return Uri(
      path: routeName,
      queryParameters: arguments?.let((it) {
        if (it is Map<String, dynamic> && kIsWeb) {
          return Map.from(it);
        }
        return null;
      }),
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

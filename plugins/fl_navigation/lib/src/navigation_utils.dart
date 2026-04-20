import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class PushBehavior {
  const PushBehavior({
    this.rootNavigator = false,
    this.useGoRouter = true,
  });

  final bool rootNavigator;
  final bool useGoRouter;

  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  });

  Uri buildUri(String routeName, Object? arguments) {
    return Uri(
      path: routeName,
      queryParameters: arguments?.let(
        (it) {
          if (it is Map<String, dynamic> && kIsWeb) {
            return Map.from(it);
          }
          return null;
        },
      ),
    );
  }

  /// Helper function to check if GoRouter is available
  bool _hasGoRouter(BuildContext context) {
    try {
      GoRouter.of(context);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provide the wrapper as a push behavior
///
/// Ref: [Navigator.pushNamed] or [GoRouter.push]
class PushNamedBehavior extends PushBehavior {
  const PushNamedBehavior({
    super.rootNavigator = false,
    super.useGoRouter = true,
  });

  @override
  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    if (useGoRouter && _hasGoRouter(context)) {
      return _pushWithGoRouter<T>(context, routeName, arguments: arguments);
    }

    final uri = buildUri(routeName, arguments);

    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushNamed(uri.toString(), arguments: arguments).then(asOrNull);
  }

  Future<T?> _pushWithGoRouter<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return GoRouter.of(context).push<T>(routeName, extra: arguments);
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
    if (useGoRouter && _hasGoRouter(context)) {
      return _pushReplacementWithGoRouter<T>(
        context,
        routeName,
        arguments: arguments,
      );
    }

    final uri = buildUri(routeName, arguments);

    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    )
        .pushReplacementNamed(
          uri.toString(),
          arguments: arguments,
          result: result,
        )
        .then(asOrNull);
  }

  Future<T?> _pushReplacementWithGoRouter<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return GoRouter.of(context).pushReplacementNamed(
      routeName,
      extra: arguments,
    );
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
  });

  factory PushNamedAndRemoveUntilBehavior.removeAll({
    bool rootNavigator = false,
    bool useGoRouter = true,
  }) =>
      PushNamedAndRemoveUntilBehavior(
        (route) => false,
        rootNavigator: rootNavigator,
        useGoRouter: useGoRouter,
      );

  /// The predicate may be applied to the same route more than once if
  /// [Route.willHandlePopInternally] is true.
  ///
  /// Ref: [Navigator.pushNamedAndRemoveUntil.predicate]
  final RoutePredicate predicate;

  @override
  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    if (useGoRouter && _hasGoRouter(context)) {
      return _pushAndRemoveUntilWithGoRouter<T>(
        context,
        routeName,
        arguments: arguments,
      );
    }

    final uri = buildUri(routeName, arguments);

    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    )
        .pushNamedAndRemoveUntil(
          uri.toString(),
          predicate,
          arguments: arguments,
        )
        .then(asOrNull);
  }

  Future<T?> _pushAndRemoveUntilWithGoRouter<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    // For removeAll behavior, use go() which clears the stack
    if (predicate == (Route<dynamic> route) => false) {
      return GoRouter.of(context).push<T>(routeName, extra: arguments);
    } else {
      // For partial removal, fallback to Navigator
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
}

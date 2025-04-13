import 'package:flutter/material.dart';

import 'data_checker.dart';

abstract class PushBehavior {
  const PushBehavior({
    this.rootNavigator = false,
  });

  final bool rootNavigator;

  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  });
}

/// Provide the wrapper as a push behavior
///
/// Ref: [Navigator.pushNamed]
class PushNamedBehavior extends PushBehavior {
  const PushNamedBehavior({
    super.rootNavigator = false,
  });

  @override
  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pushNamed(routeName, arguments: arguments).then(asOrNull);
}

/// Provide the wrapper as a push behavior
///
/// Ref: [Navigator.pushReplacementNamed]
class PushReplacementNamedBehavior<TO extends Object?> extends PushBehavior {
  const PushReplacementNamedBehavior({
    this.result,
    super.rootNavigator = false,
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
  }) =>
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      )
          .pushReplacementNamed(
            routeName,
            arguments: arguments,
            result: result,
          )
          .then(asOrNull);
}

/// Provide the wrapper as a push behavior
///
/// Ref: [Navigator.pushNamedAndRemoveUntil]
class PushNamedAndRemoveUntilBehavior<TO extends Object?> extends PushBehavior {
  const PushNamedAndRemoveUntilBehavior(
    this.predicate, {
    super.rootNavigator = false,
  });

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
  }) =>
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      )
          .pushNamedAndRemoveUntil(
            routeName,
            predicate,
            arguments: arguments,
          )
          .then(asOrNull);
}

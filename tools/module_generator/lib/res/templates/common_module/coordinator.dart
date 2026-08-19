import '../../../common/definitions.dart';

const commonModuleCoordinator =
    '''import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'views/${moduleNameKey}_screen.dart';

extension ${classNameKey}Coordinator on BuildContext {
  /// Entry point into the $classNameKey module.
  ///
  /// This module takes no route arguments, so the coordinator's job here is to
  /// own the entry *decision* rather than translate parameters: put pre-nav
  /// guards (auth checks, feature flags, "already satisfied" short-circuits)
  /// and post-nav handling in this method so no caller has to repeat them.
  Future<T?> goTo$classNameKey<T>({
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) {
    // TODO(template): add the entry logic this module needs — or, if it never
    // grows any, delete this file and its barrel export and call
    // `pushBehavior.push(context, ${classNameKey}Screen.routeName)` directly.
    // A coordinator that only forwards is indirection without leverage.
    return pushBehavior.push(this, ${classNameKey}Screen.routeName);
  }
}
''';

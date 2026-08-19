import '../../../common/definitions.dart';

const listingModuleCoordinator =
    '''import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '$modelFilterImportKey';
import 'views/${moduleNameKey}_screen.dart';

extension ${classNameKey}Coordinator on BuildContext {
  /// Opens the $classNameKey listing, optionally pre-filtered.
  ///
  /// Owns the translation from a domain [${modelNameKey}Filter] to the route's
  /// platform-correct payload, so callers never build [${classNameKey}Args]
  /// (or a query string) themselves.
  Future<T?> goTo$classNameKey<T>({
    ${modelNameKey}Filter? filter,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) {
    return pushBehavior.push(
      this,
      ${classNameKey}Screen.routeName,
      arguments: ${classNameKey}Args(filter: filter).adaptiveArguments,
    );
  }
}
''';

import '../../../common/definitions.dart';

const detailModuleCoordinator =
    '''import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '$modelImportKey';
import 'views/${moduleNameKey}_screen.dart';

extension ${classNameKey}Coordinator on BuildContext {
  /// Opens $classNameKey for an already-loaded [object], so the screen can
  /// paint before the refresh completes.
  Future<T?> goTo$classNameKey<T>({
    required $modelNameKey object,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) {
    return pushBehavior.push(
      this,
      ${classNameKey}Screen.routeName,
      arguments: ${classNameKey}Args(initial: object).adaptiveArguments,
    );
  }

  /// Opens $classNameKey for an [id] alone — the deep-link path, where the
  /// screen fetches before it can render.
  Future<T?> goTo${classNameKey}ById<T>({
    required String id,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) {
    return pushBehavior.push(
      this,
      ${classNameKey}Screen.routeName,
      arguments: ${classNameKey}Args(id: id).adaptiveArguments,
    );
  }
}
''';

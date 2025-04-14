import '../../../common/definations.dart';

final detailModuleCoordinator = '''import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '$moduleNameKey.dart';

extension ${classNameKey}Coordinator on BuildContext {
  Future<T?> goTo$classNameKey<T>({
    required $modelNameKey object,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      ${classNameKey}Screen.routeName,
      arguments: ${classNameKey}Args(
        initial: object,
      ),
    );
  }

  Future<T?> goTo${classNameKey}ById<T>({
    required String id,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      ${classNameKey}Screen.routeName,
      arguments: ${classNameKey}Args(
        id: id,
      ),
    );
  }
}
''';

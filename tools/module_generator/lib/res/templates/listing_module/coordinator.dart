import '../../../common/definitions.dart';

final listingModuleCoordinator = '''import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '$moduleNameKey.dart';

extension ${classNameKey}Coordinator on BuildContext {
  Future<T?> goTo$classNameKey<T>({
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      ${classNameKey}Screen.routeName,
    );
  }
}
''';

import '../../../common/definations.dart';

const detailModuleRoute = '''import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '$importPartKey/../../di/di.dart';
import 'bloc/${moduleNameKey}_bloc.dart';
import 'views/${moduleNameKey}_screen.dart';

class ${classNameKey}Route {
  Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        ${classNameKey}Screen.routeName: (context) {
          final args = asOrNull<${classNameKey}Args>(settings.arguments);
          return BlocProvider<${classNameKey}Bloc>(
            create: (context) => injector.get(param1: args?.initial),
            child: ${classNameKey}Screen(args: args),
          );
        },
      };
}
''';

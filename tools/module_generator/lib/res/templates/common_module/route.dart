import '../../../common/definations.dart';

const commonModuleRoute = '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/di.dart';
import 'bloc/${moduleNameKey}_bloc.dart';
import 'views/${moduleNameKey}_screen.dart';

class ${classNameKey}Route {
  Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        ${classNameKey}Screen.routeName: (context) {
          return BlocProvider<${classNameKey}Bloc>(
            create: (context) => injector(),
            child: const ${classNameKey}Screen(),
          );
        },
      };
}
''';

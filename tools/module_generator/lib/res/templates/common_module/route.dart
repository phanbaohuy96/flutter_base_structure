import '../../../common/definitions.dart';

const commonModuleRoute = '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/${moduleNameKey}_bloc.dart';
import 'views/${moduleNameKey}_screen.dart';

class ${classNameKey}Route {
  static Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        //TODO: Update route name
        '': (context) {
          return BlocProvider(
            create: (context) => ${classNameKey}Bloc(),
            child: const ${classNameKey}Screen(),
          );
        },
      };
}
''';

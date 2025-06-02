import '../../../common/definations.dart';

const listingModuleRoute = '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '$importPartKey/../../di/di.dart';
import 'bloc/${moduleNameKey}_bloc.dart';
import 'views/${moduleNameKey}_screen.dart';

class ${classNameKey}Route extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: ${classNameKey}Screen.routeName,
        builder: (context, uri, extra) {
          final args = asOrNull<${classNameKey}Args>(extra);
          return BlocProvider<${classNameKey}Bloc>(
            create: (context) => injector(),
            child: const ${classNameKey}Screen(),
          );
        },
      ),
    ];
  }
}
''';

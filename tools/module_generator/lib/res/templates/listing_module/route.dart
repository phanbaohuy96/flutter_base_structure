import '../../../common/definations.dart';

const listingModuleRoute = '''import 'package:core/core.dart';

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

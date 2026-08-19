import '../../../common/definitions.dart';

const commonModuleRoute =
    '''import 'package:core/core.dart';

import '${libImportKey}di/di.dart';
import 'bloc/${moduleNameKey}_bloc.dart';
import 'views/${moduleNameKey}_screen.dart';

@FlRouteProvider()
class ${classNameKey}Route extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: ${classNameKey}Screen.routeName,
        name: ${classNameKey}Screen.routeName,
        builder: (context, uri, extra) {
          return BlocProvider<${classNameKey}Bloc>(
            create: (context) => injector.get(),
            child: const ${classNameKey}Screen(),
          );
        },
      ),
    ];
  }
}
''';

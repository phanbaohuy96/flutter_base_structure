import '../../../common/definations.dart';

const detailModuleRoute = '''import 'package:core/core.dart';

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
            create: (context) => injector.get(param1: args?.initial),
            child: ${classNameKey}Screen(args: args),
          );
        },
        verifier: (uri, extra) {
          return uri.path.startsWith(
            ${classNameKey}Screen.routeName,
          );
        },
        extraBuilder: (p0, uri, extra) {
          if (extra is ${classNameKey}Args) {
            return extra;
          }

          return ${classNameKey}Args.fromUrlParams(
            uri.queryParameters as Map<String, dynamic>,
          );
        },
      ),
    ];
  }
}
''';

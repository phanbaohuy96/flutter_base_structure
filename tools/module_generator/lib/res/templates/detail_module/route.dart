import '../../../common/definations.dart';

const detailModuleRoute = '''import 'package:core/core.dart';

import '$importPartKey/../../di/di.dart';
import 'bloc/${moduleNameKey}_bloc.dart';
import 'views/${moduleNameKey}_screen.dart';

class ${classNameKey}Route extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter<${classNameKey}Args>(
        path: ${classNameKey}Screen.routeName,
        builder: (context, uri, extra) {
          final args = asOrNull<${classNameKey}Args>(extra);
          return BlocProvider<${classNameKey}Bloc>(
            create: (context) => injector.get(param1: args?.initial),
            child: ${classNameKey}Screen(args: args),
          );
        },
        extraFromUrlQueries: ${classNameKey}Args.fromUrlParams,
      ),
    ];
  }
}
''';

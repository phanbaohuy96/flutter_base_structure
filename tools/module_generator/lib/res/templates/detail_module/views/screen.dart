import '../../../../common/definitions.dart';

final detailModuleScreen = '''import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '$importPartKey../l10n/generated/app_localizations.dart';
import '${importPartKey}base/base.dart';
import '${importPartKey}extentions/extention.dart';
import '../bloc/${moduleNameKey}_bloc.dart';

part '$moduleNameKey.action.dart';

class ${classNameKey}Args {
  final $modelNameKey? initial;
  final String? id;

  ${classNameKey}Args({this.initial, this.id});

  factory ${classNameKey}Args.fromUrlParams(
    Map<String, dynamic> queryParameters,
  ) =>
      ${classNameKey}Args(
        id: asOrNull(queryParameters['id']),
      );

  dynamic get adaptive {
    if (kIsWeb) {
      return {
        'id': initial?.id ?? id,
      }..removeWhere((key, value) => value.isNullOrEmpty);
    }
    return this;
  }
}

class ${classNameKey}Screen extends StatefulWidget {
  static String routeName = '/$routeNameKey';

  const ${classNameKey}Screen({Key? key, this.args}) : super(key: key);
  
  final ${classNameKey}Args? args;

  @override
  State<${classNameKey}Screen> createState() => _${classNameKey}ScreenState();
}

class _${classNameKey}ScreenState extends StateBase<${classNameKey}Screen> {
  final _refreshController = RefreshController(initialRefresh: true);

  @override
  CoreDelegate get delegate => bloc;

  ${classNameKey}Bloc get bloc => BlocProvider.of(context);

  late ThemeData _themeData;

  TextTheme get textTheme => _themeData.textTheme;

  late AppLocalizations trans;

  @override
  void hideLoading() {
    _refreshController
      ..refreshCompleted()
      ..loadComplete();
    super.hideLoading();
  }

  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeData = context.theme;
    trans = translate(context);
    return ScreenForm(
      child: BlocConsumer<${classNameKey}Bloc, ${classNameKey}State>(
        listener: _blocListener,
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(${classNameKey}State state) {
    return SmartRefresherWrapper(
      enablePullDown: true,
      onRefresh: onRefresh,
      controller: _refreshController,
      child: const SizedBox(height: 16),
    );
  }
}
''';

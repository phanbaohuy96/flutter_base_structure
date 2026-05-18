import '../../../../common/definations.dart';

const detailModuleScreen = '''import 'package:core/core.dart';
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
}

class ${classNameKey}Screen extends StatefulWidget {
  static String routeName = '/$moduleNameKey';

  const ${classNameKey}Screen({Key? key, this.args}) : super(key: key);
  
  final ${classNameKey}Args? args;

  @override
  State<${classNameKey}Screen> createState() => _${classNameKey}ScreenState();
}

class _${classNameKey}ScreenState extends StateBase<${classNameKey}Screen> {
  final _refreshController = RefreshController(initialRefresh: true);

  @override
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

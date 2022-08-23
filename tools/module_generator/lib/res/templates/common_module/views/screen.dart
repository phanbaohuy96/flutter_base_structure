import '../../../../common/definitions.dart';

const commonModuleScreen = '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../base/base.dart';
import '../../../extentions/extention.dart';
import '../bloc/${moduleNameKey}_bloc.dart';

part '$moduleNameKey.action.dart';

class ${classNameKey}Screen extends StatefulWidget {
  const ${classNameKey}Screen({Key? key}) : super(key: key);

  @override
  State<${classNameKey}Screen> createState() => _${classNameKey}ScreenState();
}

class _${classNameKey}ScreenState extends StateBase<${classNameKey}Screen> {
  @override
  ${classNameKey}Bloc get bloc => BlocProvider.of(context);

  late ThemeData _themeData;

  TextTheme get textTheme => _themeData.textTheme;

  late AppLocalizations trans;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    trans = translate(context);
    return BlocConsumer<${classNameKey}Bloc, ${classNameKey}State>(
      listener: _blocListener,
      builder: (context, state) {
        return Container();
      },
    );
  }
}
''';

import '../../../../common/definitions.dart';

final commonModuleScreen =
    '''import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '$importPartKey../l10n/generated/app_localizations.dart';
import '${importPartKey}base/base.dart';
import '${importPartKey}extentions/extention.dart';
import '../bloc/${moduleNameKey}_bloc.dart';

part '$moduleNameKey.action.dart';

class ${classNameKey}Screen extends StatefulWidget {
  static String routeName = '/$routeNameKey';

  const ${classNameKey}Screen({super.key});

  @override
  State<${classNameKey}Screen> createState() => _${classNameKey}ScreenState();
}

class _${classNameKey}ScreenState extends StateBase<${classNameKey}Screen> {
  @override
  ${classNameKey}Bloc get bloc => BlocProvider.of(context);

  late AppLocalizations trans;

  @override
  Widget build(BuildContext context) {
    trans = translate(context);
    return ScreenForm(
      child: BlocConsumer<${classNameKey}Bloc, ${classNameKey}State>(
        listener: _blocListener,
        builder: (context, state) {
          return Container();
        },
      ),
    );
  }
}
''';

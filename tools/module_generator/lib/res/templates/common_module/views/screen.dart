import '../../../../common/definitions.dart';

const commonModuleScreen =
    '''import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '${libImportKey}l10n/localization_ext.dart';
import '${presentationImportKey}base/base.dart';
import '${presentationImportKey}extentions/extention.dart';
import '../bloc/${moduleNameKey}_bloc.dart';

part '$moduleNameKey.action.dart';

class ${classNameKey}Screen extends StatefulWidget {
  static const String routeName = '/$routeNameKey';

  const ${classNameKey}Screen({super.key});

  @override
  State<${classNameKey}Screen> createState() => _${classNameKey}ScreenState();
}

class _${classNameKey}ScreenState extends StateBase<${classNameKey}Screen> {
  @override
  ${classNameKey}Bloc get bloc => BlocProvider.of(context);

  late AppLocalizations trans;

  @override
  void initState() {
    super.initState();
    bloc.add(Get${classNameKey}Event());
  }

  @override
  Widget build(BuildContext context) {
    trans = translate(context);
    return ScreenForm(
      child: BlocConsumer<${classNameKey}Bloc, ${classNameKey}State>(
        listener: _blocListener,
        builder: (context, state) {
          // TODO(template): render `state.detail` using `trans` for copy.
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
''';

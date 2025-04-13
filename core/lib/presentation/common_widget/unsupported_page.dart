import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../l10n/localization_ext.dart';
import 'empty_data.dart';
import 'forms/screen_form.dart';

class UnsupportedPage extends StatelessWidget {
  final String? title;
  final String? msg;
  const UnsupportedPage({Key? key, this.title, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenForm(
      title: title ?? context.coreL10n.inform,
      child: Center(
        child: EmptyData(
          icon: coreImageConstant.logo,
          message: msg ?? context.coreL10n.featureUnderDevelopment,
        ),
      ),
    );
  }
}

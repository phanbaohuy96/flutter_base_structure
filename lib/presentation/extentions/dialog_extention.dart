import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/dialog.dart';

import '../../common/components/i18n/internationalization.dart';
import '../../common/utils/dimension.dart';
import '../theme/theme_button.dart';

Future<dynamic> showNoticeDialog({
  @required BuildContext context,
  @required String message,
  @required Widget icon,
  String titleBtn,
  bool barrierDismissible = true,
  Function() onPressed,
  bool useRootNavigator = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (build) {
      final theme = Theme.of(context);
      return NotifyDialog(
        iconPopup: icon,
        content: Text(
          message,
          style: theme.textTheme.bodyText2,
          textAlign: TextAlign.center,
        ),
        buttonActions: [
          ThemeButton.primary(
            width: Dimension.getWidth(0.9),
            height: 45,
            context: context,
            title: titleBtn ?? S.of(context).translate('common.dismiss'),
            onTap: () {
              onPressed?.call();
              Navigator.of(context, rootNavigator: useRootNavigator).pop();
            },
          )
        ],
      );
    },
  );
}

Future<dynamic> showNoticeErrorDialog({
  @required BuildContext context,
  @required String message,
  bool barrierDismissible = true,
  Function() onPressed,
  bool useRootNavigator = true,
}) {
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onPressed: onPressed,
    titleBtn: S.of(context).translate('common.dismiss'),
    useRootNavigator: useRootNavigator,
    icon: Icon(
      Icons.error_outline,
      color: Colors.red,
      size: 100,
    ),
  );
}

Future<dynamic> showNoticeWarningDialog({
  @required BuildContext context,
  @required String message,
  bool barrierDismissible = true,
  Function() onPressed,
  bool useRootNavigator = true,
}) {
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onPressed: onPressed,
    titleBtn: S.of(context).translate('common.dismiss'),
    useRootNavigator: useRootNavigator,
    icon: Icon(
      Icons.warning,
      color: Colors.orange,
      size: 100,
    ),
  );
}

Future<dynamic> showNoticeConfirmDialog({
  @required BuildContext context,
  @required Icon icon,
  @required String message,
  bool barrierDismissible = true,
  String titleBtnDone,
  String titleBtnCancel,
  Function() onConfirmed,
  Function() onCanceled,
  bool useRootNavigator = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (build) {
      final theme = Theme.of(context);
      return NotifyDialog(
        iconPopup: icon,
        content: Text(
          message,
          style: theme.textTheme.bodyText2,
          textAlign: TextAlign.center,
        ),
        buttonActions: [
          ThemeButton.notRecommend(
            context: context,
            title: titleBtnCancel ?? S.of(context).translate('common.cancel'),
            onTap: () {
              onCanceled?.call();
              Navigator.of(context, rootNavigator: true).pop();
            },
            width: Dimension.getWidth(0.42),
            height: 50,
          ),
          ThemeButton.recommend(
            context: context,
            title: titleBtnDone ?? S.of(context).translate('common.confirm'),
            onTap: () {
              onConfirmed?.call();
              Navigator.of(context, rootNavigator: true).pop();
            },
            width: Dimension.getWidth(0.42),
            height: 50,
          )
        ],
      );
    },
  );
}

Future<void> showModal(
  BuildContext context,
  Widget content, {
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.only(bottom: Dimension.bottomPadding),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.9, color: Colors.grey[400])]),
        child: content,
      );
    },
  );
}

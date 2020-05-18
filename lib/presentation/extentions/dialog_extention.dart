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
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (build) {
      final theme = Theme.of(context);
      return NotifyDialog(
        iconPopup: icon,
        content: Text(
          message,
          style: theme.textTheme.title,
          textAlign: TextAlign.center,
        ),
        buttonActions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ThemeButton.primary(
              width: Dimension.getWidth(0.8),
              context: context,
              title: titleBtn ?? S.of(context).translate('common.dismiss'),
              onTap: () {
                onPressed?.call();
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
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
}) {
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onPressed: onPressed,
    titleBtn: S.of(context).translate('common.dismiss'),
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
}) {
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onPressed: onPressed,
    titleBtn: S.of(context).translate('common.dismiss'),
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
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (build) {
      final theme = Theme.of(context);
      return NotifyDialog(
        iconPopup: icon,
        content: Text(
          message,
          style: theme.textTheme.title,
          textAlign: TextAlign.center,
        ),
        buttonActions: [
          ThemeButton.left(
            context: context,
            title: titleBtnCancel ?? S.of(context).translate('common.cancel'),
            onTap: () {
              onCanceled?.call();
              Navigator.of(context, rootNavigator: true).pop();
            },
            width: Dimension.getWidth(0.4),
          ),
          ThemeButton.right(
            context: context,
            title: titleBtnDone ?? S.of(context).translate('common.confirm'),
            onTap: () {
              onConfirmed?.call();
              Navigator.of(context, rootNavigator: true).pop();
            },
            width: Dimension.getWidth(0.4),
          )
        ],
      );
    },
  );
}

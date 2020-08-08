import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/dialog.dart';

import '../../common/components/i18n/internationalization.dart';
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
      final mediaData = MediaQuery.of(context);
      return NotifyDialog(
        iconPopup: icon,
        content: Text(
          message,
          style: theme.textTheme.bodyText2,
          textAlign: TextAlign.center,
        ),
        buttonActions: [
          SizedBox(
            width: mediaData.size.width * 0.9,
            height: 45,
            child: ThemeButton.primary(
              context: context,
              title: titleBtn ?? S.of(context).translate('common.dismiss'),
              onPressed: () {
                onPressed?.call();
                Navigator.of(context, rootNavigator: useRootNavigator).pop();
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
  bool useRootNavigator = true,
}) {
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onPressed: onPressed,
    titleBtn: S.of(context).translate('common.dismiss'),
    useRootNavigator: useRootNavigator,
    icon: const Icon(
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
    icon: const Icon(
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
      final mediaData = MediaQuery.of(context);
      return NotifyDialog(
        iconPopup: icon,
        content: Text(
          message,
          style: theme.textTheme.bodyText2,
          textAlign: TextAlign.center,
        ),
        buttonActions: [
          SizedBox(
            width: mediaData.size.width * 0.42,
            height: 50,
            child: ThemeButton.notRecommend(
              context: context,
              title: titleBtnCancel ?? S.of(context).translate('common.cancel'),
              onPressed: () {
                onCanceled?.call();
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ),
          SizedBox(
            width: mediaData.size.width * 0.42,
            height: 50,
            child: ThemeButton.recommend(
              context: context,
              title: titleBtnDone ?? S.of(context).translate('common.confirm'),
              onPressed: () {
                onConfirmed?.call();
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
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
      final mediaData = MediaQuery.of(context);

      return Container(
        padding: EdgeInsets.only(
          bottom: mediaData.padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10.9,
              color: Colors.grey[400],
            ),
          ],
        ),
        child: content,
      );
    },
  );
}

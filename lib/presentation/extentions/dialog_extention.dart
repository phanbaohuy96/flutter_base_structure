part of 'extention.dart';

Future<dynamic> showNoticeDialog({
  @required BuildContext context,
  @required String message,
  String title,
  String titleBtn,
  bool barrierDismissible = true,
  Function() onClose,
  bool useRootNavigator = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final theme = Theme.of(context);
      if (Platform.isAndroid) {
        return AlertDialog(
          title: Text(
            title ?? translate(context)('common.inform'),
            style: theme.textTheme.headline5,
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: useRootNavigator).pop();
                onClose?.call();
              },
              child: Text(titleBtn ?? translate(context)('common.dismiss')),
            )
          ],
        );
      } else {
        return CupertinoAlertDialog(
          title: Text(title ?? translate(context)('common.inform')),
          content: Text(
            message,
            style: theme.textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context, rootNavigator: useRootNavigator).pop();
                onClose?.call();
              },
              child: Text(titleBtn ?? translate(context)('common.dismiss')),
            ),
          ],
        );
      }
    },
  );
}

Future<dynamic> showNoticeErrorDialog({
  @required BuildContext context,
  @required String message,
  bool barrierDismissible = false,
  Function() onClose,
  bool useRootNavigator = true,
}) {
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onClose: onClose,
    titleBtn: translate(context)('common.ok'),
    useRootNavigator: useRootNavigator,
    title: translate(context)('common.error'),
  );
}

Future<dynamic> showNoticeWarningDialog({
  @required BuildContext context,
  @required String message,
  bool barrierDismissible = false,
  Function() onClose,
  bool useRootNavigator = true,
}) {
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onClose: onClose,
    titleBtn: translate(context)('common.ok'),
    useRootNavigator: useRootNavigator,
    title: translate(context)('common.warning'),
  );
}

Future<dynamic> showNoticeConfirmDialog({
  @required BuildContext context,
  @required Icon icon,
  @required String message,
  @required String title,
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
    builder: (context) {
      final theme = Theme.of(context);
      if (Platform.isAndroid) {
        return AlertDialog(
          title: Text(
            title,
            style: theme.textTheme.headline5,
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: useRootNavigator).pop();
                onCanceled?.call();
              },
              child:
                  Text(titleBtnCancel ?? translate(context)('common.cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: useRootNavigator).pop();
                onConfirmed?.call();
              },
              child: Text(titleBtnDone ?? translate(context)('common.confirm')),
            ),
          ],
        );
      } else {
        Widget _buildAction({Function() onTap, String title}) {
          return RawMaterialButton(
            constraints: const BoxConstraints(minHeight: 45),
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.of(context, rootNavigator: useRootNavigator).pop();
              onTap?.call();
            },
            child: Text(
              title,
              style: theme.textTheme.button.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        }

        return CupertinoAlertDialog(
          title: Text(
            title,
            style: theme.textTheme.headline5,
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAction(
                  onTap: onConfirmed,
                  title: titleBtnDone ?? translate(context)('common.confirm'),
                ),
                const Divider(thickness: 1, height: 1),
                _buildAction(
                  onTap: onCanceled,
                  title: titleBtnCancel ?? translate(context)('common.cancel'),
                ),
              ],
            )
          ],
        );
      }
    },
  );
}

Future<void> showModal(
  BuildContext context,
  Widget content, {
  bool useRootNavigator = true,
  double bottomPadding,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Wrap(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                bottom: bottomPadding ?? MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(8),
                  topStart: Radius.circular(8),
                ),
                boxShadow: boxShadowDark,
              ),
              child: content,
            )
          ],
        ),
      );
    },
  );
}

Future<void> showActionDialog(
  BuildContext context, {
  Map<String, Function> action = const <String, Function>{},
  String title = '',
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  bool dimissWhenSelect = true,
}) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.headline5,
          ),
          actions: [
            ...action.entries
                .map<TextButton>(
                  (e) => TextButton(
                    onPressed: () {
                      if (dimissWhenSelect) {
                        Navigator.of(
                          context,
                          rootNavigator: useRootNavigator,
                        ).pop();
                      }
                      e.value?.call();
                    },
                    child: Text(e.key),
                  ),
                )
                .toList(),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: useRootNavigator).pop();
              },
              child: Text(translate(context)('common.cancel')),
            ),
          ],
        );
      },
    );
  } else {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return ThemeBottomSheet.cupertinoBottomActionSheet(
          context: context,
          action: !dimissWhenSelect
              ? action
              : action.map(
                  (key, value) => MapEntry(
                    key,
                    () {
                      Navigator.of(
                        context,
                        rootNavigator: useRootNavigator,
                      ).pop();
                      value?.call();
                    },
                  ),
                ),
          title: title,
          onCancelPressed: () {
            Navigator.of(context, rootNavigator: useRootNavigator).pop();
          },
        );
      },
    );
  }
}

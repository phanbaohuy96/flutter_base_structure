part of 'extention.dart';

Future<dynamic> showNoticeDialog({
  required BuildContext context,
  required String message,
  String? title,
  String? titleBtn,
  bool barrierDismissible = true,
  Function()? onClose,
  bool useRootNavigator = true,
  bool dismissWhenAction = true,
}) {
  final dismissFunc = () {
    if (dismissWhenAction) {
      Navigator.of(context, rootNavigator: useRootNavigator).pop();
    }
  };
  final trans = translate(context);
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final theme = Theme.of(context);

      final showAndroidDialog = () => AlertDialog(
            title: Text(
              title ?? trans.inform,
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
                  dismissFunc.call();
                  onClose?.call();
                },
                child: Text(titleBtn ?? trans.ok),
              )
            ],
          );

      if (kIsWeb) {
        return showAndroidDialog();
      } else if (Platform.isAndroid) {
        return showAndroidDialog();
      } else {
        return CupertinoAlertDialog(
          title: Text(title ?? trans.inform),
          content: Text(
            message,
            style: theme.textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                dismissFunc.call();
                onClose?.call();
              },
              child: Text(titleBtn ?? trans.ok),
            ),
          ],
        );
      }
    },
  );
}

Future<dynamic> showNoticeErrorDialog({
  required BuildContext context,
  required String message,
  bool barrierDismissible = false,
  void Function()? onClose,
  bool useRootNavigator = true,
  String? titleBtn,
}) {
  final trans = translate(context);
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onClose: onClose,
    titleBtn: titleBtn ?? trans.ok,
    useRootNavigator: useRootNavigator,
    title: trans.error,
  );
}

Future<dynamic> showNoticeWarningDialog({
  required BuildContext context,
  required String message,
  bool barrierDismissible = false,
  void Function()? onClose,
  bool useRootNavigator = true,
}) {
  final trans = translate(context);
  return showNoticeDialog(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onClose: onClose,
    titleBtn: trans.ok,
    useRootNavigator: useRootNavigator,
    title: trans.warning,
  );
}

Future<dynamic> showNoticeConfirmDialog({
  required BuildContext context,
  required String message,
  required String title,
  bool barrierDismissible = true,
  String? titleBtnDone,
  String? titleBtnCancel,
  void Function()? onConfirmed,
  void Function()? onCanceled,
  bool useRootNavigator = true,
  bool dismissWhenAction = true,
  TextStyle? styleBtnRight,
  TextStyle? styleBtnLeft,
}) {
  final dismissFunc = () {
    if (dismissWhenAction) {
      Navigator.of(context, rootNavigator: useRootNavigator).pop();
    }
  };
  final trans = translate(context);
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final theme = Theme.of(context);

      final showAndroidDialog = () => AlertDialog(
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
                  dismissFunc.call();
                  onCanceled?.call();
                },
                child: Text(
                  titleBtnCancel ?? trans.cancel,
                  style: styleBtnLeft ??
                      theme.textTheme.button?.copyWith(
                        color: AppColor.primaryColor,
                      ),
                ),
              ),
              TextButton(
                onPressed: () {
                  dismissFunc.call();
                  onConfirmed?.call();
                },
                child: Text(
                  titleBtnDone ?? trans.confirm,
                  style: styleBtnRight ??
                      theme.textTheme.button?.copyWith(
                        color: AppColor.primaryColor,
                      ),
                ),
              ),
            ],
          );

      if (kIsWeb) {
        return showAndroidDialog();
      } else if (Platform.isAndroid) {
        return showAndroidDialog();
      } else {
        Widget _buildAction({
          Function()? onTap,
          required String title,
          TextStyle? style,
        }) {
          return RawMaterialButton(
            constraints: const BoxConstraints(minHeight: 45),
            padding: EdgeInsets.zero,
            onPressed: () {
              dismissFunc.call();
              onTap?.call();
            },
            child: Text(
              title,
              style: style ??
                  theme.textTheme.button!.copyWith(
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
            Row(
              children: [
                Expanded(
                  child: _buildAction(
                    onTap: onCanceled,
                    title: titleBtnCancel ?? trans.cancel,
                    style: styleBtnLeft,
                  ),
                ),
                Container(width: 0.5, height: 44, color: Colors.grey),
                Expanded(
                  child: _buildAction(
                    onTap: onConfirmed,
                    title: titleBtnDone ?? trans.confirm,
                    style: styleBtnRight,
                  ),
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
  double? bottomPadding,
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
  Map<String, void Function()> actions = const <String, void Function()>{},
  String title = '',
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  bool dimissWhenSelect = true,
}) {
  final trans = translate(context);
  if (kIsWeb || Platform.isAndroid) {
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
            ...actions.entries
                .map<TextButton>(
                  (e) => TextButton(
                    onPressed: () {
                      if (dimissWhenSelect) {
                        Navigator.of(
                          context,
                          rootNavigator: useRootNavigator,
                        ).pop();
                      }
                      e.value.call();
                    },
                    child: Text(e.key),
                  ),
                )
                .toList(),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: useRootNavigator).pop();
              },
              child: Text(trans.cancel),
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
        final theme = Theme.of(context);
        return CupertinoActionSheet(
          actions: [
            ...actions.entries.map(
              (e) => CupertinoActionSheetAction(
                onPressed: () {
                  if (dimissWhenSelect) {
                    if (dimissWhenSelect) {
                      Navigator.of(
                        context,
                        rootNavigator: useRootNavigator,
                      ).pop();
                    }
                    e.value.call();
                  }
                },
                child: Text(
                  e.key,
                  style: theme.textTheme.headline5?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
          title: Text(
            title,
            style: theme.textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: useRootNavigator,
              ).pop();
            },
            child: Text(
              trans.cancel,
              style: theme.textTheme.headline5?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

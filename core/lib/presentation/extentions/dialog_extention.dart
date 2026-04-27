part of 'extention.dart';

Future<T?> showNoticeDialog<T>({
  required BuildContext context,
  required String message,
  Widget? content,
  String? title,
  String? titleBtn,
  bool barrierDismissible = true,
  Function()? onClose,
  bool useRootNavigator = true,
  bool dismissWhenAction = true,
  Widget? icon,
}) {
  final themeDialog = injector<ThemeDialog>(param1: context);

  final showDialog = themeDialog.processShowDialog;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      return themeDialog.buildNoticeDialog(
        title: title,
        message: message,
        content: content,
        dismissWhenAction: dismissWhenAction,
        useRootNavigator: useRootNavigator,
        onClose: onClose,
        titleBtn: titleBtn,
        barrierDismissible: barrierDismissible,
        icon: icon,
      );
    },
  );
}

Future<T?> showNoticeErrorDialog<T>({
  required BuildContext context,
  required String message,
  bool barrierDismissible = false,
  void Function()? onClose,
  bool useRootNavigator = true,
  String? titleBtn,
  Widget? icon,
}) {
  final localization = context.coreL10n;
  return showNoticeDialog<T>(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onClose: onClose,
    titleBtn: titleBtn,
    useRootNavigator: useRootNavigator,
    title: localization.error,
    icon: icon,
  );
}

Future<T?> showNoticeWarningDialog<T>({
  required BuildContext context,
  required String message,
  bool barrierDismissible = false,
  void Function()? onClose,
  bool useRootNavigator = true,
  Widget? icon,
}) {
  final localization = context.coreL10n;
  return showNoticeDialog<T>(
    context: context,
    message: message,
    barrierDismissible: barrierDismissible,
    onClose: onClose,
    titleBtn: localization.ok,
    useRootNavigator: useRootNavigator,
    title: localization.warning,
    icon: icon,
  );
}

Future<bool> showNoticeConfirmDialog({
  required BuildContext context,
  String? message,
  required String title,
  Widget? content,
  bool barrierDismissible = true,
  String? leftBtn,
  String? rightBtn,
  void Function()? onConfirmed,
  void Function()? onCanceled,
  bool useRootNavigator = true,
  bool dismissWhenAction = true,
  TextStyle? styleRightBtn,
  TextStyle? styleLeftBtn,
  TextStyle? titleStyle,
  Widget? icon,
}) async {
  final themeDialog = injector<ThemeDialog>(param1: context);

  final res = await themeDialog.processShowDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      return themeDialog.buildConfirmDialog(
        title: title,
        message: message ?? '',
        content: content,
        onConfirmed: onConfirmed,
        onCanceled: onCanceled,
        dismissWhenAction: dismissWhenAction,
        useRootNavigator: useRootNavigator,
        leftBtn: leftBtn,
        rightBtn: rightBtn,
        styleLeftBtn: styleLeftBtn,
        styleRightBtn: styleRightBtn,
        titleStyle: titleStyle,
        icon: icon,
      );
    },
  );
  return asOrNull<bool>(res, false)!;
}

Future<T?> showNoticeConfirmWithReasonDialog<T>({
  required BuildContext context,
  required String message,
  required String title,
  String? hint,
  bool barrierDismissible = true,
  String? leftBtn,
  String? rightBtn,
  void Function(String reason)? onConfirmed,
  void Function(String reason)? onCanceled,
  bool useRootNavigator = true,
  bool dismissWhenAction = true,
  TextStyle? styleRightBtn,
  TextStyle? styleLeftBtn,
  Widget? additionalWidget,
  bool? isRequiredReason,
}) {
  final themeDialog = injector<ThemeDialog>(param1: context);

  final showDialog = themeDialog.processShowDialog;

  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      // Using scaffold for resizeToAvoidBottomInset
      return InputContainerProvider(
        builder: (context, _icReasonCtr) => GestureDetector(
          onTap: () {
            if (_icReasonCtr.value.focusNode.hasFocus) {
              CoreCommonFunction().hideKeyboard(context);
            } else if (barrierDismissible) {
              Navigator.of(
                context,
                rootNavigator: useRootNavigator,
              ).pop(_icReasonCtr.text);
            }
          },
          child: themeDialog.buildConfirmWithReasonDialog(
            controller: _icReasonCtr,
            title: title,
            hint: hint,
            message: message,
            onConfirmed: onConfirmed,
            onCanceled: onCanceled,
            dismissWhenAction: dismissWhenAction,
            useRootNavigator: useRootNavigator,
            leftBtn: leftBtn,
            rightBtn: rightBtn,
            styleLeftBtn: styleLeftBtn,
            styleRightBtn: styleRightBtn,
            additionalWidget: additionalWidget,
            isRequiredReason: isRequiredReason,
          ),
        ),
      );
    },
  );
}

Future<T?> showModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  bool resizeToAvoidBottomInset = true,
  String? title,
  void Function()? onClose,
  bool useSafeArea = false,
  Color? backgroundColor,
  bool showTitleDivider = false,
  bool isDismissible = true,
  bool isScrollControlled = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  RouteSettings? routeSettings,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (_) {
      return injector<ThemeDialog>(param1: context).buildModalBottomSheet(
        body: builder(context),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        onClose: onClose,
        title: title,
        useRootNavigator: useRootNavigator,
        backgroundColor: backgroundColor,
        showTitleDivider: showTitleDivider,
        showDragHandle: showDragHandle,
      );
    },
  );
}

Future<T?> showActionDialog<T>(
  BuildContext context, {
  Map<String, void Function()> actions = const <String, void Function()>{},
  String title = '',
  String? subTitle = '',
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  bool dimissWhenSelect = true,
  String? titleBottomBtn,
}) {
  final themeDialog = injector<ThemeDialog>(param1: context);

  if (!kIsWeb && Platform.isAndroid) {
    final showDialog = themeDialog.processShowDialog;
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        return themeDialog.buildActionDialog(
          title: title,
          useRootNavigator: useRootNavigator,
          actions: actions,
          dimissWhenSelect: dimissWhenSelect,
          subTitle: subTitle,
          titleBottomBtn: titleBottomBtn,
        );
      },
    );
  } else {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return themeDialog.buildActionDialog(
          title: title,
          useRootNavigator: useRootNavigator,
          actions: actions,
          dimissWhenSelect: dimissWhenSelect,
          subTitle: subTitle,
          titleBottomBtn: titleBottomBtn,
        );
      },
    );
  }
}

Future<T?> showNoticeConfirmWithValidateDialog<T>({
  required BuildContext context,
  required String message,
  required String title,
  required String validateString,
  String? hint,
  bool barrierDismissible = true,
  String? leftBtn,
  String? rightBtn,
  void Function()? onConfirmed,
  void Function()? onCanceled,
  bool useRootNavigator = true,
  bool dismissWhenAction = true,
  TextStyle? styleRightBtn,
  TextStyle? styleLeftBtn,
}) {
  final themeDialog = injector<ThemeDialog>(param1: context);

  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      // Using scaffold for resizeToAvoidBottomInset
      return InputContainerProvider(
        builder: (context, _icReasonCtr) => GestureDetector(
          onTap: () {
            if (_icReasonCtr.value.focusNode.hasFocus) {
              CoreCommonFunction().hideKeyboard(context);
            } else if (barrierDismissible) {
              Navigator.of(context, rootNavigator: useRootNavigator).pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: themeDialog.buildNoticeConfirmWithValidateDialog(
              controller: _icReasonCtr,
              title: title,
              hint: hint,
              message: message,
              validateString: validateString,
              onConfirmed: onConfirmed,
              onCanceled: onCanceled,
              dismissWhenAction: dismissWhenAction,
              useRootNavigator: useRootNavigator,
              leftBtn: leftBtn,
              rightBtn: rightBtn,
              styleLeftBtn: styleLeftBtn,
              styleRightBtn: styleRightBtn,
            ),
          ),
        ),
      );
    },
  );
}

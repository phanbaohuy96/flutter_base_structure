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
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      return injector<ThemeDialog>(param1: context).buildNoticeDialog(
        title: title,
        message: message,
        content: content,
        dismissWhenAction: dismissWhenAction,
        useRootNavigator: useRootNavigator,
        onClose: onClose,
        titleBtn: titleBtn,
        barrierDismissible: barrierDismissible,
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
  );
}

Future<T?> showNoticeWarningDialog<T>({
  required BuildContext context,
  required String message,
  bool barrierDismissible = false,
  void Function()? onClose,
  bool useRootNavigator = true,
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
  );
}

Future<T?> showNoticeDialogWithOptions<T>({
  required BuildContext context,
  required dynamic title,
  required List<Map<String, dynamic>> options,
  TextStyle? styleOptionTitle,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  void Function(int? selectedOption)? onConfirmed,
  void Function()? onCanceled,
  int? initialValue,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      return injector<ThemeDialog>(param1: context)
          .buildNoticeDialogWithOptions(
        title: title,
        options: options,
        styleOptionTitle: styleOptionTitle,
        onConfirmed: (int? selectedOption) {
          if (onConfirmed != null) {
            onConfirmed(selectedOption);
          }
        },
        onCanceled: onCanceled,
        initialValue: initialValue,
      );
    },
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
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      return injector<ThemeDialog>(param1: context).buildConfirmDialog(
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
  ).then((value) => asOrNull<bool>(value, false)!);
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
  final _icReasonCtr = InputContainerController();
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      // Using scaffold for resizeToAvoidBottomInset
      return GestureDetector(
        onTap: () {
          if (_icReasonCtr.value.focusNode.hasFocus) {
            CoreCommonFunction().hideKeyboard(context);
          } else if (barrierDismissible) {
            Navigator.of(context, rootNavigator: useRootNavigator).pop(
              _icReasonCtr.text,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: injector<ThemeDialog>(param1: context)
              .buildConfirmWithReasonDialog(
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
  ).then((value) {
    _icReasonCtr.dispose();
    return value;
  });
}

Future<T?> showModal<T>(
  BuildContext context,
  Widget body, {
  bool useRootNavigator = true,
  bool resizeToAvoidBottomInset = true,
  String? title,
  void Function()? onClose,
  bool useSafeArea = false,
  Color? backgroundColor,
  bool showTitleDivider = false,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (_) {
      return injector<ThemeDialog>(param1: context).buildModalBottomSheet(
        body: body,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        onClose: onClose,
        title: title,
        useRootNavigator: useRootNavigator,
        backgroundColor: backgroundColor,
        showTitleDivider: showTitleDivider,
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
  if (!kIsWeb && Platform.isAndroid) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        return injector<ThemeDialog>(param1: context).buildActionDialog(
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
        return injector<ThemeDialog>(param1: context).buildActionDialog(
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
  final _icReasonCtr = InputContainerController();
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      // Using scaffold for resizeToAvoidBottomInset
      return GestureDetector(
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
          body: injector<ThemeDialog>(param1: context)
              .buildNoticeConfirmWithValidateDialog(
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
      );
    },
  ).then((value) {
    _icReasonCtr.dispose();
    return value;
  });
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../core.dart';
import '../../l10n/localization_ext.dart';

@Injectable(as: ThemeDialog)
class CoreThemeDialog extends ThemeDialog {
  CoreThemeDialog(@factoryParam super.context);
}

abstract class ThemeDialog {
  ThemeDialog(@factoryParam this.context);

  String get cancel => context.coreL10n.cancel;
  String get confirm => context.coreL10n.confirm;
  String get ok => context.coreL10n.ok;
  String get inform => context.coreL10n.inform;

  final BuildContext context;

  Widget buildConfirmDialog({
    String? title,
    String? message,
    Widget? content,
    String? leftBtn,
    String? rightBtn,
    TextStyle? styleRightBtn,
    TextStyle? styleLeftBtn,
    TextStyle? titleStyle,
    bool useRootNavigator = true,
    bool dismissWhenAction = true,
    void Function()? onConfirmed,
    void Function()? onCanceled,
    Widget? icon,
  }) {
    final dismissFunc = (bool result) {
      if (dismissWhenAction) {
        Navigator.of(context, rootNavigator: useRootNavigator).pop(result);
      }
    };
    final theme = context.theme;

    final showAndroidDialog = () => AlertDialog(
          icon: icon,
          title: Text(
            title ?? inform,
            style: titleStyle ?? theme.textTheme.headlineSmall,
          ),
          content: content ??
              Text(
                message ?? '',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
          actions: [
            TextButton(
              key: const ValueKey('ConfirmDialog_cancel_btn'),
              onPressed: () {
                dismissFunc.call(false);
                onCanceled?.call();
              },
              child: Text(
                leftBtn ?? cancel,
                style: styleLeftBtn ??
                    theme.textTheme.labelLarge?.copyWith(
                      color: context.themeColor.primary,
                    ),
              ),
            ),
            TextButton(
              key: const ValueKey('ConfirmDialog_confirm_btn'),
              onPressed: () {
                dismissFunc.call(true);
                onConfirmed?.call();
              },
              child: Text(
                rightBtn ?? confirm,
                style: styleRightBtn ??
                    theme.textTheme.labelLarge?.copyWith(
                      color: context.themeColor.primary,
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
        required bool popResult,
      }) {
        return RawMaterialButton(
          constraints: const BoxConstraints(minHeight: 45),
          padding: EdgeInsets.zero,
          onPressed: () {
            dismissFunc.call(popResult);
            onTap?.call();
          },
          child: Text(
            title,
            style: style ??
                theme.textTheme.labelLarge!.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.normal,
                ),
          ),
        );
      }

      return CupertinoAlertDialog(
        title: Text(
          title ?? inform,
          style: theme.textTheme.headlineSmall,
        ),
        content: content ??
            Text(
              message ?? '',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                key: const ValueKey('ConfirmDialog_cancel_btn'),
                child: _buildAction(
                  onTap: onCanceled,
                  title: leftBtn ?? cancel,
                  style: styleLeftBtn,
                  popResult: false,
                ),
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                key: const ValueKey('ConfirmDialog_confirm_btn'),
                child: _buildAction(
                  onTap: onConfirmed,
                  title: rightBtn ?? confirm,
                  style: styleRightBtn,
                  popResult: true,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget buildNoticeDialogWithOptions({
    required dynamic title,
    required List<Map<String, dynamic>> options,
    TextStyle? styleOptionTitle,
    bool useRootNavigator = true,
    bool dismissWhenAction = true,
    bool barrierDismissible = true,
    void Function(int? selectedOption)? onConfirmed,
    void Function()? onCanceled,
    int? initialValue,
  }) {
    final dismissFunc = () {
      if (dismissWhenAction) {
        Navigator.of(context, rootNavigator: useRootNavigator).pop();
      }
    };
    final selectedOptionNotifier = ValueNotifier<int?>(initialValue);

    final textTheme = context.theme.textTheme;
    final localization = context.coreL10n;
    final themeColor = context.themeColor;

    final showAndroidDialog = () => PopScope(
          canPop: barrierDismissible,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: context.themeColor.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(localization.inform),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Divider(
                  color: context.themeColor.dividerColor,
                  thickness: 1.0,
                ),
                const SizedBox(
                  height: 5,
                ),
                title is String
                    ? Text(
                        title,
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : title,
              ],
            ),
            content: ValueListenableBuilder<int?>(
              valueListenable: selectedOptionNotifier,
              builder: (context, _selectedOption, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(options.length, (index) {
                    final option = options[index];
                    final title = option['title'] as dynamic;
                    final description = option['description'] as dynamic;
                    return Theme(
                      data: Theme.of(context).copyWith(
                        radioTheme: const RadioThemeData(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: RadioListTile<int>(
                        title: title is String
                            ? Text(
                                title,
                                style: textTheme.titleSmall,
                              )
                            : title,
                        subtitle: description != null
                            ? description is String
                                ? Text(
                                    description,
                                    style: textTheme.bodyMedium,
                                  )
                                : description
                            : null,
                        value: index,
                        groupValue: selectedOptionNotifier.value,
                        toggleable: false,
                        contentPadding: EdgeInsets.zero,
                        dense: false,
                        activeColor: themeColor.primary,
                        onChanged: (int? value) {
                          if (value != null) {
                            selectedOptionNotifier.value = value;
                          }
                        },
                      ),
                    );
                  }),
                );
              },
            ),
            actions: [
              TextButton(
                key: const ValueKey('NoticeDialogWithOptions_close_btn'),
                onPressed: () {
                  dismissFunc.call();
                  onCanceled?.call();
                },
                child: Text(
                  localization.cancel,
                  style: textTheme.labelLarge?.copyWith(
                    color: themeColor.primary,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('NoticeDialogWithOptions_confirm_btn'),
                onPressed: () {
                  dismissFunc.call();
                  onConfirmed?.call(selectedOptionNotifier.value);
                },
                child: Text(
                  localization.confirm,
                  style: textTheme.labelLarge?.copyWith(
                    color: themeColor.primary,
                  ),
                ),
              ),
            ],
          ),
        );

    if (kIsWeb) {
      return showAndroidDialog();
    } else if (Platform.isAndroid) {
      return showAndroidDialog();
    } else {
      return NoticeDialogWithOptions(
        title: title,
        options: options,
        parentContext: context,
        styleOptionTitle: styleOptionTitle,
        useRootNavigator: useRootNavigator,
        dismissWhenAction: dismissWhenAction,
        barrierDismissible: barrierDismissible,
        onConfirmed: onConfirmed,
        onCanceled: onCanceled,
        initialValue: initialValue,
      );
    }
  }

  Widget buildConfirmWithReasonDialog({
    required InputContainerController controller,
    String? title,
    String? hint,
    required String message,
    String? leftBtn,
    String? rightBtn,
    TextStyle? styleRightBtn,
    TextStyle? styleLeftBtn,
    bool useRootNavigator = true,
    bool dismissWhenAction = true,
    void Function(String)? onConfirmed,
    void Function(String)? onCanceled,
    Widget? additionalWidget,
    bool? isRequiredReason,
  }) {
    final _icReason = controller;
    final dismissFunc = () {
      if (dismissWhenAction) {
        Navigator.of(context, rootNavigator: useRootNavigator).pop(
          _icReason.text,
        );
      }
    };
    final theme = context.theme;

    final showAndroidDialog = () => AlertDialog(
          title: Text(
            title ?? inform,
            style: theme.textTheme.headlineSmall,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputTitleWidget(title: message, required: false),
              if (additionalWidget != null) additionalWidget,
              InputContainer(
                controller: _icReason,
                maxLines: 6,
                hint: hint,
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const ValueKey('ConfirmWithReasonDialog_cancel_btn'),
              onPressed: () {
                dismissFunc.call();
                onCanceled?.call(_icReason.text);
              },
              child: Text(
                leftBtn ?? cancel,
                style: styleLeftBtn ??
                    theme.textTheme.labelLarge?.copyWith(
                      color: context.themeColor.primary,
                    ),
              ),
            ),
            TextButton(
              key: const ValueKey('ConfirmWithReasonDialog_confirm_btn'),
              onPressed: () {
                dismissFunc.call();
                onConfirmed?.call(_icReason.text);
              },
              child: Text(
                rightBtn ?? confirm,
                style: styleRightBtn ??
                    theme.textTheme.labelLarge?.copyWith(
                      color: context.themeColor.primary,
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
                theme.textTheme.labelLarge!.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.normal,
                ),
          ),
        );
      }

      return CupertinoAlertDialog(
        title: Text(
          title ?? inform,
          style: theme.textTheme.headlineSmall,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputTitleWidget(title: message, required: false),
              if (additionalWidget != null) additionalWidget,
              InputContainer(
                controller: _icReason,
                maxLines: 4,
                hint: hint,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                key: const ValueKey('ConfirmWithReasonDialog_cancel_btn'),
                child: _buildAction(
                  onTap: () => onCanceled?.call(_icReason.text),
                  title: leftBtn ?? cancel,
                  style: styleLeftBtn,
                ),
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                key: const ValueKey('ConfirmWithReasonDialog_confirm_btn'),
                child: _buildAction(
                  onTap: () => onConfirmed?.call(_icReason.text),
                  title: rightBtn ?? confirm,
                  style: styleRightBtn,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget buildNoticeDialog({
    required String message,
    Widget? content,
    String? title,
    String? titleBtn,
    Function()? onClose,
    bool useRootNavigator = true,
    bool dismissWhenAction = true,
    bool barrierDismissible = true,
  }) {
    final dismissFunc = () {
      if (dismissWhenAction) {
        Navigator.of(context, rootNavigator: useRootNavigator).pop();
      }
    };
    final theme = context.theme;
    final showAndroidDialog = () => PopScope(
          canPop: barrierDismissible,
          child: AlertDialog(
            title: Text(
              title ?? inform,
              style: theme.textTheme.headlineSmall,
            ),
            content: content ??
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
            actions: [
              TextButton(
                key: const ValueKey('NoticeDialog_close_btn'),
                onPressed: () {
                  dismissFunc.call();
                  onClose?.call();
                },
                child: Text(titleBtn ?? ok),
              ),
            ],
          ),
        );

    if (kIsWeb) {
      return showAndroidDialog();
    } else if (Platform.isAndroid) {
      return showAndroidDialog();
    } else {
      return PopScope(
        canPop: barrierDismissible,
        child: CupertinoAlertDialog(
          title: Text(title ?? inform),
          content: Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              key: const ValueKey('NoticeDialog_close_btn'),
              onPressed: () {
                dismissFunc.call();
                onClose?.call();
              },
              child: Text(titleBtn ?? ok),
            ),
          ],
        ),
      );
    }
  }

  Widget buildActionDialog({
    Map<String, void Function()> actions = const <String, void Function()>{},
    String? title,
    String? subTitle = '',
    bool useRootNavigator = true,
    bool dimissWhenSelect = true,
    String? titleBottomBtn,
    Function()? onClose,
  }) {
    final theme = context.theme;
    if (kIsWeb || Platform.isAndroid) {
      return AlertDialog(
        title: RichText(
          text: TextSpan(
            text: title,
            style: theme.textTheme.headlineSmall,
            children: [
              if (subTitle?.isNotEmpty == true)
                TextSpan(
                  text: '\n\n',
                  children: [
                    TextSpan(
                      text: subTitle,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          ...actions.entries
              .map<TextButton>(
                (e) => TextButton(
                  key: ValueKey('ActionDialog_${e.key}'),
                  onPressed: () {
                    if (dimissWhenSelect) {
                      Navigator.of(
                        context,
                        rootNavigator: useRootNavigator,
                      ).pop();
                    }
                    e.value.call();
                  },
                  child: Text(
                    e.key,
                    style: TextStyle(
                      color: context.themeColor.primary,
                    ),
                  ),
                ),
              )
              .toList(),
          TextButton(
            key: const ValueKey('ActionDialog_close_btn'),
            onPressed: () {
              Navigator.of(context, rootNavigator: useRootNavigator).pop();
              onClose?.call();
            },
            child: Text(
              titleBottomBtn ?? cancel,
              style: TextStyle(
                color: context.themeColor.primary,
              ),
            ),
          ),
        ],
      );
    } else {
      return CupertinoActionSheet(
        actions: [
          ...actions.entries.map(
            (e) => CupertinoActionSheetAction(
              key: ValueKey('ActionDialog_${e.key}'),
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
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        title: Text(
          title ?? '',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        message: subTitle?.isNotEmpty == true
            ? Text(
                subTitle!,
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.center,
              )
            : null,
        cancelButton: CupertinoActionSheetAction(
          key: const ValueKey('ActionDialog_close_btn'),
          onPressed: () {
            Navigator.of(
              context,
              rootNavigator: useRootNavigator,
            ).pop();
            onClose?.call();
          },
          child: Text(
            titleBottomBtn ?? cancel,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget buildModalBottomSheet({
    required Widget body,
    bool useRootNavigator = true,
    String? title,
    void Function()? onClose,
    Color? backgroundColor,
    bool resizeToAvoidBottomInset = true,
  }) {
    final theme = context.theme;

    final mediaData = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxContentSize =
            constraints.maxHeight - mediaData.padding.top - 120;
        return Padding(
          padding:
              resizeToAvoidBottomInset ? mediaData.viewInsets : EdgeInsets.zero,
          child: Wrap(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: backgroundColor ?? Theme.of(context).canvasColor,
                  borderRadius: const BorderRadiusDirectional.only(
                    topEnd: Radius.circular(28),
                    topStart: Radius.circular(28),
                  ),
                  // boxShadow: context.themeColor.boxShadowLight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          margin: const EdgeInsets.only(
                            bottom: 8,
                            top: 8,
                          ),
                        ),
                      ],
                    ),
                    if (title.isNotNullOrEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              title ?? '',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            key: const ValueKey('ModalBottomSheet_close_btn'),
                            onPressed: onClose ??
                                () => Navigator.of(
                                      context,
                                      rootNavigator: useRootNavigator,
                                    ).pop(),
                            icon: Icon(
                              Icons.close,
                              size: 24,
                              color: context.themeColor.schemeAction,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const Divider(),
                    ] else
                      const SizedBox(
                        height: 4,
                      ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxContentSize),
                      child: body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildNoticeConfirmWithValidateDialog({
    required InputContainerController controller,
    String? title,
    required String message,
    required String validateString,
    String? hint,
    String? leftBtn,
    String? rightBtn,
    TextStyle? styleRightBtn,
    TextStyle? styleLeftBtn,
    bool useRootNavigator = true,
    bool dismissWhenAction = true,
    void Function()? onConfirmed,
    void Function()? onCanceled,
  }) {
    final _icValidate = controller;
    final dismissFunc = () {
      if (dismissWhenAction) {
        Navigator.of(context, rootNavigator: useRootNavigator).pop();
      }
    };
    final theme = context.theme;

    final showAndroidDialog = () => AlertDialog(
          title: Text(
            title ?? inform,
            style: theme.textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              InputContainer(
                controller: _icValidate,
                hint: hint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const ValueKey('NoticeConfirmWithValidateDialog_cancel_btn'),
              onPressed: () {
                dismissFunc.call();
                onCanceled?.call();
              },
              child: Text(
                leftBtn ?? cancel,
                style: styleLeftBtn ??
                    theme.textTheme.labelLarge?.copyWith(
                      color: context.themeColor.primary,
                    ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _icValidate.value.tdController,
              builder: (context, value, child) {
                return AvailabilityWidget(
                  enable: value.text == validateString,
                  child: child!,
                );
              },
              child: TextButton(
                key: const ValueKey(
                  'NoticeConfirmWithValidateDialog_confirm_btn',
                ),
                onPressed: () {
                  dismissFunc.call();
                  onConfirmed?.call();
                },
                child: Text(
                  rightBtn ?? confirm,
                  style: styleRightBtn ??
                      theme.textTheme.labelLarge?.copyWith(
                        color: Colors.red,
                      ),
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
                theme.textTheme.labelLarge!.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.normal,
                ),
          ),
        );
      }

      return CupertinoAlertDialog(
        title: Text(
          title ?? inform,
          style: theme.textTheme.headlineSmall,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Text(
                message,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              InputContainer(
                controller: _icValidate,
                hint: hint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                key: const ValueKey(
                  'NoticeConfirmWithValidateDialog_cancel_btn',
                ),
                child: _buildAction(
                  onTap: () => onCanceled?.call(),
                  title: leftBtn ?? cancel,
                  style: styleLeftBtn,
                ),
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                key: const ValueKey(
                  'NoticeConfirmWithValidateDialog_confirm_btn',
                ),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _icValidate.value.tdController,
                  builder: (context, value, child) {
                    return AvailabilityWidget(
                      enable: value.text == validateString,
                      child: child!,
                    );
                  },
                  child: _buildAction(
                    onTap: () => onConfirmed?.call(),
                    title: rightBtn ?? confirm,
                    style: styleRightBtn ??
                        theme.textTheme.labelLarge?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}

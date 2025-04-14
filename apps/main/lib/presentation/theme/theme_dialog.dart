import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../l10n/generated/app_localizations.dart';
import '../extentions/extention.dart';

@Injectable(as: ThemeDialog)
class AppThemeDialog extends ThemeDialog {
  AppThemeDialog(@factoryParam super.context);

  AppLocalizations get trans => translate(context);

  @override
  String get cancel => trans.cancel;

  @override
  String get confirm => trans.confirm;

  @override
  String get inform => trans.inform;

  @override
  String get ok => trans.ok;

  Widget _buildDialogBox({
    required Widget body,
    required Widget button,
    required ThemeData theme,
    TextStyle? titleStyle,
    String? title,
    Widget? icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          constraints: const BoxConstraints(
            maxWidth: 450,
          ),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon ?? const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title ?? '',
                  style: titleStyle ?? theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              Container(
                constraints: BoxConstraints(
                  maxWidth: 450,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(child: body),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 16),
                child: button,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget buildConfirmDialog({
    String? title,
    String? message,
    Widget? content,
    String? leftBtn,
    String? rightBtn,
    TextStyle? styleRightBtn,
    TextStyle? styleLeftBtn,
    bool useRootNavigator = true,
    bool dismissWhenAction = true,
    void Function()? onConfirmed,
    void Function()? onCanceled,
    Widget? icon,
    TextStyle? titleStyle,
  }) {
    final dismissFunc = (bool result) {
      if (dismissWhenAction) {
        Navigator.of(context, rootNavigator: useRootNavigator).pop(result);
      }
    };

    final theme = context.theme;
    return _buildDialogBox(
      theme: theme,
      icon: icon,
      title: title,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: content ??
                  Center(
                    child: Text(
                      message ?? '',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
            ),
          ),
        ],
      ),
      button: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: ThemeButton.outline(
                key: const ValueKey('ConfirmDialog_cancel_btn'),
                title: leftBtn ?? trans.close,
                minimumSize: const Size(88, 36.0),
                onPressed: () {
                  dismissFunc.call(false);
                  onCanceled?.call();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ThemeButton.primary(
                key: const ValueKey('ConfirmDialog_confirm_btn'),
                title: rightBtn ?? confirm,
                minimumSize: const Size(88, 36.0),
                onPressed: () {
                  dismissFunc.call(true);
                  onConfirmed?.call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
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
    void Function(String reason)? onConfirmed,
    void Function(String reason)? onCanceled,
    Widget? additionalWidget,
    bool? isRequiredReason,
  }) {
    final dismissFunc = () {
      if (dismissWhenAction) {
        Navigator.of(context, rootNavigator: useRootNavigator).pop();
      }
    };

    final theme = context.theme;
    final _icReason = controller;
    return _buildDialogBox(
      theme: theme,
      title: title,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputTitleWidget(title: message, required: false),
                const SizedBox(height: 8),
                if (additionalWidget != null) additionalWidget,
                InputContainer(
                  controller: _icReason,
                  maxLines: 4,
                  hint: hint,
                  fillColor: Colors.white,
                  titleStyle: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      button: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: ThemeButton.outline(
                key: const ValueKey('ConfirmWithReasonDialog_cancel_btn'),
                title: leftBtn ?? trans.close,
                minimumSize: const Size(88, 36.0),
                onPressed: () {
                  dismissFunc.call();
                  onCanceled?.call(_icReason.text);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ThemeButton.primary(
                key: const ValueKey('ConfirmWithReasonDialog_confirm_btn'),
                title: rightBtn ?? confirm,
                minimumSize: const Size(88, 36.0),
                onPressed: () {
                  dismissFunc.call();
                  onConfirmed?.call(_icReason.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
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
    return PopScope(
      canPop: barrierDismissible,
      child: _buildDialogBox(
        theme: theme,
        title: title ?? inform,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Center(
                  child: content ??
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                ),
              ),
            ),
          ],
        ),
        button: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ThemeButton.primary(
            key: const ValueKey('NoticeDialog_close_btn'),
            title: titleBtn ?? confirm,
            minimumSize: const Size(88, 36.0),
            onPressed: () {
              dismissFunc.call();
              onClose?.call();
            },
          ),
        ),
      ),
    );
  }
}

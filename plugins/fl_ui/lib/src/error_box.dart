import 'package:fl_theme/fl_theme.dart';
import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

import 'box_color.dart';
import 'custom_stepper.dart';

class ErrorBox extends StatefulWidget {
  final ErrorBoxController? controller;
  final Widget child;
  final EdgeInsetsGeometry errorTextPadding;
  final EdgeInsetsGeometry? errorBoxPadding;
  final TextStyle? errorStyle;
  final BorderRadius? borderRadius;
  final Color normalBorderColor;
  final String? validation;

  const ErrorBox({
    Key? key,
    required this.child,
    this.controller,
    this.errorStyle,
    this.borderRadius,
    this.normalBorderColor = Colors.transparent,
    this.errorBoxPadding,
    this.errorTextPadding = const EdgeInsets.only(top: 8),
    this.validation,
  }) : super(key: key);

  @override
  State<ErrorBox> createState() => _ErrorBoxState();
}

class _ErrorBoxState extends State<ErrorBox> {
  ErrorBoxController? controller;

  @override
  void initState() {
    controller =
        widget.controller ?? ErrorBoxController(value: widget.validation);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ErrorBox oldWidget) {
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        controller?.dispose();
      }
      controller =
          widget.controller ?? ErrorBoxController(value: widget.validation);
    } else if (widget.controller == null &&
        oldWidget.validation != widget.validation) {
      controller?.value = widget.validation;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: controller!.focusNode,
      onFocusChange: (value) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 250),
        );
      },
      child: ValueListenableBuilder<String?>(
        valueListenable: controller!,
        builder: (context, value, child) {
          final themeColor = context.themeColor;
          final decoration = context.decorationTheme;
          final borderRadius =
              widget.borderRadius ?? decoration.inputRadiusBorder;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              HighlightBoxColor(
                padding: value != null
                    ? widget.errorBoxPadding ?? EdgeInsets.zero
                    : EdgeInsets.zero,
                borderRadius: borderRadius,
                borderWidth: decoration.borderThin,
                bgColor: Colors.transparent,
                borderColor: value == null
                    ? widget.normalBorderColor
                    : themeColor.error,
                child: child,
              ),
              Builder(
                builder: (context) {
                  if (value.isNullOrEmpty) {
                    return const SizedBox();
                  }
                  return AnimatedSlideBox(
                    begin: const Offset(0.0, -1),
                    duration: const Duration(milliseconds: 167),
                    child: Padding(
                      padding: widget.errorTextPadding,
                      child: Text(
                        value!,
                        style:
                            widget.errorStyle ??
                            context.textTheme.inputError?.copyWith(
                              color: themeColor.error,
                            ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

class ErrorBoxController extends ValueNotifier<String?> {
  ErrorBoxController({String? value}) : super(value);

  final _focusNode = FocusNode();

  FocusNode get focusNode => _focusNode;

  void setError(String message) {
    value = message;
    notifyListeners();
    requestFocus();
  }

  void clear() {
    value = null;
    notifyListeners();
  }

  bool get hasError => value != null;

  void requestFocus() {
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

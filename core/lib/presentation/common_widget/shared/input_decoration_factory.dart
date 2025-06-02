import 'package:flutter/material.dart';

import '../../../core.dart';

enum TitleMode {
  floating,
  above,
}

class InputDecorationFactory {
  static InputDecoration build({
    required BuildContext context,
    required bool enable,
    String? title,
    String? hint,
    TextStyle? titleStyle,
    required bool required,
    Color? fillColor,
    TextStyle? hintStyle,
    EdgeInsetsGeometry? prefixIconPadding,
    EdgeInsetsGeometry? suffixIconPadding,
    double? prefixIconSize,
    double? suffixIconSize,
    bool? isDense,
    String? errorText,
    TextStyle? errorStyle,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final appTextTheme = context.textTheme;
    final behavior = context.theme.inputDecorationTheme.floatingLabelBehavior;
    return InputDecoration(
      label: title.isNotNullOrEmpty
          ? InputTitleWidget(
              title: title,
              required: required,
              style: (titleStyle ?? appTextTheme.inputTitle)?.let(
                (it) => it.copyWith(
                  // Reverse the scale of the floating label if it force never
                  // floating
                  // More info: packages/flutter/lib/src/material/input_decorator.dart
                  // _kFinalLabelScale
                  fontSize: behavior == FloatingLabelBehavior.never
                      ? (it.fontSize ?? 0) / 0.75
                      : null,
                ),
              ),
            )
          : null,
      labelStyle: titleStyle ?? appTextTheme.inputTitle,
      filled: !enable || fillColor != null,
      fillColor: enable ? fillColor : null,
      hintText: hint,
      hintStyle: hintStyle ?? appTextTheme.inputHint,
      errorText: errorText,
      errorStyle: (errorStyle ?? appTextTheme.inputError)?.copyWith(
        fontSize: errorText?.isNotEmpty == true ? null : 1,
      ),
      errorMaxLines: 4,
      suffixIcon: suffixIcon?.let(
        (it) => AvailabilityWidget(
          enable: enable,
          child: it,
        ),
      ),
      suffixIconConstraints: BoxConstraints(
        minHeight: suffixIconSize ?? 0,
        minWidth: suffixIconSize ?? 0,
      ),
      prefixIcon: prefixIcon,
      prefixIconConstraints: BoxConstraints(
        minHeight: prefixIconSize ?? 0,
        minWidth: prefixIconSize ?? 0,
      ),
      isDense: isDense,
      counterStyle: appTextTheme.bodySmall,
    );
  }

  static InputDecorationTheme overrideTheme({
    required BuildContext context,
    bool showBorder = true,
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    bool? alignLabelWithHint,
  }) {
    final inputDecorationTheme = context.theme.inputDecorationTheme;
    return inputDecorationTheme.copyWith(
      alignLabelWithHint: alignLabelWithHint,
      border: !showBorder
          ? InputBorder.none
          : inputDecorationTheme.border.let((it) {
              if (it is OutlineInputBorder) {
                return it.copyWith(
                  borderSide: borderSide,
                  borderRadius: borderRadius,
                );
              }
              return it?.copyWith(
                borderSide: borderSide,
              );
            }),
      enabledBorder: !showBorder
          ? InputBorder.none
          : inputDecorationTheme.enabledBorder.let((it) {
              if (it is OutlineInputBorder) {
                return it.copyWith(
                  borderSide: borderSide,
                  borderRadius: borderRadius,
                );
              }
              return it?.copyWith(
                borderSide: borderSide,
              );
            }),
      focusedBorder: !showBorder
          ? InputBorder.none
          : inputDecorationTheme.focusedBorder.let((it) {
              if (it is OutlineInputBorder) {
                return it.copyWith(
                  borderSide: borderSide,
                  borderRadius: borderRadius,
                );
              }
              return it?.copyWith(
                borderSide: borderSide,
              );
            }),
      contentPadding: contentPadding ?? inputDecorationTheme.contentPadding,
    );
  }
}

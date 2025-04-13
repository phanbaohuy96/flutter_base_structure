import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Migrate DiagnosticableMixin to Diagnosticable until
// https://github.com/flutter/flutter/pull/51495 makes it into stable (v1.15.21)
class CustomDatePickerTheme with DiagnosticableTreeMixin {
  final TextStyle? cancelStyle;
  final TextStyle? doneStyle;
  final TextStyle? itemStyle;
  final Color? backgroundColor;
  final Color? headerColor;

  final double containerHeight;
  final double titleHeight;
  final double itemHeight;
  final ThemeData? theme;

  CustomDatePickerTheme({
    TextStyle? cancelStyle,
    TextStyle? doneStyle,
    TextStyle? itemStyle,
    Color? backgroundColor,
    this.headerColor,
    this.containerHeight = 210.0,
    this.titleHeight = 44.0,
    this.itemHeight = 36.0,
    this.theme,
  })  : cancelStyle = theme?.textTheme.labelLarge,
        doneStyle = theme?.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
        backgroundColor = backgroundColor ?? theme?.primaryColor,
        itemStyle = itemStyle ?? theme?.textTheme.bodyLarge;
}

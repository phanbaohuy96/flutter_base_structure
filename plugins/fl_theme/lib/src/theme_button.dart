import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

class ThemeButton {
  ThemeButton._();

  static Widget primary({
    Key? key,
    String? title,
    void Function()? onPressed,
    bool enable = true,
    Widget? prefixIcon,
    Size minimumSize = const Size(88, 40),
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
    double? prefixSpace = 8,
    TextStyle? textStyle,
  }) =>
      ElevatedButton(
        key: key,
        onPressed: enable ? onPressed : null,
        style: ConditionBuilder.on(
          condition: () => style != null,
          value: () => style,
        ).build(
          orElse: () => ElevatedButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            textStyle: textStyle,
          ),
        ),
        child: _buildChild(
          title: title,
          prefixIcon: prefixIcon,
          prefixSpace: prefixSpace,
          mainAxisAlignment: mainAxisAlignment,
        ),
      );

  static Widget secondary({
    Key? key,
    String title = '',
    void Function()? onPressed,
    bool enable = true,
    Widget? prefixIcon,
    double? prefixSpace = 8,
    Size minimumSize = const Size(88, 40),
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
    TextStyle? textStyle,
  }) =>
      outline(
        key: key,
        title: title,
        onPressed: onPressed,
        enable: enable,
        prefixIcon: prefixIcon,
        minimumSize: minimumSize,
        mainAxisAlignment: mainAxisAlignment,
        padding: padding,
        style: style,
        prefixSpace: prefixSpace,
        textStyle: textStyle,
      );

  static Widget outline({
    Key? key,
    String? title,
    void Function()? onPressed,
    bool enable = true,
    Widget? prefixIcon,
    Size minimumSize = const Size(88, 40),
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    EdgeInsetsGeometry? padding,
    Color? foregroundColor,
    Color? backgroundColor,
    ButtonStyle? style,
    TextStyle? textStyle,
    double? prefixSpace = 8,
  }) {
    final defaultStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.resolveWith<Size>(
        (_) => minimumSize,
      ),
      padding: ConditionBuilder.on(
        condition: () => padding != null,
        value: () => WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
          (_) => padding!,
        ),
      ).build(orElse: () => null),
      backgroundColor: ConditionBuilder.on(
        condition: () => backgroundColor != null,
        value: () => _resolveAndExcludeDisabledWith<Color?>(
          (Set<WidgetState> states) {
            return backgroundColor;
          },
        ),
      ).build(orElse: () => null),
      foregroundColor: ConditionBuilder.on(
        condition: () => foregroundColor != null,
        value: () => _resolveAndExcludeDisabledWith<Color?>(
          (Set<WidgetState> states) {
            return foregroundColor;
          },
        ),
      ).build(orElse: () => null),
      side: ConditionBuilder.on(
        condition: () => foregroundColor != null,
        value: () => _resolveAndExcludeDisabledWith<BorderSide?>(
          (Set<WidgetState> states) {
            return BorderSide(
              color: foregroundColor!,
              width: 1,
            );
          },
        ),
      ).build(
        orElse: () => null,
      ),
      textStyle: ConditionBuilder.on(
        condition: () => textStyle != null,
        value: () => _resolveAndExcludeDisabledWith<TextStyle?>(
          (Set<WidgetState> states) {
            return textStyle;
          },
        ),
      ).build(
        orElse: () => null,
      ),
    );
    return OutlinedButton(
      key: key,
      onPressed: enable ? onPressed : null,
      style: ConditionBuilder.on(
        condition: () => style != null,
        value: () => style,
      ).build(
        orElse: () => defaultStyle,
      ),
      child: _buildChild(
        title: title,
        prefixIcon: prefixIcon,
        prefixSpace: prefixSpace,
        mainAxisAlignment: mainAxisAlignment,
      ),
    );
  }

  static Widget text({
    Key? key,
    required String title,
    void Function()? onPressed,
    Size minimumSize = const Size(88, 40),
    bool enable = true,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) =>
      TextButton(
        style: TextButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
        ),
        key: key,
        onPressed: enable ? onPressed : null,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      );

  static Widget _buildChild({
    String? title,
    Widget? prefixIcon,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    double? prefixSpace,
  }) {
    return ConditionBuilder<Widget>.from([
      Conditional(
        condition: () => prefixIcon != null && title != null,
        value: () => Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            prefixIcon!,
            SizedBox(width: prefixSpace),
            Text(title!),
          ],
        ),
      ),
      Conditional(
        condition: () => title != null,
        value: () => Text(
          title!,
          textAlign: TextAlign.center,
        ),
      ),
      Conditional(
        condition: () => prefixIcon != null,
        value: () => prefixIcon!,
      ),
    ]).build(
      orElse: () => const SizedBox.shrink(),
    )!;
  }

  static WidgetStateProperty<T?> _resolveAndExcludeDisabledWith<T>(
    WidgetPropertyResolver<T> callback,
  ) {
    return WidgetStateProperty.resolveWith<T?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        return callback(states);
      },
    );
  }
}

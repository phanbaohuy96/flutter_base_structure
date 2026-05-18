import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';

class BoxColor extends StatelessWidget {
  final Color? color;
  final BorderRadius? borderRadius;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final BoxShape boxShape;
  final List<BoxShadow>? boxShadow;

  const BoxColor({
    Key? key,
    this.color,
    this.borderRadius,
    this.child,
    this.padding = const EdgeInsets.fromLTRB(6, 4, 6, 4),
    this.margin,
    this.border,
    this.constraints,
    this.alignment,
    this.boxShape = BoxShape.rectangle,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      constraints: constraints,
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
        shape: boxShape,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

class HighlightBoxColor extends StatelessWidget {
  final Widget? child;
  final Color? bgColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;

  /// Default is [ThemeData.colorScheme.primary]
  final Color? borderColor;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final void Function()? onTap;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;

  const HighlightBoxColor({
    Key? key,
    this.child,
    this.margin,
    this.padding = const EdgeInsets.all(8),
    this.bgColor,
    this.borderColor,
    this.constraints,
    this.alignment,
    this.onTap,
    this.borderRadius,
    this.borderWidth,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _borderRadius =
        borderRadius ?? const BorderRadius.all(Radius.circular(8));
    final _borderWidth = borderWidth ?? 1;
    return InkWell(
      onTap: onTap,
      borderRadius: _borderRadius,
      child: BoxColor(
        padding: padding,
        color: bgColor,
        constraints: constraints,
        alignment: alignment,
        borderRadius: _borderRadius,
        margin: margin,
        boxShadow: boxShadow,
        border: Border.all(
          color: borderColor ?? context.themeColor.borderColor,
          width: _borderWidth,
        ),
        child: child,
      ),
    );
  }
}

class ChipItem extends StatelessWidget {
  final bool selected;
  final String text;
  final void Function(bool selected)? onTap;
  final TextTheme textTheme;
  final BoxConstraints? constraints;
  final Color? bgColor;
  final Color? selectedBGColor;
  final Color? color;
  final Color? selectedColor;

  const ChipItem({
    Key? key,
    required this.selected,
    required this.text,
    required this.textTheme,
    this.onTap,
    this.constraints = const BoxConstraints(minWidth: 80),
    this.bgColor,
    this.selectedBGColor,
    this.color,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = selected
        ? (selectedColor ?? context.themeColor.selected)
        : (color ?? Colors.grey);

    final _bgColor = selected
        ? (selectedBGColor ?? Theme.of(context).colorScheme.secondary)
        : (bgColor ?? Colors.transparent);
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: () => onTap?.call(selected),
      child: BoxColor(
        constraints: constraints,
        color: _bgColor,
        borderRadius: BorderRadius.circular(32),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        border: Border.all(
          width: 1,
          color: _color,
        ),
        child: Text(
          text,
          style: selected
              ? textTheme.bodyMedium?.copyWith(color: _color)
              : textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StatusBox extends StatelessWidget {
  const StatusBox({
    super.key,
    this.color,
    this.textColor,
    this.bgColor,
    this.status,
    this.hasBorder = false,
  });

  final Color? color;
  final Color? textColor;
  final Color? bgColor;
  final String? status;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return BoxColor(
      color: bgColor ?? Colors.grey[200]!,
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 12,
      ),
      border: hasBorder
          ? Border.all(
              width: 1,
              color: color ?? Colors.grey,
            )
          : null,
      constraints: const BoxConstraints(minWidth: 64),
      alignment: Alignment.center,
      child: Text(
        status ?? '--',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor ?? color ?? Colors.grey,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

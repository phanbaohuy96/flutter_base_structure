import 'package:flutter/material.dart';

import 'item_devider.dart';

class InfoItem extends StatelessWidget {
  /// [String, Widget] is supported
  final dynamic title;

  /// [String, Widget] is supported
  final dynamic value;

  /// Default using [ThemeData.primaryColor]
  final Color? color;
  final ItemDivider divider;
  final Color? dividerColor;

  final EdgeInsets padding;

  /// Default using [TextTheme.labelLarge]
  final TextStyle? titleStyle;

  /// Default using [TextTheme.bodyMedium]
  final TextStyle? valueStyle;
  final int? titleFlex;
  final int? valueFlex;
  final double spacer;
  final CrossAxisAlignment crossAxisAlignment;
  final Widget? backgroundWidget;
  final Alignment backgroundWidgetAlignment;
  final bool? required;

  const InfoItem({
    Key? key,
    required this.title,
    this.value,
    this.color,
    this.divider = ItemDivider.space,
    this.dividerColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.titleStyle,
    this.valueStyle,
    this.titleFlex = 1,
    this.valueFlex = 2,
    this.spacer = 8,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.backgroundWidget,
    this.backgroundWidgetAlignment = Alignment.topCenter,
    this.required = false,
  })  : assert(
          title is String || title is Widget,
          '$title [String, Widget] is supported',
        ),
        assert(
          value == null || value is String || value is Widget,
          '$value [String, Widget] is supported',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      margin: EdgeInsets.only(
        bottom:
            divider == ItemDivider.none || divider == ItemDivider.line ? 0 : 16,
      ),
      color: color ?? theme.primaryColor,
      child: Builder(
        builder: (context) {
          final child = Padding(
            padding: EdgeInsets.only(left: padding.left, right: padding.right),
            child: Container(
              padding:
                  EdgeInsets.only(top: padding.top, bottom: padding.bottom),
              decoration: BoxDecoration(
                border: divider == ItemDivider.line
                    ? Border(
                        bottom: BorderSide(
                          color: dividerColor ??
                              Colors.grey.withAlpha((0.1 * 255).round()),
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: crossAxisAlignment,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      final tw = title is Widget
                          ? title
                          : Text(
                              title,
                              style: titleStyle ?? textTheme.labelLarge,
                            );
                      if (titleFlex != null) {
                        return Expanded(
                          flex: titleFlex!,
                          child: tw,
                        );
                      }
                      return tw;
                    },
                  ),
                  if (required == true)
                    const Text(
                      '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(width: spacer),
                  Builder(
                    builder: (context) {
                      final vw = value is Widget
                          ? value
                          : Text(
                              value ?? '--',
                              style: valueStyle ?? textTheme.bodyMedium,
                              textAlign: TextAlign.end,
                            );
                      if (valueFlex != null) {
                        return Expanded(
                          flex: valueFlex!,
                          child: vw,
                        );
                      }
                      return vw;
                    },
                  ),
                ],
              ),
            ),
          );
          return backgroundWidget != null
              ? Stack(
                  alignment: backgroundWidgetAlignment,
                  children: [backgroundWidget!, child],
                )
              : child;
        },
      ),
    );
  }
}

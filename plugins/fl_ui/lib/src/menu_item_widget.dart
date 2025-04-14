import 'package:flutter/material.dart';

import '../fl_ui.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    Key? key,
    required this.title,
    this.icon,
    this.onTap,
    this.color,
    this.divider,
    this.itemBorder = ItemBorder.none,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.tailIcon,
    this.description,
    this.boxShadow,
    this.titleStyle,
  })  : assert(
          title is String || title is Widget,
          '$title [String, Widget] is supported',
        ),
        super(key: key);

  /// [String, Widget] is supported
  final dynamic title;
  final TextStyle? titleStyle;
  final void Function()? onTap;
  final Widget? icon;
  final Color? color;
  final ItemDivider? divider;
  final ItemBorder itemBorder;
  final EdgeInsets padding;
  final Widget? tailIcon;
  final Widget? description;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    BorderRadius? borderRadius;
    switch (itemBorder) {
      case ItemBorder.all:
        borderRadius = BorderRadius.circular(8);
        break;
      case ItemBorder.top:
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        );

        break;
      case ItemBorder.bottom:
        borderRadius = const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );

        break;
      default:
    }
    final theme = Theme.of(context);
    final bgColor = color ?? theme.primaryColor;
    return AvailabilityWidget(
      enable: onTap != null,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: divider != ItemDivider.space ? 0 : 16,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: bgColor,
                boxShadow: boxShadow,
                borderRadius: borderRadius,
                gradient: divider == ItemDivider.line &&
                        itemBorder != ItemBorder.bottom &&
                        itemBorder != ItemBorder.all
                    ? LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.01, 0.01],
                        colors: [Colors.black12, bgColor],
                      )
                    : null,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: title is Widget
                        ? title
                        : Text(
                            title,
                            style: titleStyle ??
                                Theme.of(context).textTheme.titleSmall,
                          ),
                  ),
                  if (description != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: description!,
                    ),
                  if (tailIcon != null) tailIcon!,
                  if (onTap != null && tailIcon == null)
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

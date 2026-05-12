import 'package:badges/badges.dart' as badge;
import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';

class BadgeBox extends StatelessWidget {
  final int count;
  final Color? countTextColor;
  final Color? backgroundColor;
  final Widget child;
  final badge.BadgePosition? badgePosition;
  final int maxCount;

  const BadgeBox({
    Key? key,
    required this.count,
    required this.child,
    this.countTextColor,
    this.backgroundColor,
    this.badgePosition,
    this.maxCount = 99,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = context.themeColor;
    final decoration = context.decorationTheme;
    final resolvedBackgroundColor = backgroundColor ?? themeColor.error;
    final resolvedTextColor = countTextColor ?? themeColor.onError;

    return badge.Badge(
      showBadge: count > 0,
      badgeContent: Container(
        alignment: Alignment.center,
        child: Text(
          count > maxCount ? '$maxCount+' : '$count',
          style: context.textTheme.labelSmall?.copyWith(
            color: resolvedTextColor,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
        ),
      ),
      position: badgePosition ?? badge.BadgePosition.topEnd(top: -4, end: -5),
      badgeAnimation: const badge.BadgeAnimation.scale(
        toAnimate: true,
        animationDuration: Duration(milliseconds: 250),
      ),
      badgeStyle: badge.BadgeStyle(
        badgeColor: resolvedBackgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: decoration.spaceXs,
          vertical: decoration.spaceXxs / 2,
        ),
        shape: badge.BadgeShape.square,
        borderRadius: decoration.chipRadiusBorder,
      ),
      child: child,
    );
  }
}

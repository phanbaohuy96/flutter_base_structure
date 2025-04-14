import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';

class BadgeBox extends StatelessWidget {
  final int count;
  final Color countTextColor;
  final Color backgroundColor;
  final Widget child;
  final badge.BadgePosition? badgePosition;
  const BadgeBox({
    Key? key,
    required this.count,
    required this.child,
    this.countTextColor = Colors.white,
    this.backgroundColor = const Color(0xFFEC3505),
    this.badgePosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return badge.Badge(
      showBadge: count > 0,
      badgeContent: Container(
        alignment: Alignment.center,
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: countTextColor,
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
        badgeColor: backgroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 1,
        ),
        shape: badge.BadgeShape.square,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

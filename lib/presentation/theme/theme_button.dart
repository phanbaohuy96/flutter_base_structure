import 'package:flutter/material.dart';

import 'theme_color.dart';

class ThemeButton {
  static TextStyle? getTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.button;
  }

  static Widget primary({
    required BuildContext context,
    required String title,
    Function()? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
    bool enable = true,
  }) =>
      RawMaterialButton(
        fillColor: enable
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withAlpha(55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onPressed: enable ? onPressed : null,
        elevation: 0,
        padding: padding,
        constraints: constraints,
        child: Text(
          title,
          style: getTextStyle(context)!.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );

  static Widget primaryIcon({
    required BuildContext context,
    required String title,
    required Widget icon,
    Function()? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 15,
    ),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
  }) =>
      RawMaterialButton(
        fillColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onPressed: onPressed,
        elevation: 0,
        padding: padding,
        constraints: constraints,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                title,
                style: getTextStyle(context)!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            icon,
          ],
        ),
      );

  static Widget notRecommend({
    required BuildContext context,
    String title = '',
    Function()? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
    bool enable = true,
  }) =>
      RawMaterialButton(
        fillColor: enable
            ? AppColor.greyDC
            : Theme.of(context).colorScheme.primary.withAlpha(55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onPressed: enable ? onPressed : null,
        elevation: 0,
        padding: padding,
        constraints: constraints,
        child: Text(
          title,
          style: getTextStyle(context)!.copyWith(
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      );

  static Widget denied({
    required BuildContext context,
    String title = '',
    Function()? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
    bool? reverseColor,
  }) =>
      RawMaterialButton(
        fillColor: reverseColor == true ? Colors.red : const Color(0xffFFF0F1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onPressed: onPressed,
        elevation: 0,
        padding: padding,
        constraints: constraints,
        child: Text(
          title,
          style: getTextStyle(context)!.copyWith(
            color: reverseColor == true ? AppColor.white : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      );

  static Widget recommend({
    required BuildContext context,
    required String title,
    Function()? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
    bool enable = true,
  }) {
    return ThemeButton.primary(
      context: context,
      title: title,
      onPressed: onPressed,
      padding: padding,
      constraints: constraints,
      enable: enable,
    );
  }
}

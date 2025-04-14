import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ExtendedFab extends StatelessWidget {
  const ExtendedFab({
    super.key,
    this.onPressed,
    required this.label,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Widget label;
  final Widget? icon;

  factory ExtendedFab.add({
    Key? key,
    required String label,
    VoidCallback? onPressed,
  }) =>
      ExtendedFab(
        key: key,
        label: Text(label),
        onPressed: onPressed,
        icon: const Icon(Icons.add),
      );

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: label,
      icon: icon,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: context.themeColor.primary,
      foregroundColor: context.themeColor.elevatedBtnForegroundColor,
    );
  }
}

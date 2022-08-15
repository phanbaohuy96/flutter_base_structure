import 'package:flutter/material.dart';

class AvailabilityWidget extends StatelessWidget {
  final bool enable;
  final Widget child;

  const AvailabilityWidget({
    Key? key,
    required this.child,
    this.enable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (enable) {
      return child;
    }
    return AbsorbPointer(
      absorbing: true,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: child,
      ),
    );
  }
}

import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/cupertino.dart';

class Loading extends StatelessWidget {
  final Brightness? brightness;
  final double radius;

  const Loading({
    Key? key,
    this.brightness,
    this.radius = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
        brightness: brightness ?? context.theme.brightness,
      ),
      child: CupertinoActivityIndicator(
        radius: radius,
      ),
    );
  }
}

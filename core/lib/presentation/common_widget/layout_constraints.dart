import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MobileSizeLayoutConstraints extends StatelessWidget {
  const MobileSizeLayoutConstraints({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final aspectRatio = const Size(3, 4).aspectRatio;
          final screenRatio = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          ).aspectRatio;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenRatio > aspectRatio
                    ? constraints.maxHeight * aspectRatio
                    : constraints.maxWidth,
              ),
              child: child,
            ),
          );
        },
      );
    }
    return child;
  }
}

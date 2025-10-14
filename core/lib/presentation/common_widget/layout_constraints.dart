import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MobileSizeLayoutConstraints extends StatelessWidget {
  const MobileSizeLayoutConstraints({
    super.key,
    required this.child,
    this.aspectRatio = 3 / 4,
  });

  final Widget child;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dimensions = _calculateDimensions(constraints);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(size: dimensions),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dimensions.width),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Size _calculateDimensions(BoxConstraints constraints) {
    final screenRatio = constraints.maxWidth / constraints.maxHeight;

    if (screenRatio > aspectRatio) {
      // Screen is wider than target aspect ratio - constrain by height
      final width = constraints.maxHeight * aspectRatio;
      return Size(width, constraints.maxHeight);
    } else {
      // Screen is taller than target aspect ratio - constrain by width
      final height = constraints.maxWidth / aspectRatio;
      return Size(constraints.maxWidth, height);
    }
  }
}

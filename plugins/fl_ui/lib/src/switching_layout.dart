import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum SwitchingAnimation {
  swipeLTR, //Left to right
  swipeRTL, //Right to left
  swipeTTB, //Top to bottom
  swipeBTT, //Bottom to top
}

class LayoutSwitching extends StatefulWidget {
  final Duration duration;
  final Widget first;
  final Widget second;
  final bool isFirstLayout;
  final SwitchingAnimation direction;

  const LayoutSwitching({
    Key? key,
    required this.first,
    required this.second,
    this.isFirstLayout = true,
    this.duration = const Duration(milliseconds: 250),
    this.direction = SwitchingAnimation.swipeRTL,
  }) : super(key: key);

  @override
  State<LayoutSwitching> createState() => _LayoutSwitchingState();
}

class _LayoutSwitchingState extends State<LayoutSwitching> {
  late String uuid;

  @override
  void initState() {
    uuid = const Uuid().v4();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      reverseDuration: widget.duration,
      transitionBuilder: (child, animation) {
        return widget.direction.transitionBuilder(
          child,
          animation,
          child.key.toString().contains('false'),
        );
      },
      child: SizedBox(
        key: ValueKey('$uuid - ${widget.isFirstLayout}'),
        child: widget.isFirstLayout ? widget.first : widget.second,
      ),
    );
  }
}

extension _SwitchDirectionExt on SwitchingAnimation {
  Widget transitionBuilder(
    Widget child,
    Animation<double> animation,
    bool isReverse,
  ) {
    switch (this) {
      case SwitchingAnimation.swipeRTL:
      case SwitchingAnimation.swipeLTR:
        return _buildHorizontalAnim(
          child,
          animation,
          isReverse,
        );
      case SwitchingAnimation.swipeBTT:
      case SwitchingAnimation.swipeTTB:
        return _buildVerticalAnim(
          child,
          animation,
          isReverse,
        );
    }
  }

  Widget _buildHorizontalAnim(
    Widget child,
    Animation<double> animation,
    bool isReverse,
  ) {
    Offset begin;
    const end = Offset.zero;
    if (this == SwitchingAnimation.swipeLTR) {
      if (isReverse) {
        begin = const Offset(-1, 0);
      } else {
        begin = const Offset(1, 0);
      }
    } else {
      if (isReverse) {
        begin = const Offset(1, 0);
      } else {
        begin = const Offset(-1, 0);
      }
    }

    return SlideTransition(
      position: animation.drive(
        Tween(begin: begin, end: end).chain(
          CurveTween(
            curve: Curves.linear,
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _buildVerticalAnim(
    Widget child,
    Animation<double> animation,
    bool isReverse,
  ) {
    Offset begin;
    const end = Offset.zero;
    if (this == SwitchingAnimation.swipeBTT) {
      begin = const Offset(0.0, 1.0);
      if (isReverse) {
        // Reverse the direction for reverse animation
        begin = const Offset(0.0, -1.0);
      } else {
        begin = const Offset(0.0, 1.0);
      }
    } else {
      if (isReverse) {
        // Reverse the direction for reverse animation
        begin = const Offset(0.0, 1.0);
      } else {
        begin = const Offset(0.0, -1.0);
      }
    }
    return SlideTransition(
      position: animation.drive(
        Tween(begin: begin, end: end).chain(
          CurveTween(
            curve: Curves.linear,
          ),
        ),
      ),
      child: child,
    );
  }
}

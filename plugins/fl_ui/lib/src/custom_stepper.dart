import 'package:flutter/material.dart';

class StepData {
  final Widget step;
  final Widget title;
  final Widget content;
  final Color dividerColor;
  final bool showDivider;
  final EdgeInsetsGeometry contentPadding;
  final double stepSize;

  StepData({
    required this.step,
    required this.title,
    required this.content,
    required this.dividerColor,
    this.showDivider = true,
    this.contentPadding = const EdgeInsets.only(
      left: 24,
    ),
    this.stepSize = 24.0,
  });

  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: stepSize / 2,
              ),
              child: SizedBox(
                width: stepSize,
                height: stepSize,
                child: step,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: stepSize / 2,
                ),
                child: title,
              ),
            ),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: stepSize / 2 - 0.5,
                ),
                width: 1,
                color: showDivider ? dividerColor : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: contentPadding,
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class VerticalStepper extends StatelessWidget {
  final List<StepData> steps;

  const VerticalStepper({
    Key? key,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          steps.length,
          (index) => AnimatedSlideBox(
            duration: const Duration(milliseconds: 500),
            begin: Offset(0.0, -1 * (index + 1)),
            child: steps[index].build(context),
          ),
        ),
      ),
    );
  }
}

class AnimatedSlideBox extends StatefulWidget {
  final Widget? child;
  final Offset begin;
  final Offset end;
  final Duration duration;

  const AnimatedSlideBox({
    Key? key,
    this.child,
    this.begin = const Offset(0.0, -0.5),
    this.end = Offset.zero,
    this.duration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<AnimatedSlideBox> createState() => _AnimatedSlideBoxState();
}

class _AnimatedSlideBoxState extends State<AnimatedSlideBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..forward();
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: widget.begin,
    end: widget.end,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}

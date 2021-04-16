import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final Future<bool> Function(bool) onChanging;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeTextColor;
  final Color inactiveTextColor;

  const CustomSwitch({
    Key? key,
    required this.value,
    required this.onChanging,
    required this.activeColor,
    this.inactiveColor = Colors.grey,
    this.activeTextColor = Colors.white70,
    this.inactiveTextColor = Colors.white70,
  }) : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
    _circleAnimation = AlignmentTween(
      begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
      end: widget.value ? Alignment.centerLeft : Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () async {
            if (await widget
                .onChanging(_circleAnimation.value == Alignment.centerLeft)) {
              if (_animationController.isCompleted) {
                await _animationController.reverse();
              } else {
                await _animationController.forward();
              }
            }
          },
          child: Container(
            width: 34.0,
            height: 18.0,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: _circleAnimation.value == Alignment.centerLeft
                  ? widget.inactiveColor
                  : widget.activeColor,
            ),
            child: Row(
              mainAxisAlignment: _circleAnimation.value == Alignment.centerLeft
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: <Widget>[
                Align(
                  alignment: _circleAnimation.value,
                  child: Container(
                    width: 14.0,
                    height: 14.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

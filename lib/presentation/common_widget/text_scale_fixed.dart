import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TextScaleFixed extends StatefulWidget {
  final double scaleFixedFactor;
  final Widget child;

  TextScaleFixed({this.scaleFixedFactor = 1, this.child});
  @override
  _TextScaleFixedState createState() => _TextScaleFixedState();
}

class _TextScaleFixedState extends State<TextScaleFixed> {
  double scaleFixedFactor = 0.0;

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    if (scaleFixedFactor == 0.0) {
      return const SizedBox();
    }
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: scaleFixedFactor,
      ),
      child: widget.child,
    );
  }

  void postFrameCallback(_) {
    if (scaleFixedFactor != widget.scaleFixedFactor) {
      setState(() {
        scaleFixedFactor = widget.scaleFixedFactor ?? 1;
      });
    }
  }
}

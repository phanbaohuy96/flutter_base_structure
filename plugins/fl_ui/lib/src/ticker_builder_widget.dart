import 'dart:async';

import 'package:flutter/material.dart';

class TickerBuilder extends StatefulWidget {
  const TickerBuilder({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.tickLimit,
  });

  final Widget Function(BuildContext, int tick) builder;
  final Duration duration;
  final int? tickLimit;

  @override
  State<TickerBuilder> createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder> {
  int tick = 0;
  @override
  void didChangeDependencies() {
    startTimer(widget.duration);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TickerBuilder oldWidget) {
    if ([
      oldWidget.duration.inMilliseconds != widget.duration.inMilliseconds,
      oldWidget.tickLimit != widget.tickLimit,
    ].any((e) => e)) {
      startTimer(widget.duration);
    }
    super.didUpdateWidget(oldWidget);
  }

  Timer? _timer;

  void startTimer(Duration duration) {
    if (widget.tickLimit != null && tick > widget.tickLimit!) {
      _cancelTimer();
      return;
    }

    _cancelTimer();
    _timer = Timer.periodic(
      duration,
      (Timer timer) => setState(
        () {
          _timer = timer;
          tick++;
          if (widget.tickLimit != null && tick > widget.tickLimit!) {
            timer.cancel();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, tick);
  }
}

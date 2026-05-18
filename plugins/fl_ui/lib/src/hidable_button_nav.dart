import 'dart:math';

import 'package:flutter/material.dart';

import 'measure_size.dart';

class HidableBottomScrollListener extends ChangeNotifier {
  double bottom = 0;
  double _last = 0;
  double _height = 0;

  ScrollController? activeScroll;

  final _controllers = <ScrollController>[];
  final _listeners = <void Function()>[];

  HidableBottomScrollListener(List<ScrollController> controllers) {
    controllers.forEach(addController);
  }

  double get height => _height;

  void setHeight(double height) {
    _height = height;
    bottom = 0;
    notifyListeners();
  }

  void addController(ScrollController controller) {
    if (!_controllers.contains(controller)) {
      _controllers.add(controller);
      final ls = () => listenOnCtrl(controller);
      controller.addListener(ls);
      _listeners.add(ls);
    }
  }

  void listenOnCtrl(ScrollController controller) {
    // Prevent bouncing physic
    final pos = controller.positions.first;
    final offset = pos.pixels;
    if (offset <= 0 || offset > pos.maxScrollExtent) {
      return;
    }
    if (activeScroll != null && activeScroll != controller) {
      _last = 0;
      bottom = _height;
    }

    activeScroll = controller;

    final current = offset;
    bottom += _last - current;
    if (bottom <= -_height) {
      bottom = -_height;
    }
    if (bottom >= 0) {
      bottom = 0;
    }
    _last = current;
    if (bottom <= 0 && bottom >= -_height) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      for (final ls in _listeners) {
        controller.removeListener(ls);
      }
    }
    _controllers.clear();
    _listeners.clear();
    super.dispose();
  }
}

class HidableBottomNav extends StatefulWidget {
  const HidableBottomNav({
    super.key,
    this.scrollControllers = const [],
    required this.child,
  });
  final List<ScrollController> scrollControllers;
  final Widget child;

  @override
  State<HidableBottomNav> createState() => HidableBottomNavState();
}

class HidableBottomNavState extends State<HidableBottomNav> {
  late final listener = HidableBottomScrollListener(
    widget.scrollControllers,
  );

  double maxHeight = 0.0;

  void show() {
    listener.setHeight(maxHeight);
  }

  void hide() {
    listener.setHeight(0);
  }

  void addListener(ScrollController p1) {
    listener.addController(p1);
  }

  @override
  void dispose() {
    listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listener,
      builder: (context, child) {
        return SizedBox(
          height: listener.height + listener.bottom,
          child: child!,
        );
      },
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: MeasureSize(
          onChange: (size) {
            maxHeight = max(maxHeight, size.height);
            final bottomBarHeight = listener.height;
            if (bottomBarHeight < size.height) {
              listener.setHeight(size.height);
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

class ScrollIndicator extends StatefulWidget {
  ///scrollController listview/gridview
  ///
  final ScrollController scrollController;
  final double width, height;
  final Decoration decoration, indicatorDecoration;
  final AlignmentGeometry alignment;
  final Size indicatorSize;
  ScrollIndicator({
    required this.scrollController,
    this.width = 100,
    this.height = 10,
    this.decoration = const BoxDecoration(color: Colors.black26),
    this.indicatorDecoration = const BoxDecoration(color: Colors.black),
    this.alignment = Alignment.center,
    this.indicatorSize = const Size(20, 5),
  });

  @override
  _ScrollIndicatorState createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<ScrollIndicator> {
  double move = 0.0;

  double get offsetPos =>
      (widget.height - widget.indicatorSize.height).abs() / 2;

  double get maxScrollWidth {
    return widget.width - offsetPos * 2 + widget.indicatorSize.width;
  }

  @override
  void initState() {
    _calPos();
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ScrollIndicator oldWidget) {
    widget.scrollController
      ..removeListener(_scrollListener)
      ..addListener(_scrollListener);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    widget.scrollController.addListener(_scrollListener);
    super.didChangeDependencies();
  }

  void _scrollListener() {
    setState(() {
      if (mounted) {
        _calPos();
      }
    });
  }

  void _calPos() {
    final pos = widget.scrollController.position;
    if (pos.hasContentDimensions) {
      final scrollPer = pos.pixels / pos.maxScrollExtent * maxScrollWidth;
      move = scrollPer + offsetPos;
    } else {
      move = offsetPos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Container(
        height: widget.height,
        width: widget.width + widget.indicatorSize.width * 2,
        decoration: widget.decoration,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: max(0, widget.height - widget.indicatorSize.height) / 2,
              left: move,
              child: Container(
                height: widget.indicatorSize.height,
                width: widget.indicatorSize.width,
                decoration: widget.indicatorDecoration,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

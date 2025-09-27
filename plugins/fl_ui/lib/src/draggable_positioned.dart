import 'dart:math';

import 'package:flutter/material.dart';

/// DraggablePositioned widget which is always aligned to
/// the edge of the screen - be it left,top, right,bottom
class DraggablePositioned extends StatefulWidget {
  final Widget child;
  final Offset? initPosition;
  final Offset? from;
  final double securityBottom;
  final void Function(Offset offset)? onDragEnd;
  final BoxConstraints? layoutConstraints;
  final Size? childSize;

  const DraggablePositioned({
    Key? key,
    required this.child,
    this.initPosition,
    this.from,
    this.securityBottom = 0,
    this.onDragEnd,
    this.layoutConstraints,
    this.childSize,
  }) : super(key: key);

  @override
  _DraggablePositionedState createState() => _DraggablePositionedState();
}

class _DraggablePositionedState extends State<DraggablePositioned> {
  late Size _widgetSize;
  double? _left, _top;
  double _screenWidth = 0.0, _screenHeight = 0.0;
  double? _screenWidthMid, _screenHeightMid;

  @override
  void initState() {
    super.initState();
    _setupLayoutSize();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _getWidgetSize(context),
    );
  }

  void _getWidgetSize(BuildContext context) {
    _widgetSize = context.size!;

    if (widget.initPosition != null) {
      _calculatePosition(widget.initPosition!);
    }
  }

  void _setupLayoutSize() {
    if (widget.layoutConstraints != null) {
      _screenWidth = widget.layoutConstraints!.maxWidth;
      _screenHeight = widget.layoutConstraints!.maxHeight;
      _screenWidthMid = _screenWidth / 2 - (widget.childSize?.width ?? 0) / 2;
      _screenHeightMid =
          _screenHeight / 2 - (widget.childSize?.height ?? 0) / 2;
    }
  }

  @override
  void didUpdateWidget(covariant DraggablePositioned oldWidget) {
    if (oldWidget.from?.dy != widget.from?.dy ||
        oldWidget.from?.dx != widget.from?.dx) {
      animated = false;
      _left = null;
      _top = null;
    }
    _setupLayoutSize();
    super.didUpdateWidget(oldWidget);
  }

  bool animated = false;

  @override
  Widget build(BuildContext context) {
    if (!animated && widget.from != null && widget.initPosition != null) {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 150),
        left: _left ?? widget.from!.dx,
        top: _top ?? widget.from!.dy,
        onEnd: () {
          setState(() {
            animated = true;
          });
        },
        child: widget.child,
      );
    }
    return Positioned(
      left: _left,
      top: _top,
      child: Draggable(
        feedback: widget.child,
        onDragEnd: _handleDragEnded,
        childWhenDragging: const SizedBox(),
        child: widget.child,
      ),
    );
  }

  void _handleDragEnded(DraggableDetails draggableDetails) {
    _calculatePosition(draggableDetails.offset);
    widget.onDragEnd?.call(draggableDetails.offset);
  }

  void _calculatePosition(Offset targetOffset) {
    if (_screenWidthMid == null || _screenHeightMid == null) {
      final screenSize = MediaQuery.of(context).size;
      _screenWidth = screenSize.width;
      _screenHeight = screenSize.height;
      _screenWidthMid = _screenWidth / 2;
      _screenHeightMid = _screenHeight / 2;
    }
    final anchor = _getAnchor(targetOffset);
    switch (anchor) {
      case _Anchor.leftFirst:
        _left = 0;
        _top = max(_widgetSize.height / 2, targetOffset.dy);
        break;
      case _Anchor.topFirst:
        _left = max(_widgetSize.width / 2, targetOffset.dx);
        _top = 0;
        break;
      case _Anchor.rightSecond:
        _left = _screenWidth - _widgetSize.width;
        _top = max(_widgetSize.height, targetOffset.dy);
        break;
      case _Anchor.topSecond:
        _left = min(_screenWidth - _widgetSize.width, targetOffset.dx);
        _top = 0;
        break;
      case _Anchor.leftThird:
        _left = 0;
        _top = min(
          _screenHeight - _widgetSize.height - widget.securityBottom,
          targetOffset.dy,
        );
        break;
      case _Anchor.bottomThird:
        _left = _widgetSize.width / 2;
        _top = _screenHeight - _widgetSize.height - widget.securityBottom;
        break;
      case _Anchor.rightFourth:
        _left = _screenWidth - _widgetSize.width;
        _top = min(
          _screenHeight - _widgetSize.height - widget.securityBottom,
          targetOffset.dy,
        );
        break;
      case _Anchor.bottomFourth:
        _left = _screenWidth - _widgetSize.width;
        _top = _screenHeight - _widgetSize.height - widget.securityBottom;
        break;
    }
    setState(() {});
  }

  /// Computes the appropriate anchor screen edge for the widget
  _Anchor _getAnchor(Offset position) {
    if (position.dx < _screenWidthMid! && position.dy < _screenHeightMid!) {
      return position.dx < position.dy ? _Anchor.leftFirst : _Anchor.topFirst;
    } else if (position.dx >= _screenWidthMid! &&
        position.dy < _screenHeightMid!) {
      return _screenWidth - position.dx < position.dy
          ? _Anchor.rightSecond
          : _Anchor.topSecond;
    } else if (position.dx < _screenWidthMid! &&
        position.dy >= _screenHeightMid!) {
      return position.dx < _screenHeight - position.dy
          ? _Anchor.leftThird
          : _Anchor.bottomThird;
    } else {
      return _screenWidth - position.dx < _screenHeight - position.dy
          ? _Anchor.rightFourth
          : _Anchor.bottomFourth;
    }
  }
}

/// #######################################
/// #       |          #        |         #
/// #    topFirst      #   topSecond      #
/// # -  leftFirst     #  rightSecond -   #
/// #######################################
/// # -  leftThird     #   rightFourth -  #
/// #   bottomThird    #   bottomFourth   #
/// #       |          #       |          #
/// #######################################
enum _Anchor {
  leftFirst,
  topFirst,
  rightSecond,
  topSecond,
  leftThird,
  bottomThird,
  rightFourth,
  bottomFourth
}

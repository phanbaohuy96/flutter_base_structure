import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef OnWidgetSizeChange = void Function(Size size);

typedef WidgetBuilder = Widget Function(BuildContext context, Size size);

class MeasureSizeBuilder extends StatefulWidget {
  final WidgetBuilder builder;

  const MeasureSizeBuilder({
    Key key,
    @required this.builder,
  }) : super(key: key);

  @override
  _MeasureSizeBuilderState createState() => _MeasureSizeBuilderState();
}

class _MeasureSizeBuilderState extends State<MeasureSizeBuilder> {
  final GlobalKey widgetKey = GlobalKey();
  Size oldSize;
  Orientation lastOrientation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return LayoutBuilder(
      builder: (context, _) {
        final orientation = MediaQuery.of(context).orientation;
        if (lastOrientation != null && lastOrientation != orientation) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
        }
        lastOrientation = orientation;
        return SizedBox(
          height: double.infinity,
          width: double.infinity,
          key: widgetKey,
          child: widget.builder?.call(context, oldSize),
        );
      },
    );
  }

  void postFrameCallback(_) {
    final context = widgetKey.currentContext;
    if (context == null) {
      return;
    }

    final newSize = context.size;
    if (oldSize == newSize) {
      return;
    }
    setState(() {
      oldSize = newSize;
    });
  }
}

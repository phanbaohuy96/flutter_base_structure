import 'package:flutter/cupertino.dart';

class KeepAliveWidget extends StatefulWidget {
  const KeepAliveWidget({
    Key? key,
    required this.child,
    this.wantKeepAlive = true,
  }) : super(key: key);

  final Widget child;
  final bool wantKeepAlive;

  @override
  State<KeepAliveWidget> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.wantKeepAlive;

  @override
  void didUpdateWidget(covariant KeepAliveWidget oldWidget) {
    if (widget.wantKeepAlive != oldWidget.wantKeepAlive) {
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

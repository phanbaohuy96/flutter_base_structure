import 'package:flutter/cupertino.dart';

class KeepAliveWidget extends StatefulWidget {
  const KeepAliveWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<KeepAliveWidget> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

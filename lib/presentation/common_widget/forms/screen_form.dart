import 'package:flutter/material.dart';

import '../../../common/constants.dart';

class ScreenForm extends StatefulWidget {
  final String? title;
  final Widget? child;
  final double elevation;

  const ScreenForm({
    Key? key,
    this.title,
    this.child,
    this.elevation = 3,
  }) : super(key: key);

  @override
  _ScreenFormState createState() => _ScreenFormState();
}

class _ScreenFormState extends State<ScreenForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? '',
          style: theme.textTheme.headline5,
        ),
        leading: IconButton(
          icon: Image.asset(
            ImageConstant.iconChevronLeft,
            width: 18,
            height: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: widget.elevation,
        titleSpacing: 0,
      ),
      body: widget.child,
    );
  }
}

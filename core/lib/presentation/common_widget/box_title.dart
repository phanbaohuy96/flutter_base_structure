import 'package:flutter/material.dart';

import '../extentions/context_extention.dart';

class BoxTitle extends StatelessWidget {
  final Widget? titleWidget;
  final Widget child;
  final TextStyle? textStyle;
  final String? title;
  final List<Widget> actions;
  final EdgeInsetsGeometry titlePadding;
  final bool isRequired;

  const BoxTitle({
    Key? key,
    this.titleWidget,
    required this.child,
    this.title,
    this.textStyle,
    this.isRequired = false,
    this.actions = const [],
    this.titlePadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  })  : assert(
          title != null || titleWidget != null,
          'Please provide BoxTitle.title || BoxTitle.titleWidget',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? context.textTheme.titleMedium;

    final _titleWidget = titleWidget ??
        RichText(
          text: TextSpan(
            text: title,
            style: style,
            children: [
              if (isRequired == true)
                TextSpan(
                  text: ' *',
                  style: style?.copyWith(
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: titlePadding,
          child: actions.isEmpty
              ? _titleWidget
              : Row(children: [Expanded(child: _titleWidget), ...actions]),
        ),
        child,
      ],
    );
  }
}

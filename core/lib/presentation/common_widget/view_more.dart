import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';

import 'html_widget_wrapper.dart';

class HtmlWidgetWithViewMore extends StatelessWidget {
  final String htmlContent;
  final bool expand;
  final String viewMore;
  final String seeLess;
  final double minHeight;
  final TextStyle? style;

  const HtmlWidgetWithViewMore({
    Key? key,
    required this.htmlContent,
    this.expand = false,
    required this.viewMore,
    required this.seeLess,
    this.minHeight = 200,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewMoreWidget(
      viewMore: viewMore,
      seeLess: seeLess,
      minHeight: minHeight,
      child: HtmlWidgetWrapper(
        htmlContent: htmlContent,
        textStyle: style,
      ),
    );
  }
}

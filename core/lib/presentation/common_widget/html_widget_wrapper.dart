import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fwfh_chewie/fwfh_chewie.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../common/utils/core_common_function.dart';

class HtmlWidgetWrapper extends StatelessWidget {
  final String htmlContent;
  final TextStyle? textStyle;
  final FutureOr<bool> Function(String)? onTapUrl;
  final bool wrapStyle;
  final bool center;
  final bool? buildAsync;
  final bool usingWebView;

  const HtmlWidgetWrapper({
    super.key,
    required this.htmlContent,
    this.textStyle,
    this.onTapUrl,
    this.wrapStyle = true,
    this.center = false,
    this.buildAsync,
    this.usingWebView = true,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      wrapStyle
          ? CoreCommonFunction().wrapStyleHtmlContent(
              htmlContent,
              isCenter: center,
            )
          : htmlContent,
      buildAsync: buildAsync,
      customStylesBuilder: CoreCommonFunction().customStylesBuilder,
      factoryBuilder: () => CustomHTMLWidgetFactory(
        usingWebView: usingWebView,
      ),
      onTapUrl: (p0) {
        if (onTapUrl != null) {
          return onTapUrl!.call(p0);
        }
        launchUrlString(p0);
        return true;
      },
      textStyle: textStyle,
    );
  }
}

class CustomHTMLWidgetFactory extends WidgetFactory implements ChewieFactory {
  final bool usingWebView;

  CustomHTMLWidgetFactory({this.usingWebView = true});

  @override
  bool get webView => usingWebView;
}

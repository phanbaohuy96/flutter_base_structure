part of 'webview_screen.dart';

extension WebviewAction on _WebViewScreenState {
  String? get url {
    if (widget.params?.url?.isNotEmpty != true) {
      return null;
    }
    if (widget.params?.url?.startsWith('http://') == false &&
        widget.params?.url?.startsWith('https://') == false) {
      return 'http://${widget.params?.url}';
    } else {
      return widget.params?.url;
    }
  }

  String get htmlContent {
    return CoreCommonFunction().wrapStyleHtmlContent(widget.params?.html ?? '');
  }
}

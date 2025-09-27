part of 'webview_screen.dart';

extension WebviewAction on _WebViewScreenState {
  String? get url {
    final paramUrl = widget.params?.url?.let(Uri.decodeComponent);
    if (paramUrl?.isNotEmpty != true) {
      return null;
    }
    if (paramUrl?.startsWith('http://') == false &&
        paramUrl?.startsWith('https://') == false) {
      return 'http://$paramUrl';
    } else {
      return paramUrl;
    }
  }

  String get htmlContent {
    return CoreCommonFunction().wrapStyleHtmlContent(widget.params?.html ?? '');
  }
}

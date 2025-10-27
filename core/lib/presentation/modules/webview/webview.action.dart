part of 'webview_screen.dart';

extension WebviewAction on _WebViewScreenState {
  String? get url {
    final paramUrl = widget.params?.url;
    if (paramUrl?.isEmpty != false) {
      return null;
    }

    try {
      final decodedUrl = Uri.decodeComponent(paramUrl!);

      // Validate URL format
      if (decodedUrl.isEmpty) {
        return null;
      }

      // Add protocol if missing
      if (!decodedUrl.startsWith('http://') &&
          !decodedUrl.startsWith('https://')) {
        return 'https://$decodedUrl';
      }

      // Validate URI
      final uri = Uri.parse(decodedUrl);
      if (!uri.hasAuthority) {
        throw const FormatException('Invalid URL format');
      }

      return decodedUrl;
    } catch (e) {
      debugPrint('URL processing error: $e');
      return null;
    }
  }

  String get htmlContent {
    final html = widget.params?.html;
    if (html?.isEmpty != false) {
      return '<html><body><p>No content available</p></body></html>';
    }

    try {
      return CoreCommonFunction().wrapStyleHtmlContent(html!);
    } catch (e) {
      debugPrint('HTML processing error: $e');
      return '<html><body><p>Error processing content</p></body></html>';
    }
  }
}

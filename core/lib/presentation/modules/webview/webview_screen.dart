import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core.dart';
import '../../../l10n/localization_ext.dart';

part 'webview.action.dart';

class WebViewArgs {
  final String? url;
  final String? html;
  final String? title;

  const WebViewArgs({this.url, this.html, this.title});

  factory WebViewArgs.fromUrlParams(Map<String, dynamic> queryParameters) =>
      WebViewArgs(
        url: asOrNull(queryParameters['url']),
        html: asOrNull(queryParameters['html']),
        title: asOrNull(queryParameters['title']),
      );

  dynamic get adaptiveArguments {
    if (kIsWeb) {
      return {
        'url': url != null ? Uri.encodeComponent(url!) : null,
        'html': html,
        'title': title,
      }..removeWhere((key, value) => value.isNullOrEmpty);
    }
    return this;
  }

  bool get hasUrl => url.isNotNullOrEmpty;
  bool get hasHtml => html.isNotNullOrEmpty;
  bool get hasValidContent => hasUrl || hasHtml;
}

enum WebViewLoadState { idle, loading, loaded, error }

class WebViewScreen extends StatefulWidget {
  static const String routeName = '/webview';

  const WebViewScreen({super.key, this.params});

  final WebViewArgs? params;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  WebViewLoadState _loadState = WebViewLoadState.idle;
  double _progress = 0.0;
  String? _errorMessage;

  WebViewArgs get _params => widget.params ?? const WebViewArgs();

  @override
  void initState() {
    super.initState();
    _validateContent();
  }

  void _validateContent() {
    if (!_params.hasValidContent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _loadState = WebViewLoadState.error;
          _errorMessage = context.coreL10n.noContentToDisplay;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenForm(title: _params.title, child: _buildWebViewStack());
  }

  Widget _buildWebViewStack() {
    return Stack(
      children: [
        Positioned.fill(child: _buildWebView()),
        if (_loadState == WebViewLoadState.loading)
          Positioned.fill(child: _buildProgressOverlay()),
        if (_loadState == WebViewLoadState.error)
          Positioned.fill(child: _buildErrorView()),
      ],
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialSettings: _createWebViewSettings(),
      initialUrlRequest: _createInitialUrlRequest(),
      initialData: _createInitialData(),
      onWebViewCreated: _handleWebViewCreated,
      onLoadStart: _handleLoadStart,
      onLoadStop: _handleLoadStop,
      onProgressChanged: _handleProgressChanged,
      shouldOverrideUrlLoading: _handleShouldOverrideUrlLoading,
      onReceivedError: _handleReceivedError,
      onReceivedHttpError: _handleHttpError,
    );
  }

  Widget _buildProgressOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Loading(),
        const SizedBox(height: 16),
        SizedBox(
          width: 140,
          child: LinearProgressIndicator(
            value: _progress,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.grey[300],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    final trans = context.coreL10n;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              trans.failedToLoadContent,
              style: textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: Text(trans.retry),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: Text(trans.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InAppWebViewSettings _createWebViewSettings() {
    return InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      javaScriptEnabled: true,
      supportZoom: true,
      builtInZoomControls: true,
      displayZoomControls: false,

      // Security settings
      allowFileAccess: false,
      allowContentAccess: false,

      // Performance settings
      cacheEnabled: true,
      clearCache: false,

      // Android-specific settings
      useHybridComposition: true,
      domStorageEnabled: true,

      // iOS-specific settings
      allowsInlineMediaPlayback: true,
      allowsBackForwardNavigationGestures: true,
    );
  }

  URLRequest? _createInitialUrlRequest() {
    final processedUrl = url;
    if (processedUrl == null) {
      return null;
    }

    try {
      final uri = Uri.parse(processedUrl);
      return URLRequest(url: WebUri.uri(uri));
    } catch (e) {
      debugPrint('Invalid URL: $processedUrl - Error: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setErrorState('Invalid URL format: $processedUrl');
      });
      return null;
    }
  }

  InAppWebViewInitialData? _createInitialData() {
    if (!_params.hasUrl && _params.hasHtml) {
      return InAppWebViewInitialData(
        data: htmlContent,
        mimeType: 'text/html',
        encoding: 'utf-8',
      );
    }
    return null;
  }

  void _handleWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    _setupJavaScriptHandlers(controller);
    _setState(WebViewLoadState.loading);
  }

  void _setupJavaScriptHandlers(InAppWebViewController controller) {
    controller
      // JavaScript bridge for toast messages
      ..addJavaScriptHandler(
        handlerName: 'Toaster',
        callback: (args) {
          if (args.isNotEmpty && mounted) {
            _showToast(args[0].toString());
          }
        },
      )
      // JavaScript bridge for navigation
      ..addJavaScriptHandler(
        handlerName: 'Navigation',
        callback: (args) {
          if (args.isNotEmpty && mounted) {
            final action = args[0].toString();
            switch (action) {
              case 'back':
                Navigator.of(context).pop();
                break;
              case 'close':
                Navigator.of(context).pop();
                break;
            }
          }
        },
      );
  }

  void _handleLoadStart(InAppWebViewController controller, WebUri? url) {
    _setState(WebViewLoadState.loading);
    setState(() {
      _progress = 0.0;
      _errorMessage = null;
    });
    debugPrint('WebView started loading: $url');
  }

  void _handleLoadStop(InAppWebViewController controller, WebUri? url) {
    _setState(WebViewLoadState.loaded);
    setState(() {
      _progress = 1.0;
    });
    debugPrint('WebView finished loading: $url');
  }

  void _handleProgressChanged(InAppWebViewController controller, int progress) {
    setState(() {
      _progress = progress / 100.0;
    });
  }

  Future<NavigationActionPolicy> _handleShouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url;

    if (url == null) {
      return NavigationActionPolicy.ALLOW;
    }

    // Handle external protocols
    if (_shouldOpenExternally(url)) {
      await _launchExternalUrl(url);
      return NavigationActionPolicy.CANCEL;
    }

    // Handle file downloads
    if (_isDownloadableFile(url)) {
      await _handleFileDownload(url);
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  void _handleReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    final errorMsg = 'Failed to load: ${error.description}';
    debugPrint('WebView error: $errorMsg (Type: ${error.type})');
    _setErrorState(error.description);
  }

  void _handleHttpError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  ) {
    final errorMsg =
        'HTTP Error ${errorResponse.statusCode}: ${errorResponse.reasonPhrase}';
    debugPrint('WebView HTTP error: $errorMsg');
    _setErrorState(errorMsg);
  }

  bool _shouldOpenExternally(WebUri url) {
    final scheme = url.scheme.toLowerCase();
    return !['http', 'https', 'file', 'data'].contains(scheme);
  }

  bool _isDownloadableFile(WebUri url) {
    final path = url.path.toLowerCase();
    const downloadableExtensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.xls',
      '.xlsx',
      '.zip',
    ];
    return downloadableExtensions.any(path.endsWith);
  }

  Future<void> _launchExternalUrl(WebUri url) async {
    try {
      final uri = Uri.parse(url.toString());
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Cannot launch URL: $url');
      }
    } catch (e) {
      debugPrint('Failed to launch external URL: $e');
      if (mounted) {
        _showToast(context.coreL10n.failedToOpenExternalLink);
      }
    }
  }

  Future<void> _handleFileDownload(WebUri url) async {
    try {
      final uri = Uri.parse(url.toString());
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        _showToast(context.coreL10n.downloadStarted);
      }
    } catch (e) {
      debugPrint('Failed to handle file download: $e');
      if (mounted) {
        _showToast(context.coreL10n.downloadFailed);
      }
    }
  }

  void _showToast(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setState(WebViewLoadState state) {
    if (mounted) {
      setState(() {
        _loadState = state;
      });
    }
  }

  void _setErrorState(String errorMessage) {
    if (mounted) {
      setState(() {
        _loadState = WebViewLoadState.error;
        _errorMessage = errorMessage;
      });
    }
  }

  void _retry() {
    _setState(WebViewLoadState.idle);
    setState(() {
      _errorMessage = null;
      _progress = 0.0;
    });

    final controller = _webViewController;
    if (controller == null) {
      return;
    }

    try {
      if (_params.hasUrl) {
        final processedUrl = url;
        if (processedUrl != null) {
          controller.loadUrl(
            urlRequest: URLRequest(url: WebUri.uri(Uri.parse(processedUrl))),
          );
        }
      } else if (_params.hasHtml) {
        controller.loadData(data: htmlContent);
      }
    } catch (e) {
      debugPrint('Failed to retry loading: $e');
      _setErrorState('Failed to retry: $e');
    }
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}

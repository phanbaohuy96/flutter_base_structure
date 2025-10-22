import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core.dart';
import '../../../l10n/localization_ext.dart';

part 'webview.action.dart';

class WebViewArgs {
  final String? url;
  final String? html;
  final String? title;
  final String? assetPath;

  WebViewArgs({
    this.url,
    this.html,
    this.title,
    this.assetPath,
  });

  factory WebViewArgs.fromUrlParams(
    Map<String, dynamic> queryParameters,
  ) =>
      WebViewArgs(
        url: asOrNull(queryParameters['url']),
        html: asOrNull(queryParameters['html']),
        title: asOrNull(queryParameters['title']),
        assetPath: asOrNull(queryParameters['assetPath']),
      );

  dynamic get adaptiveArguments {
    if (kIsWeb) {
      return {
        'url': url != null ? Uri.encodeComponent(url!) : null,
        'html': html,
        'title': title,
        'assetPath': assetPath,
      }..removeWhere((key, value) => value.isNullOrEmpty);
    }
    return this;
  }
}

class WebViewScreen extends StatefulWidget {
  static String routeName = '/webview';

  const WebViewScreen({
    Key? key,
    this.params,
  }) : super(key: key);

  final WebViewArgs? params;

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with AfterLayoutMixin {
  double progress = -1;

  @override
  void afterFirstLayout(BuildContext context) {
    context.themeColor.setLightStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenForm(
      title: widget.params?.title,
      actions: [
        if (url != null) _rightButton(),
      ],
      child: Stack(
        children: [
          Positioned.fill(
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                supportZoom: false,
                // Android-specific settings
                useHybridComposition: true,
                // iOS-specific settings
                allowsInlineMediaPlayback: true,
              ),
              initialUrlRequest: url.isNotNullOrEmpty
                  ? URLRequest(url: WebUri.uri(Uri.parse(url!)))
                  : null,
              initialData: url.isNullOrEmpty && htmlContent.isNotEmpty
                  ? InAppWebViewInitialData(data: htmlContent)
                  : null,
              onWebViewCreated: (controller) {
                controller.addJavaScriptHandler(
                  handlerName: 'Toaster',
                  callback: (args) {
                    if (args.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(args[0])),
                      );
                    }
                  },
                );
              },
              onLoadStart: (controller, url) {
                debugPrint('Page started loading: $url');
              },
              onLoadStop: (controller, url) {
                debugPrint('Page finished loading: $url');
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
                debugPrint('WebView is loading (progress : $progress%)');
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url;

                if (url != null &&
                    url.hasAbsolutePath &&
                    !url.scheme.startsWith('http')) {
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) {
                debugPrint('''Page resource error:
            description: ${error.description}
            type: ${error.type}''');
              },
            ),
          ),
          Center(
            child: Visibility(
              visible: progress < 1.0 && progress != -1,
              child: const Loading(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightButton() => PopupMenuButton<Map<String, dynamic>>(
        icon: Icon(
          Icons.more_vert_outlined,
          color: context.themeColor.appbarForegroundColor,
        ),
        color: context.theme.primaryColor,
        onSelected: (item) => item['onTap'].call(),
        itemBuilder: (_) => [
          ..._dropdownItems.map(
            (e) => PopupMenuItem<Map<String, dynamic>>(
              value: e,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  e['icon'],
                  const SizedBox(width: 8),
                  Text(
                    e['title'],
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  List<Map<String, dynamic>> get _dropdownItems {
    final l10n = context.coreL10n;
    return [
      {
        'title': l10n.openInExternalBrowser,
        'icon': const Icon(
          Icons.language_outlined,
          size: 16,
        ),
        'onTap': () {
          CoreCommonFunction().tryLunchUri(url!);
        },
      },
      {
        'title': l10n.copyLink,
        'icon': const Icon(
          Icons.content_copy_outlined,
          size: 16,
        ),
        'onTap': () async {
          await url?.let((it) async {
            await Clipboard.setData(ClipboardData(text: it));
            showToast(context, l10n.copied);
          });
        },
      },
    ];
  }
}

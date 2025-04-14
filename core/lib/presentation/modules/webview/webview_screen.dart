// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../core.dart';
import '../../../l10n/localization_ext.dart';

part 'webview.action.dart';

class WebViewArgs {
  final String? url;
  final String? html;
  final String? title;

  WebViewArgs({
    this.url,
    this.html,
    this.title,
  });

  WebViewArgs copyWith({
    String? url,
    String? html,
    String? title,
    String? openInExternalBrowser,
    String? copyLink,
    String? copied,
  }) {
    return WebViewArgs(
      url: url ?? this.url,
      html: html ?? this.html,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'html': html,
      'title': title,
    };
  }

  factory WebViewArgs.fromMap(Map<String, dynamic> map) {
    return WebViewArgs(
      url: map['url'] != null ? map['url'] as String : null,
      html: map['html'] != null ? map['html'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory WebViewArgs.fromJson(String source) =>
      WebViewArgs.fromMap(json.decode(source) as Map<String, dynamic>);
}

class WebViewScreen extends StatefulWidget {
  static String routeName = '/webview';

  const WebViewScreen({
    Key? key,
    this.params,
    this.hasBorder = true,
  }) : super(key: key);

  final WebViewArgs? params;
  final bool? hasBorder;

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with AfterLayoutMixin {
  // final bool _pageCreated = false;
  // final bool _pageLoading = true;
  late final WebViewController _controller;

  @override
  void afterFirstLayout(BuildContext context) {
    context.themeColor.setLightStatusBar();
  }

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''Page resource error:
code: ${error.errorCode}
description: ${error.description}
errorType: ${error.errorType}
isForMainFrame: ${error.isForMainFrame}''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.uri.hasAbsolutePath) {
              if (!request.url.startsWith('http')) {
                launchUrl(
                  Uri.parse(request.url),
                  mode: LaunchMode.externalApplication,
                );

                return NavigationDecision.prevent;
              } else {
                return NavigationDecision.navigate;
              }
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );
    if (url.isNotNullOrEmpty) {
      controller.loadRequest(Uri.parse(url!));
    } else {
      controller.loadHtmlString(htmlContent);
    }
    // ..loadRequest(Uri.parse());

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenForm(
      title: widget.params?.title,
      hasBottomBorderRadius: widget.hasBorder,
      actions: [
        if (url != null) _rightButton(),
      ],
      child: WebViewWidget(
        controller: _controller,
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

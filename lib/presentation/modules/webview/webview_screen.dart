import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/utils.dart';
import '../../base/base.dart';
import '../../common_widget/export.dart';
import '../../extentions/extention.dart';
import '../../theme/theme_color.dart';

class WebviewArgs {
  final String? url;
  final String? html;
  final String? title;

  WebviewArgs({this.url, this.html, this.title});
}

class WebviewScreen extends StatefulWidget {
  final WebviewArgs? args;

  const WebviewScreen({
    Key? key,
    this.args,
  }) : super(key: key);

  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends StateBase<WebviewScreen> {
  bool _pageCreated = false;
  bool _pageLoading = true;
  WebViewController? _controller;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant WebviewScreen oldWidget) {
    if (oldWidget.args?.url != widget.args?.url ||
        oldWidget.args?.html != widget.args?.html) {
      loadData();
    }
    super.didUpdateWidget(oldWidget);
  }

  late AppLocalizations trans;

  @override
  Widget build(BuildContext context) {
    trans = translate(context);
    return ScreenForm(
      title: widget.args?.title,
      actions: [
        if (url != null) _rightButton(),
      ],
      child: Container(
        color: AppColor.white,
        child: Stack(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _pageCreated ? 1 : 0,
              child: WebView(
                initialUrl: url,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (controller) {
                  _controller = controller;
                  loadData();
                },
                onPageStarted: (_) {
                  if (Platform.isAndroid) {
                    setState(() {
                      _pageCreated = true;
                      _pageLoading = true;
                    });
                  }
                },
                onPageFinished: (_) {
                  setState(() {
                    _pageCreated = true;
                    _pageLoading = false;
                  });
                },
              ),
            ),
            Builder(
              builder: (ctx) {
                if (!_pageLoading) {
                  return const SizedBox();
                }
                return const Center(
                  child: Loading(
                    brightness: Brightness.light,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String? get url {
    if (widget.args?.url?.isNotEmpty != true) {
      return null;
    }
    if (widget.args?.url?.startsWith('http://') == false &&
        widget.args?.url?.startsWith('https://') == false) {
      return 'http://$url';
    } else {
      return widget.args?.url;
    }
  }

  void loadData() {
    if (url == null) {
      _controller?.loadUrl(
        Uri.dataFromString(
          CommonFunction.wrapStyleHtmlContent(widget.args?.html ?? ''),
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString(),
      );
      return;
    }
  }

  Widget _rightButton() => PopupMenuButton<MenuItemView>(
        icon: const Icon(
          Icons.more_vert_outlined,
          color: AppColor.white,
        ),
        onSelected: (item) => item.onTap?.call(),
        itemBuilder: (_) => _dropdownItems
            .map(
              (e) => PopupMenuItem<MenuItemView>(
                value: e,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    e.icon,
                    const SizedBox(width: 8),
                    Text(e.title),
                  ],
                ),
              ),
            )
            .toList(),
      );

  List<MenuItemView> get _dropdownItems {
    return [
      MenuItemView(
        title: trans.openInExternalBrowser,
        icon: const Icon(Icons.language_outlined),
        onTap: () {
          launchUrl(Uri.parse(url!));
        },
      ),
      MenuItemView(
        title: trans.copyLink,
        icon: const Icon(
          Icons.content_copy_outlined,
        ),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: url));
          showToast(trans.copied);
        },
      )
    ];
  }

  @override
  AppBlocBase? get bloc => null;
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../generated/assets.dart';
import '../../extentions/extention.dart';

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({
    super.key,
    required this.onBackToWelcomePage,
  });

  final VoidCallback onBackToWelcomePage;

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    final trans = translate(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: EmptyData(
              message: trans.pageNotFound,
              icon: Assets.images.png.emptySearchState,
              iconWidth: 220,
              iconHeight: 220,
            ),
          ),
          myNavigatorObserver.history.length <= 2
              ? ThemeButton.text(
                  title: trans.backToHomepage,
                  onPressed: _backToWelcomePage,
                )
              : ThemeButton.text(title: trans.back, onPressed: _back),
        ],
      ),
    );
  }

  void _backToWelcomePage() {
    widget.onBackToWelcomePage();
  }

  void _back() {
    Navigator.pop(context);
  }
}

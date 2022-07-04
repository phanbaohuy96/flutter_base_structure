import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'loading.dart';

export 'package:pull_to_refresh/pull_to_refresh.dart';

class SmartRefresherWrapper {
  SmartRefresherWrapper._();

  static SmartRefresher build({
    required RefreshController controller,
    bool enablePullDown = true,
    bool enablePullUp = false,
    VoidCallback? onRefresh,
    VoidCallback? onLoading,
    required Widget child,
  }) {
    return SmartRefresher(
      physics: const BouncingScrollPhysics(),
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      controller: controller,
      onRefresh: onRefresh,
      onLoading: onLoading,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          return const Align(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Loading(
                brightness: Brightness.light,
                radius: 10,
              ),
            ),
          );
        },
      ),
      child: child,
    );
  }
}

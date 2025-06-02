import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart' as lib;

import 'loading.dart';

export 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    hide RefreshController;

class SmartRefresherWrapper extends StatelessWidget {
  const SmartRefresherWrapper({
    super.key,
    required this.controller,
    this.onRefresh,
    this.onLoading,
    this.child,
    this.scrollController,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.physics = const BouncingScrollPhysics(),
  });

  final RefreshController controller;
  final bool enablePullDown;
  final bool enablePullUp;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final Widget? child;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return lib.SmartRefresher(
      physics: physics,
      header: lib.MaterialClassicHeader(
        backgroundColor: Theme.of(context).primaryColor,
        color: Theme.of(context).colorScheme.primary,
      ),
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      controller: controller.externalCtrl,
      onRefresh: onRefresh,
      onLoading: onLoading,
      scrollController: scrollController,
      footer: lib.CustomFooter(
        loadStyle: lib.LoadStyle.ShowWhenLoading,
        builder: (BuildContext context, lib.LoadStatus? mode) {
          if (mode == lib.LoadStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Loading(
                radius: 10,
              ),
            );
          }
          return const SizedBox();
        },
      ),
      child: child,
    );
  }
}

abstract class IRefreshController {
  Future<void> requestRefresh();
  void refreshCompleted();

  Future<void> requestLoading();
  void loadComplete();

  void dispose();
}

class RefreshController extends IRefreshController {
  final lib.RefreshController _controller;

  RefreshController({bool initialRefresh = false})
      : _controller = lib.RefreshController(initialRefresh: initialRefresh);

  lib.RefreshController get externalCtrl => _controller;

  @override
  Future<void> requestRefresh() async {
    return _controller.requestRefresh();
  }

  @override
  void refreshCompleted() {
    _controller.refreshCompleted();
  }

  @override
  Future<void> requestLoading() async {
    return _controller.requestLoading();
  }

  @override
  void loadComplete() {
    _controller.loadComplete();
  }

  @override
  void dispose() {
    return _controller.dispose();
  }
}

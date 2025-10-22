import 'package:flutter/foundation.dart';
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
    this.footerTriggeredExtent = 100.0,
  });

  final RefreshController controller;
  final bool enablePullDown;
  final bool enablePullUp;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final Widget? child;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final double footerTriggeredExtent;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollEndNotification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - footerTriggeredExtent) {
              _handleLoading();
            }
          }
          return false;
        },
        child: _buildRefresher(context),
      );
    }

    return _buildRefresher(context);
  }

  Widget _buildRefresher(BuildContext context) {
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

  void _handleLoading() {
    if (!controller.isLoadmore && enablePullUp && onLoading != null) {
      controller.requestLoading();
    }
  }
}

/// An interface defining the contract for a refresh controller.
///
/// This interface provides methods and properties to manage refresh and
/// load more functionalities in scrollable content.
///
/// Implementations of this interface should handle:
/// - Requesting refresh and load more operations
/// - Completing these operations
/// - Tracking the status of refresh and load more operations
/// - Proper resource cleanup
///
/// Example usage:
/// ```dart
/// class MyRefreshController implements IRefreshController {
///   // Implementation of the interface methods
/// }
/// ```
abstract class IRefreshController {
  /// Initiates a refresh operation.
  ///
  /// Returns a [Future] that completes when the refresh request is processed.
  Future<void> requestRefresh();

  /// Marks the current refresh operation as completed.
  ///
  /// Call this method when your data loading finishes successfully during
  /// a pull-to-refresh.
  void refreshCompleted();

  /// Indicates whether a refresh operation is currently in progress.
  bool get isRefreshing;

  /// Initiates a load more operation.
  ///
  /// Returns a [Future] that completes when the load more request is processed.
  Future<void> requestLoading();

  /// Marks the current load more operation as completed.
  ///
  /// Call this method when your data loading finishes successfully during
  /// a load more operation.
  void loadComplete();

  /// Indicates whether a load more operation is currently in progress.
  bool get isLoadmore;

  /// Releases resources used by the controller.
  ///
  /// Call this method when the controller is no longer needed to prevent memory
  /// leaks.
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
  bool get isRefreshing => externalCtrl.isRefresh;

  @override
  Future<void> requestLoading() async {
    return _controller.requestLoading();
  }

  @override
  void loadComplete() {
    _controller.loadComplete();
  }

  @override
  bool get isLoadmore => externalCtrl.isLoading;

  @override
  void dispose() {
    return _controller.dispose();
  }
}

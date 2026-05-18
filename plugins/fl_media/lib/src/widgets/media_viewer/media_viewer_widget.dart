import 'dart:io'
    if (dart.library.html) 'package:extended_image_library/src/_platform_web.dart'
    if (dart.library.js_interop) 'package:extended_image_library/src/_platform_web.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../fl_media.dart';
import 'retry_button.dart';

/// Opens a media viewer gallery with support for multiple images and videos
///
/// Supports:
/// - Multiple media files (images and videos)
/// - Local files and network URLs
/// - Swipe vertically to close
/// - Swipe horizontally to switch between media
/// - Hero animation support
/// - Fade transition
/// - Keeps video state when swiping between media
/// - Optional video controller sharing via [videoControllerManager]
///
/// Example:
/// ```dart
/// openMediaViewer(
///   context: context,
///   mediaItems: [
///     MediaViewerItem.network('https://example.com/image.jpg'),
///     MediaViewerItem.video('https://example.com/video.mp4'),
///   ],
///   focusIndex: 0,
///   heroTag: 'post-media-123',
///   videoControllerManager: mySharedManager, // Optional
/// );
/// ```
Future<T?> openMediaViewer<T>({
  required BuildContext context,
  required List<MediaViewerItem> mediaItems,
  int focusIndex = 0,
  String? heroTag,
  bool rootNavigator = false,
  List<Widget>? actions,
  MediaViewerStyle? style,
  VideoControllerManager? videoControllerManager,
  OnVideoVisibilityChanged? onVideoVisibilityChanged,
  MediaErrorWidgetBuilder? errorWidgetBuilder,
}) {
  return Navigator.of(context, rootNavigator: rootNavigator).push<T>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      pageBuilder: (c, a1, a2) => Material(
        color: Colors.transparent,
        child: MediaViewerWidget(
          mediaItems: mediaItems,
          focusIndex: focusIndex,
          heroTag: heroTag,
          actions: actions,
          style: style,
          videoControllerManager: videoControllerManager,
          onVideoVisibilityChanged: onVideoVisibilityChanged,
          errorWidgetBuilder: errorWidgetBuilder,
        ),
      ),
      transitionsBuilder: (c, anim, a2, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );
}

typedef MediaErrorWidgetBuilder =
    Widget Function(
      BuildContext context,
      MediaViewerItem item,
    );

class MediaViewerStyle {
  final Color backgroundColor;
  final Color onSurfaceColor;
  final TextStyle? titleTextStyle;
  final TextStyle? counterTextStyle;

  const MediaViewerStyle({
    this.backgroundColor = Colors.black,
    this.onSurfaceColor = Colors.white,
    this.titleTextStyle,
    this.counterTextStyle,
  });
}

class MediaViewerWidget extends StatefulWidget {
  const MediaViewerWidget({
    super.key,
    required this.mediaItems,
    this.focusIndex = 0,
    this.heroTag,
    this.actions,
    this.style,
    this.videoControllerManager,
    this.onVideoVisibilityChanged,
    this.errorWidgetBuilder,
  });

  final List<MediaViewerItem> mediaItems;
  final int focusIndex;
  final String? heroTag;
  final MediaViewerStyle? style;
  final List<Widget>? actions;
  final VideoControllerManager? videoControllerManager;
  final OnVideoVisibilityChanged? onVideoVisibilityChanged;
  final MediaErrorWidgetBuilder? errorWidgetBuilder;

  @override
  State<MediaViewerWidget> createState() => _MediaViewerWidgetState();
}

class _MediaViewerWidgetState extends State<MediaViewerWidget> {
  late final PageController _pageController;
  late final MediaViewerController _mediaController;
  int _previousPageIndex = 0;
  final Map<int, int> _imageRetryKeys = {};

  /// Saved video volume/playing state per index (captured before viewer modifies them).
  final Map<int, double?> _savedVolumes = {};
  final Map<int, bool?> _savedPlayingStates = {};

  /// Video IDs that existed in the shared manager before this viewer opened.
  /// Used to dispose only controllers created during the fullscreen session.
  Set<String>? _preExistingVideoIds;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.focusIndex);
    _preExistingVideoIds = widget.videoControllerManager?.activeVideoIds;
    _mediaController = MediaViewerController(
      mediaItems: widget.mediaItems,
      videoControllerManager: widget.videoControllerManager,
    );
    _previousPageIndex = widget.focusIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();

    // Restore video states before disposing controllers
    _restoreAllVideoStates();
    _mediaController.dispose();

    // Dispose video controllers that were created during the fullscreen session
    // but did not exist before (e.g. user swiped to other videos in gallery).
    final keepIds = _preExistingVideoIds;
    if (keepIds != null) {
      widget.videoControllerManager?.disposeControllersNotIn(keepIds);
    }

    super.dispose();
  }

  /// Save the current volume and playing state of a video controller.
  /// Only saves on the first call per index to capture the original state.
  void _saveVideoState(int index, VideoControllerWrapper controller) {
    if (_savedVolumes.containsKey(index)) {
      return;
    }

    final videoController = controller.controller;
    if (videoController != null) {
      try {
        if (videoController.value.isInitialized) {
          _savedVolumes[index] = videoController.value.volume;
          _savedPlayingStates[index] = videoController.value.isPlaying;
        } else {
          // Mark as visited but with null state
          _savedVolumes[index] = null;
          _savedPlayingStates[index] = null;
        }
      } catch (e) {
        // Controller might be disposed
        _savedVolumes[index] = null;
        _savedPlayingStates[index] = null;
      }
    } else {
      _savedVolumes[index] = null;
      _savedPlayingStates[index] = null;
    }
  }

  /// Restore saved volume and playing state for all video controllers.
  void _restoreAllVideoStates() {
    for (final index in _savedVolumes.keys) {
      final wrapper = _mediaController.getVideoController(index);
      if (wrapper == null) {
        continue;
      }

      final controller = wrapper.controller;
      if (controller == null) {
        continue;
      }

      try {
        if (!controller.value.isInitialized) {
          continue;
        }

        final savedVolume = _savedVolumes[index];
        final wasPlaying = _savedPlayingStates[index];

        // If previous state is null, mark controller for full cleanup
        if (savedVolume == null && wasPlaying == null) {
          wrapper.markToCleanEverything();
          continue;
        }

        // Restore volume (mute state)
        if (savedVolume != null) {
          controller.setVolume(savedVolume);
        }

        // Restore playback state
        if (wasPlaying == true) {
          controller.play();
        } else {
          controller.pause();
        }
      } catch (e) {
        // Controller might be disposed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = widget.mediaItems.length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(pageCount),
      body: ExtendedImageSlidePage(
        slideAxis: SlideAxis.both,
        slideType: SlideType.wholePage,
        resetPageDuration: const Duration(milliseconds: 167),
        slidePageBackgroundHandler: (offset, pageSize) {
          return defaultSlidePageBackgroundHandler(
            offset: offset,
            pageSize: pageSize,
            color: Colors.black,
            pageGestureAxis: SlideAxis.both,
          );
        },
        child: PageView.builder(
          itemCount: pageCount,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            return _buildMediaItem(index);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int pageCount) {
    final textTheme = Theme.of(context).textTheme;
    final appBarTheme = Theme.of(context).appBarTheme;
    final style = widget.style;
    final titleTextStyle =
        (style?.titleTextStyle ??
                appBarTheme.titleTextStyle ??
                textTheme.titleSmall)
            ?.copyWith(
              color: style?.onSurfaceColor ?? Colors.white,
            );
    final subtitleTextStyle = (style?.counterTextStyle ?? textTheme.bodyMedium)
        ?.copyWith(
          color: style?.onSurfaceColor ?? Colors.white,
        );
    return AppBar(
      backgroundColor: style?.backgroundColor ?? Colors.black12,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded, color: Colors.white),
      ),
      titleSpacing: 8,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.flMediaL10n.media,
            style: titleTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
          ListenableBuilder(
            listenable: _pageController,
            builder: (context, child) {
              final currentPage =
                  (_pageController.hasClients
                      ? _pageController.page?.round() ?? 0
                      : widget.focusIndex) +
                  1;
              return Text(
                '$currentPage/$pageCount',
                style: subtitleTextStyle,
              );
            },
          ),
        ],
      ),
      actions: widget.actions,
    );
  }

  void _onPageChanged(int index) {
    // Pause video if switching from video to non-video
    final previousItem = widget.mediaItems[_previousPageIndex];
    final currentItem = widget.mediaItems[index];

    if (previousItem.isVideo) {
      final videoController = _mediaController.getVideoController(
        _previousPageIndex,
      );

      videoController?.pause();
    }
    if (currentItem.isVideo) {
      final videoController = _mediaController.getVideoController(index);

      videoController?.play();
    }

    _previousPageIndex = index;
  }

  void _retryImage(int index) {
    setState(() {
      _imageRetryKeys[index] = (_imageRetryKeys[index] ?? 0) + 1;
    });
  }

  void _retryVideo(int index) {
    _mediaController.clearVideoController(index);
    setState(() {});
  }

  Widget _buildMediaItem(int index) {
    final item = widget.mediaItems[index];
    final isHeroEnabled = widget.heroTag != null && index == widget.focusIndex;

    Widget mediaWidget;

    if (item.isVideo) {
      mediaWidget = _buildVideoViewer(item, index);
    } else {
      mediaWidget = _buildImageViewer(item, index);
    }

    if (isHeroEnabled) {
      return Hero(
        tag: '${widget.heroTag!}-$index',
        child: mediaWidget,
      );
    }

    return mediaWidget;
  }

  Widget _buildVideoViewer(MediaViewerItem item, int index) {
    final controller = _mediaController.getVideoController(index);

    // Save the original state before VideoViewerWidget modifies it
    if (controller != null) {
      _saveVideoState(index, controller);
    }

    return ExtendedImageSlidePageHandler(
      child: VideoViewerWidget(
        item: item,
        controller: controller,
        onRetry: () => _retryVideo(index),
        errorWidgetBuilder: widget.errorWidgetBuilder,
        onVisibilityChanged: widget.onVideoVisibilityChanged,
      ),
    );
  }

  Widget _buildImageViewer(MediaViewerItem item, int index) {
    // Priority: bytes (web) > url (CloudFile) > file (native)
    if (item.bytes != null) {
      return _buildMemoryImage(item.bytes!, index);
    } else if (item.url != null) {
      if (item.isAsset) {
        return _buildAssetImage(item.url!, index);
      }
      return _buildNetworkImage(item.url!, index);
    } else if (item.file != null) {
      return _buildLocalImage(item.file!, index);
    }

    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 48,
      ),
    );
  }

  Widget _buildMemoryImage(Uint8List bytes, int index) {
    final retryCount = _imageRetryKeys[index] ?? 0;
    return ExtendedImage.memory(
      bytes,
      key: ValueKey('memory-image-$index-$retryCount'),
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      fit: BoxFit.contain,
      cacheRawData: false,
      extendedImageGestureKey: GlobalKey<ExtendedImageGestureState>(),
      loadStateChanged: (state) => _loadStateChanged(state, index),
      initGestureConfigHandler: _initGestureConfigHandler,
    );
  }

  Widget _buildNetworkImage(String url, int index) {
    final retryCount = _imageRetryKeys[index] ?? 0;
    return ExtendedImage.network(
      url,
      key: ValueKey('network-image-$index-$retryCount'),
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      fit: BoxFit.contain,
      cacheWidth: kIsWeb ? null : 1080,
      extendedImageGestureKey: GlobalKey<ExtendedImageGestureState>(),
      loadStateChanged: (state) => _loadStateChanged(state, index),
      initGestureConfigHandler: _initGestureConfigHandler,
    );
  }

  Widget _buildLocalImage(File file, int index) {
    final retryCount = _imageRetryKeys[index] ?? 0;
    return ExtendedImage.file(
      file,
      key: ValueKey('file-image-$index-$retryCount'),
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      fit: BoxFit.contain,
      cacheWidth: kIsWeb ? null : 1080,
      extendedImageGestureKey: GlobalKey<ExtendedImageGestureState>(),
      loadStateChanged: (state) => _loadStateChanged(state, index),
      initGestureConfigHandler: _initGestureConfigHandler,
    );
  }

  Widget _buildAssetImage(String assetPath, int index) {
    final retryCount = _imageRetryKeys[index] ?? 0;
    return ExtendedImage.asset(
      assetPath,
      key: ValueKey('asset-image-$index-$retryCount'),
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      fit: BoxFit.contain,
      cacheWidth: kIsWeb ? null : 1080,
      extendedImageGestureKey: GlobalKey<ExtendedImageGestureState>(),
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (state.extendedImageLoadState == LoadState.failed) {
          // Fallback to ImageView widget for asset images
          // ExtendedImage may not support all asset image formats
          return ImageView(source: assetPath);
        }
        return null;
      },
      initGestureConfigHandler: _initGestureConfigHandler,
    );
  }

  Widget? _loadStateChanged(ExtendedImageState state, int index) {
    if (state.extendedImageLoadState == LoadState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (state.extendedImageLoadState == LoadState.failed) {
      return _buildRetryWidget(
        onRetry: () => _retryImage(index),
      );
    }
    return null;
  }

  GestureConfig _initGestureConfigHandler(ExtendedImageState state) {
    return GestureConfig(
      /// Scale settings
      minScale: 1,
      animationMinScale: 0.9,
      maxScale: 3.0,
      animationMaxScale: 3.5,

      /// Speed of animation
      speed: 1.0,
      inertialSpeed: 100.0,
      initialScale: 1.0,
      inPageView: false,
      initialAlignment: InitialAlignment.center,
      reverseMousePointerScrollDirection: true,
    );
  }

  Widget _buildRetryWidget({
    required VoidCallback onRetry,
  }) {
    if (widget.errorWidgetBuilder != null) {
      return Center(
        child: GestureDetector(
          onTap: onRetry,
          child: widget.errorWidgetBuilder!(
            context,
            widget.mediaItems[_previousPageIndex],
          ),
        ),
      );
    }
    return Center(
      child: MediaRetryButton(
        onRetry: onRetry,
      ),
    );
  }
}

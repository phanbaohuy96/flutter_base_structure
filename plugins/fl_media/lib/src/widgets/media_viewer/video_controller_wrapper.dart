import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../../universal/universal.dart';
import '../../video/video_controller_manager.dart';
import '../../video/video_source.dart';
import 'media_viewer_item.dart';

/// Wrapper for VideoPlayerController that manages initialization and state
///
/// If [videoControllerManager] is provided, it will try to reuse existing
/// controllers. Otherwise, creates and manages its own controller.
class VideoControllerWrapper {
  VideoControllerWrapper({
    required this.item,
    this.videoControllerManager,
  }) {
    _initialize();
  }

  final MediaViewerItem item;
  final VideoControllerManager? videoControllerManager;
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  Uint8List? _thumbnail;
  bool _isUsingSharedController = false;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get hasError => _hasError;
  Uint8List? get thumbnail => _thumbnail;

  final _stateController = StreamController<void>.broadcast();
  Stream<void> get stateStream => _stateController.stream;

  // Unique identifier for the video (e.g., URL or file path)
  //
  // if it not null, it indicates that this controller is managed by
  // VideoControllerManager
  String? videoId;
  VideoSource? source;

  Future<void> _initialize() async {
    try {
      // Try to get controller from shared manager first
      if (videoControllerManager != null && item.url != null) {
        final url = item.url!;
        videoId = item.id ?? url;
        source = VideoSource.fromUrl(url);
        _controller = videoControllerManager!.getOrCreateController(
          videoId!,
          source!,
        );

        if (_controller != null) {
          _isUsingSharedController = true;
          _isInitialized = _controller!.value.isInitialized;

          // Add listener for video state changes
          _controller!.addListener(_onVideoStateChanged);

          if (!_isInitialized) {
            // Wait for initialization if not ready with delay to prevent double
            // init
            try {
              await Future.delayed(const Duration(milliseconds: 50));

              if (!_controller!.value.isInitialized) {
                await _controller!.initialize();
              }
              _isInitialized = _controller!.value.isInitialized;
            } catch (e) {
              // Ignore "Future already completed" errors
              if (!e.toString().contains('Future already completed')) {
                _hasError = true;
              } else {
                _isInitialized = _controller!.value.isInitialized;
              }
            }
          }

          _notifyListeners();
          return;
        }
      }

      // Fallback: create own controller
      // On web, only URL-based videos are supported
      // For native platforms, files should be converted to file:// URLs
      if (item.url == null && item.file == null) {
        _hasError = true;
        _notifyListeners();
        return;
      }

      // Create controller using network URL
      if (item.file != null && !kIsWeb) {
        // On native, convert local file to file:// URL
        _controller = createWithFile(
          item.file!,
        );
      } else if (item.url != null) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(item.url!));
      }

      if (_controller == null) {
        _hasError = true;
        _notifyListeners();
        return;
      }

      // Add listener for video state changes
      _controller!.addListener(_onVideoStateChanged);

      await _controller!.initialize();
      _isInitialized = true;

      // Generate thumbnail from first frame
      unawaited(_generateThumbnail());

      _notifyListeners();
    } catch (e) {
      _hasError = true;
      _notifyListeners();
    }
  }

  void _onVideoStateChanged() {
    _notifyListeners();
  }

  Future<void> _generateThumbnail() async {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        // Seek to first frame to ensure we have a thumbnail
        await _controller!.seekTo(Duration.zero);
        _notifyListeners();
      }
    } catch (e) {
      // Ignore thumbnail generation errors
    }
  }

  void _notifyListeners() {
    if (!_stateController.isClosed) {
      _stateController.add(null);
    }
  }

  void play() {
    _controller?.play();
  }

  void pause() {
    _controller?.pause();
  }

  void dispose() {
    _controller?.removeListener(_onVideoStateChanged);

    // Only dispose if we created this controller
    // Shared controllers are managed by VideoControllerManager
    if (!_isUsingSharedController) {
      _controller?.dispose();
    } else {
      if (videoId != null && _markToCleanEverything) {
        videoControllerManager?.disposeController(videoId!);
      }
    }

    _stateController.close();
  }

  /// Mark this controller to be cleaned from the shared manager when disposed
  bool _markToCleanEverything = false;
  void markToCleanEverything() {
    _markToCleanEverything = true;
  }
}

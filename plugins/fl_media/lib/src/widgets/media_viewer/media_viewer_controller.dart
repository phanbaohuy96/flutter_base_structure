import '../../video/video_controller_manager.dart';
import 'media_viewer_item.dart';
import 'video_controller_wrapper.dart';

/// Controller that manages video player states across the media viewer
///
/// Keeps video controllers alive when swiping between media items
/// for better UX and performance
///
/// If [videoControllerManager] is provided, it will reuse controllers from
/// external sources (e.g., community feed). Otherwise, creates own controllers.
class MediaViewerController {
  MediaViewerController({
    required this.mediaItems,
    this.videoControllerManager,
  });

  final List<MediaViewerItem> mediaItems;
  final VideoControllerManager? videoControllerManager;
  final Map<int, VideoControllerWrapper> _videoControllers = {};

  /// Get or create a video controller for the given index
  VideoControllerWrapper? getVideoController(int index) {
    if (index < 0 || index >= mediaItems.length) {
      return null;
    }

    final item = mediaItems[index];
    if (!item.isVideo) {
      return null;
    }

    // Return existing controller if available
    if (_videoControllers.containsKey(index)) {
      return _videoControllers[index];
    }

    // Create new controller wrapper with optional manager
    final wrapper = VideoControllerWrapper(
      item: item,
      videoControllerManager: videoControllerManager,
    );
    _videoControllers[index] = wrapper;
    return wrapper;
  }

  /// Dispose all video controllers
  void dispose() {
    for (final wrapper in _videoControllers.values) {
      wrapper.dispose();
    }
    _videoControllers.clear();
  }

  /// Pause all videos except the one at the given index
  void pauseAllExcept(int? currentIndex) {
    for (final entry in _videoControllers.entries) {
      if (entry.key != currentIndex) {
        entry.value.pause();
      }
    }
  }

  /// Clear and dispose a specific video controller (for retry scenarios)
  void clearVideoController(int index) {
    final wrapper = _videoControllers.remove(index);
    wrapper?.dispose();
  }
}

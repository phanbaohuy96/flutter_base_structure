import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../universal/universal.dart';
import 'video_source.dart';

/// Metadata for tracking video controller state
class VideoControllerMetadata {
  final VideoPlayerController controller;
  final String videoId;
  final VideoSource source;
  final DateTime createdAt;
  DateTime lastAccessedAt;
  bool isPreloaded;
  final void Function(VideoPlayerController)? onControllerReplaced;

  VideoControllerMetadata({
    required this.controller,
    required this.videoId,
    required this.source,
    required this.createdAt,
    required this.lastAccessedAt,
    this.isPreloaded = false,
    this.onControllerReplaced,
  });

  void markAccessed() {
    lastAccessedAt = DateTime.now();
  }
}

/// Service managing video player controllers with LRU caching
/// Prevents memory leaks by limiting active controllers and aggressive cleanup
class VideoControllerManager {
  static const int _maxActiveControllers = 1;
  static const int _maxPreloadedControllers = 15;
  static const int _maxTotalControllers =
      _maxActiveControllers + _maxPreloadedControllers;

  final Map<String, VideoControllerMetadata> _controllers = {};

  /// Get or create a video controller for the given video ID
  ///
  /// Returns null if controller creation fails.
  ///
  /// **IMPORTANT**: The returned controller may still be initializing
  /// asynchronously.
  ///
  /// Before calling `controller.initialize()`, always check:
  /// ```dart
  /// if (!controller.value.isInitialized && !controller.value.isInitializing) {
  ///   await controller.initialize();
  /// }
  /// ```
  /// Otherwise, you may get a "Future already completed" error if
  /// initialization is already in progress.
  ///
  /// The [onControllerReplaced] callback is invoked when a fallback controller
  /// is created to replace a failed controller, allowing the caller to update
  /// its reference.
  VideoPlayerController? getOrCreateController(
    String videoId,
    VideoSource source, {
    void Function(VideoPlayerController)? onControllerReplaced,
  }) {
    // Return existing controller if available
    if (_controllers.containsKey(videoId)) {
      final metadata = _controllers[videoId]!
        ..markAccessed()
        ..isPreloaded = false; // Mark as active now

      log(
        '[VideoController] Reusing controller for $videoId',
        level: 500,
        name: 'VideoControllerManager',
      );

      return metadata.controller;
    }

    // Prune cache if needed before creating new controller
    _pruneCache();

    // Create new controller
    try {
      final controller = _createController(source);
      if (controller == null) {
        log(
          '[VideoController] Failed to create controller for $videoId',
          level: 900,
          error: 'Invalid video source',
          name: 'VideoControllerManager',
        );
        return null;
      }

      final metadata = VideoControllerMetadata(
        controller: controller,
        videoId: videoId,
        source: source,
        createdAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
        onControllerReplaced: onControllerReplaced,
      );

      _controllers[videoId] = metadata;

      // Initialize controller asynchronously
      _initializeController(videoId, controller);

      log(
        '''[VideoController] Created controller for $videoId (${source.isHls
            ? 'HLS'
            : source.isLocal
            ? 'Local'
            : 'Network'})''',
        level: 500,
        name: 'VideoControllerManager',
      );

      return controller;
    } catch (e, stackTrace) {
      log(
        '[VideoController] Error creating controller for $videoId',
        level: 900,
        error: e,
        stackTrace: stackTrace,
        name: 'VideoControllerManager',
      );
      return null;
    }
  }

  /// Preload a video controller (buffer only, don't play)
  /// Used for upcoming videos in feed
  Future<void> preloadController(String videoId, VideoSource source) async {
    // Don't preload if already exists
    if (_controllers.containsKey(videoId)) {
      return;
    }

    // Check if we can preload more
    final preloadedCount = _controllers.values
        .where((m) => m.isPreloaded)
        .length;
    if (preloadedCount >= _maxPreloadedControllers) {
      log(
        '[VideoController] Preload limit reached, skipping $videoId',
        level: 500,
        name: 'VideoControllerManager',
      );
      return;
    }

    try {
      final controller = _createController(source);
      if (controller == null) {
        return;
      }

      final metadata = VideoControllerMetadata(
        controller: controller,
        videoId: videoId,
        source: source,
        createdAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
        isPreloaded: true,
      );

      _controllers[videoId] = metadata;

      // Initialize and pause immediately (preload buffer only)
      await controller.initialize();

      await controller.pause();

      log(
        '[VideoController] Preloaded controller for $videoId',
        level: 500,
        name: 'VideoControllerManager',
      );
    } catch (e, s) {
      log(
        '[VideoController] Preload failed for $videoId: $e',
        level: 700,
        error: e,
        stackTrace: s,
        name: 'VideoControllerManager',
      );
    }
  }

  /// Dispose a specific video controller
  Future<void> disposeController(String videoId, [bool force = false]) async {
    final metadata = _controllers[videoId];
    if (metadata == null) {
      return;
    }

    // Simple check: dispose if over limit
    final shouldDispose = _controllers.length > _maxTotalControllers;

    if (force || shouldDispose) {
      _controllers.remove(videoId);
      try {
        await metadata.controller.dispose();
        log(
          '[VideoController] Disposed controller for $videoId (over limit)',
          level: 500,
          name: 'VideoControllerManager',
        );
      } catch (e, s) {
        log(
          '[VideoController] Error disposing $videoId: $e',
          level: 700,
          error: e,
          stackTrace: s,
          name: 'VideoControllerManager',
        );
      }
    } else {
      // Mark as preloaded for potential reuse
      metadata.isPreloaded = true;
      log(
        '[VideoController] Kept controller for $videoId in cache (under limit)',
        level: 500,
        name: 'VideoControllerManager',
      );
    }
  }

  /// Dispose all controllers except the specified one
  Future<void> disposeAllExcept(String? activeVideoId) async {
    final toDispose = _controllers.keys
        .where((id) => id != activeVideoId)
        .toList();

    for (final videoId in toDispose) {
      await disposeController(videoId);
    }

    log(
      '''[VideoController] Disposed ${toDispose.length} controllers, kept: $activeVideoId''',
      level: 500,
      name: 'VideoControllerManager',
    );
  }

  /// Dispose all controllers
  Future<void> disposeAll() async {
    final count = _controllers.length;
    for (final metadata in _controllers.values) {
      try {
        await metadata.controller.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    }
    _controllers.clear();

    log(
      '[VideoController] Disposed all $count controllers',
      level: 500,
      name: 'VideoControllerManager',
    );
  }

  /// Get current playback position for a video
  Duration? getCurrentPosition(String videoId) {
    final metadata = _controllers[videoId];
    return metadata?.controller.value.position;
  }

  /// Get metadata for a video controller
  VideoControllerMetadata? getMetadata(String videoId) {
    return _controllers[videoId];
  }

  /// Pause all controllers except the specified active video
  /// Used to ensure only one video plays at a time
  Future<void> pauseAllExcept(String? activeVideoId) async {
    for (final entry in _controllers.entries) {
      final videoId = entry.key;
      final metadata = entry.value;

      // Skip the active video and preloaded videos (already paused)
      if (videoId == activeVideoId || metadata.isPreloaded) {
        continue;
      }

      try {
        if (metadata.controller.value.isPlaying) {
          await metadata.controller.pause();
          log(
            '''[VideoController] Paused controller for $videoId (active: $activeVideoId)''',
            level: 500,
            name: 'VideoControllerManager',
          );
        }
      } catch (e) {
        log(
          '[VideoController] Failed to pause $videoId',
          level: 700,
          error: e,
          name: 'VideoControllerManager',
        );
      }
    }
  }

  /// Set volume for all active controllers
  Future<void> setVolumeForAll(double volume) async {
    for (final metadata in _controllers.values) {
      try {
        await metadata.controller.setVolume(volume);
      } catch (e) {
        log(
          '[VideoController] Failed to set volume for ${metadata.videoId}',
          level: 900,
          error: e,
          name: 'VideoControllerManager',
        );
      }
    }
  }

  /// Get total controller count
  int get controllerCount => _controllers.length;

  /// Get the set of currently managed video IDs
  Set<String> get activeVideoIds => Set.unmodifiable(_controllers.keys.toSet());

  /// Dispose all controllers whose IDs are NOT in [keepIds]
  ///
  /// Useful for cleaning up controllers created during a temporary session
  /// (e.g. fullscreen gallery) while preserving pre-existing ones.
  Future<void> disposeControllersNotIn(Set<String> keepIds) async {
    final toDispose = _controllers.keys
        .where((id) => !keepIds.contains(id))
        .toList();

    for (final videoId in toDispose) {
      await disposeController(videoId, true);
    }

    if (toDispose.isNotEmpty) {
      log(
        '''[VideoController] Disposed ${toDispose.length} controllers not in keep set''',
        level: 500,
        name: 'VideoControllerManager',
      );
    }
  }

  /// Get active controller count (non-preloaded)
  int get activeControllerCount =>
      _controllers.values.where((m) => !m.isPreloaded).length;

  /// Create controller based on video source type
  VideoPlayerController? _createController(VideoSource source) {
    return switch (source) {
      LocalVideoSource() =>
        !kIsWeb && source.url != null
            ? VideoPlayerController.file(createFileFromPath(source.filePath))
            : null,
      NetworkVideoSource() => VideoPlayerController.networkUrl(
        Uri.parse(source.networkUrl),
      ),
    };
  }

  /// Initialize controller asynchronously with fallback support
  Future<void> _initializeController(
    String videoId,
    VideoPlayerController controller,
  ) async {
    try {
      await controller.initialize();
      log(
        '[VideoController] Initialized controller for $videoId',
        level: 500,
        name: 'VideoControllerManager',
      );
    } catch (e, stackTrace) {
      log(
        '[VideoController] Initialization failed for $videoId',
        level: 900,
        error: e,
        stackTrace: stackTrace,
        name: 'VideoControllerManager',
      );

      // Try fallback if available
      final metadata = _controllers[videoId];
      if (metadata?.source case final NetworkVideoSource source
          when source.fallback != null) {
        log(
          '[VideoController] Trying fallback URL for $videoId',
          level: 500,
          name: 'VideoControllerManager',
        );

        // Store callback before removing failed controller
        final callback = metadata?.onControllerReplaced;

        // Remove failed controller
        await disposeController(videoId, true);

        // Recreate with fallback
        final fallbackController = getOrCreateController(
          videoId,
          source.fallback!,
          onControllerReplaced: callback,
        );

        // Notify UI about controller replacement
        if (callback != null && fallbackController != null) {
          callback(fallbackController);
        }
        return;
      }

      // Remove failed controller if no fallback
      await disposeController(videoId);
    }
  }

  /// Prune cache using LRU strategy when limit exceeded
  void _pruneCache() {
    if (_controllers.length < _maxTotalControllers) {
      return;
    }

    // Sort by last accessed time (oldest first)
    final sortedEntries = _controllers.entries.toList()
      ..sort(
        (a, b) => a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt),
      );

    // Remove oldest controller
    final toRemove = sortedEntries.first;
    disposeController(toRemove.key);

    log(
      '[VideoController] Pruned cache, removed: ${toRemove.key}',
      level: 500,
      name: 'VideoControllerManager',
    );
  }

  Future<void> resumeController(String videoId) async {
    final metadata = _controllers[videoId];
    if (metadata != null) {
      try {
        if (!metadata.controller.value.isPlaying) {
          await metadata.controller.play();
          log(
            '[VideoController] Resumed controller for $videoId',
            level: 500,
            name: 'VideoControllerManager',
          );
        }
      } catch (e) {
        log(
          '[VideoController] Failed to resume $videoId',
          level: 700,
          error: e,
          name: 'VideoControllerManager',
        );
      }
    }
  }
}

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../video/video_source.dart';
import 'custom_video_controls.dart';
import 'media_viewer_item.dart';
import 'media_viewer_widget.dart';
import 'retry_button.dart';
import 'video_controller_wrapper.dart';

typedef OnVideoVisibilityChanged =
    void Function(
      BuildContext context,
      VisibilityInfo info,
      String videoId,
      VideoSource source,
    );

/// Video viewer widget with swipe-to-dismiss support
class VideoViewerWidget extends StatefulWidget {
  const VideoViewerWidget({
    super.key,
    required this.item,
    required this.controller,
    this.onVisibilityChanged,
    this.errorWidgetBuilder,
    this.onRetry,
  });

  final MediaViewerItem item;
  final VideoControllerWrapper? controller;
  final OnVideoVisibilityChanged? onVisibilityChanged;
  final MediaErrorWidgetBuilder? errorWidgetBuilder;
  final VoidCallback? onRetry;

  @override
  State<VideoViewerWidget> createState() => _VideoViewerWidgetState();
}

class _VideoViewerWidgetState extends State<VideoViewerWidget>
    with AutomaticKeepAliveClientMixin {
  ChewieController? _chewieController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeChewieController();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeChewieController() {
    final controller = widget.controller?.controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    // Listen to video completion to show thumbnail
    controller.addListener(_onVideoStateChanged);

    // Unmute the video if it was muted before
    if (controller.value.volume == 0) {
      controller.setVolume(1.0);
    }

    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      customControls: const CustomVideoControls(),
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.white,
        handleColor: Colors.white,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white70,
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _onVideoStateChanged() async {
    final controller = widget.controller?.controller;
    if (controller != null) {
      // Show thumbnail when video completes
      if (controller.value.position >= controller.value.duration) {
        // Seek to the beginning of the video to show the thumbnail
        await controller.seekTo(Duration.zero);
        await controller.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.onVisibilityChanged == null) {
      return _buildVideoPlayer();
    }
    return VisibilityDetector(
      key: Key('video-${widget.item.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: _buildVideoPlayer(),
    );
  }

  Widget _buildVideoPlayer() {
    return StreamBuilder<void>(
      stream: widget.controller?.stateStream,
      builder: (context, snapshot) {
        final wrapper = widget.controller;

        if (wrapper == null) {
          return const Center(
            child: Text(
              'No video controller',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        if (wrapper.hasError) {
          return _buildErrorState(context, wrapper);
        }

        if (!wrapper.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        // Initialize chewie if not done yet
        if (_chewieController == null) {
          _initializeChewieController();
        }

        if (_chewieController == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return GestureDetector(
          onTap: () {
            if (wrapper.controller!.value.isPlaying) {
              wrapper.pause();
            } else {
              wrapper.play();
            }
          },
          child: Center(
            child: AspectRatio(
              aspectRatio: wrapper.controller!.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            ),
          ),
        );
      },
    );
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final source = widget.controller?.source;
    final id = widget.item.id;
    if (source == null) {
      return;
    }
    if (id == null) {
      return;
    }
    if (widget.onVisibilityChanged != null) {
      widget.onVisibilityChanged!(
        context,
        info,
        id,
        source,
      );
    }
  }

  Widget _buildErrorState(
    BuildContext context,
    VideoControllerWrapper wrapper,
  ) {
    if (widget.errorWidgetBuilder != null) {
      return Center(
        child: GestureDetector(
          onTap: widget.onRetry,
          child: widget.errorWidgetBuilder!(
            context,
            widget.item,
          ),
        ),
      );
    }
    return Center(
      child: MediaRetryButton(
        onRetry: widget.onRetry,
      ),
    );
  }
}

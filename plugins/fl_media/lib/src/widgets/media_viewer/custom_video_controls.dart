import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoControls extends StatelessWidget {
  const CustomVideoControls({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$seconds';
    } else {
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = ChewieController.of(context);
    final videoController = chewieController.videoPlayerController;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        // Bottom controls
        Align(
          alignment: Alignment.bottomCenter,
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: videoController,
            builder: (context, value, child) {
              final position = value.position;
              final duration = value.duration;
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;

              return Container(
                padding: const EdgeInsets.all(16),
                height: 60,
                color: const Color(0xff525252).withValues(alpha: 0.56),
                child: Row(
                  children: [
                    // Play button
                    GestureDetector(
                      onTap: () {
                        chewieController.isPlaying
                            ? chewieController.pause()
                            : chewieController.play();
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.grey[800],
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Current time
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 45,
                      ),
                      child: Text(
                        _formatDuration(position),
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Progress bar
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (newProgress) {
                            final newPosition = Duration(
                              milliseconds:
                                  (duration.inMilliseconds * newProgress)
                                      .round(),
                            );
                            videoController.seekTo(newPosition);
                          },
                          activeColor: Colors.green,
                          inactiveColor: Colors.white.withValues(alpha: 0.3),
                          thumbColor: Colors.white,
                          min: 0.0,
                          max: 1.0,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Total duration
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 45,
                      ),
                      child: Text(
                        _formatDuration(duration),
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(width: 8),
                    // Mute/Unmute button
                    GestureDetector(
                      onTap: () {
                        if (videoController.value.volume > 0) {
                          videoController.setVolume(0);
                        } else {
                          videoController.setVolume(1.0);
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          videoController.value.volume > 0
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: Colors.grey[800],
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Center play button
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: videoController,
          builder: (context, value, child) {
            final position = value.position;
            final isAtStart =
                position.inMilliseconds < 500; // Show if less than 0.5 seconds
            final shouldShow = !value.isPlaying && isAtStart;

            if (!shouldShow) {
              return const SizedBox.shrink();
            }

            return Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: chewieController.play,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

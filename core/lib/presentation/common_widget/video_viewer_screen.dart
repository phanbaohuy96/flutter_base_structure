import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:fl_ui/fl_ui.dart';
import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'forms/screen_form.dart';

class VideoViewerArgs {
  final String? title;
  final String? url;
  final File? file;

  VideoViewerArgs({
    this.title,
    this.url,
    this.file,
  });
}

class VideoViewerScreen extends StatefulWidget {
  final VideoViewerArgs? args;

  const VideoViewerScreen({Key? key, this.args}) : super(key: key);

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  double get paddingBottom => MediaQuery.of(context).padding.bottom;

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenForm(
      title: widget.args?.title ?? 'Video',
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.only(
          bottom: paddingBottom,
        ),
        color: Colors.white,
        child: FutureBuilder(
          future: _init(),
          builder: (context, snapshot) {
            return Center(
              child: snapshot.connectionState == ConnectionState.done
                  ? Builder(
                      builder: (context) {
                        _chewieController = ChewieController(
                          videoPlayerController: _controller!,
                          autoPlay: true,
                          allowMuting: true,
                          allowFullScreen: true,
                          deviceOrientationsAfterFullScreen: [
                            DeviceOrientation.portraitUp,
                          ],
                          deviceOrientationsOnEnterFullScreen: [
                            DeviceOrientation.portraitUp,
                          ],
                          autoInitialize: true,
                        );

                        return Chewie(
                          controller: _chewieController!,
                        );
                      },
                    )
                  : const Loading(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _init() async {
    if (widget.args?.file != null) {
      _controller = VideoPlayerController.file(
        widget.args!.file!,
      );
    } else if (widget.args?.url != null) {
      _controller = Uri.tryParse(widget.args?.url ?? '')?.let(
        VideoPlayerController.networkUrl,
      );
    }

    // _controller = VideoPlayerController.network(
    //   widget.args?.url ?? '',
    // );

    await _controller!.initialize();

    _controller = _controller;
  }
}

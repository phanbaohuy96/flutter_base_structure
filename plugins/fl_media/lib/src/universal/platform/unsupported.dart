import 'package:video_player/video_player.dart';

VideoPlayerController createWithFile(_) {
  throw UnsupportedError(
    'File-based video playback is not supported on this platform.',
  );
}

/// Unsupported platform - File not available
dynamic createFileFromPath(String path) {
  throw UnsupportedError('File operations not supported on this platform');
}

/// Unsupported platform implementation for video source
/// This file is used when neither dart:io nor dart:html is available

/// Platform file wrapper - unsupported platform
class PlatformFile {
  const PlatformFile._();

  static PlatformFile? fromPath(String path) {
    throw UnsupportedError(
      'File operations are not supported on this platform',
    );
  }

  String get path => throw UnsupportedError(
    'File operations are not supported on this platform',
  );
}

/// Check if m3u8 version is available - unsupported platform
Future<String?> checkUrlAvailability(String baseUrl) async {
  throw UnsupportedError(
    'HTTP requests are not supported on this platform',
  );
}

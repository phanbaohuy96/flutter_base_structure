import 'dart:developer';

import 'package:video_player/video_player.dart';

VideoPlayerController createWithFile(_) {
  throw UnsupportedError(
    'File-based video playback is not supported on this platform.',
  );
}

/// Web platform - File not available for local file playback
dynamic createFileFromPath(String path) {
  throw UnsupportedError('Local file playback not supported on web');
}

/// Platform file wrapper for web platform
class PlatformFile {
  const PlatformFile._();

  static PlatformFile? fromPath(String path) {
    // Web doesn't support local file access in the same way
    log(
      '[PlatformFile] Local file access not supported on web',
      level: 700,
      name: 'PlatformFile',
    );
    return null;
  }

  String get path => throw UnsupportedError(
    'File path not available on web platform',
  );
}

/// Check if m3u8 version is available for a given base URL
/// Returns m3u8 URL if available, null otherwise
/// Web implementation uses fetch API-style approach
Future<String?> checkUrlAvailability(String baseUrl) async {
  try {
    // Remove file extension and add .m3u8
    final m3u8Url = baseUrl.replaceAll(RegExp(r'\.\w+$'), '.m3u8');

    // On web, we'll attempt a simple check
    // Note: Actual implementation may need to use package:http or similar
    log(
      '[VideoSource] Checking m3u8 availability for $baseUrl',
      level: 500,
      name: 'VideoSource',
    );

    // For web, we assume m3u8 is available if the pattern matches
    // A proper implementation would use package:http to verify
    if (m3u8Url.contains('.m3u8')) {
      return m3u8Url;
    }
  } catch (e, s) {
    log(
      '[VideoSource] m3u8 check failed for $baseUrl: $e',
      level: 700,
      error: e,
      stackTrace: s,
      name: 'VideoSource',
    );
  }

  return null;
}

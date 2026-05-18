import 'dart:developer';
import 'dart:io';

import 'package:video_player/video_player.dart';

VideoPlayerController createWithFile(File file) {
  return VideoPlayerController.file(file);
}

/// Create a File instance from a file path (dart:io platform)
File createFileFromPath(String path) {
  return File(path);
}

/// Platform file wrapper for dart:io (mobile/desktop)
class PlatformFile {
  final File _file;

  const PlatformFile._(this._file);

  static PlatformFile? fromPath(String path) {
    try {
      return PlatformFile._(File(path));
    } catch (e, s) {
      log(
        '[PlatformFile] Failed to create file from path: $e',
        level: 700,
        error: e,
        stackTrace: s,
        name: 'PlatformFile',
      );
      return null;
    }
  }

  String get path => _file.path;

  File get file => _file;
}

/// Check if m3u8 version is available for a given base URL
/// Returns m3u8 URL if available, null otherwise
Future<String?> checkUrlAvailability(String baseUrl) async {
  try {
    final m3u8Url = '$baseUrl.m3u8';

    // Quick HEAD request to check availability (3s timeout)
    final uri = Uri.parse(m3u8Url);
    final client = HttpClient();

    try {
      final request = await client
          .headUrl(uri)
          .timeout(
            const Duration(seconds: 3),
          );
      final response = await request.close();

      if (response.statusCode == 200) {
        log(
          '[VideoSource] m3u8 available for $baseUrl',
          level: 500,
          name: 'VideoSource',
        );
        return m3u8Url;
      }
    } finally {
      client.close();
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

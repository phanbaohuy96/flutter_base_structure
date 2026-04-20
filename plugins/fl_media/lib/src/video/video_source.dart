import 'package:flutter/foundation.dart';

import '../universal/universal.dart';

/// Sealed class representing different video source types
/// Used to determine optimal video playback strategy
sealed class VideoSource {
  const VideoSource();

  factory VideoSource.fromUrl(String url) {
    if (url.isEmpty) {
      throw ArgumentError('URL cannot be empty');
    }
    if (url.startsWith('file://') || url.startsWith('/')) {
      return LocalVideoSource(url.replaceFirst('file://', ''));
    }
    return NetworkVideoSource(url);
  }

  /// Create video source from local file path (during upload)
  factory VideoSource.local(String filePath) = LocalVideoSource;

  /// Create video source from network URL (MP4, MOV, etc.)
  factory VideoSource.network(String url, {String? fallbackUrl}) =
      NetworkVideoSource;

  /// Check if m3u8 version is available for a given base URL
  /// Returns m3u8 URL if available, null otherwise
  /// Platform-specific implementation via universal exports
  static Future<String?> checkM3u8Availability(String baseUrl) async {
    return checkUrlAvailability(baseUrl);
  }

  /// Get the playable URL for this video source
  String? get url;

  /// Check if this is a local file source
  bool get isLocal;

  /// Check if this is an HLS/m3u8 source
  bool get isHls;
}

/// Local file video source (used during upload preview)
class LocalVideoSource extends VideoSource {
  final String filePath;
  final PlatformFile? _platformFile;

  LocalVideoSource(this.filePath)
    : _platformFile = PlatformFile.fromPath(filePath);

  @override
  String? get url {
    if (kIsWeb) {
      // Web platform doesn't support local file URLs in the same way
      return null;
    }
    return _platformFile != null ? 'file://$filePath' : null;
  }

  @override
  bool get isLocal => true;

  @override
  bool get isHls => false;
}

/// Network video source (MP4, MOV, etc.)
class NetworkVideoSource extends VideoSource {
  final String networkUrl;
  final String? fallbackUrl;

  const NetworkVideoSource(this.networkUrl, {this.fallbackUrl});

  @override
  String get url => networkUrl;

  @override
  bool get isLocal => false;

  @override
  bool get isHls => networkUrl.endsWith('.m3u8');

  /// Create a fallback source if available
  NetworkVideoSource? get fallback =>
      fallbackUrl != null ? NetworkVideoSource(fallbackUrl!) : null;
}

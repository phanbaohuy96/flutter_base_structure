import 'dart:io'
    if (dart.library.html) 'package:extended_image_library/src/_platform_web.dart'
    if (dart.library.js_interop) 'package:extended_image_library/src/_platform_web.dart';

import 'package:flutter/foundation.dart';

/// Represents a media item in the viewer
/// Supports two main sources:
/// - CloudFile: network URLs (from cloud storage)
/// - FilePicked: local files with web support (bytes on web, path on native)
class MediaViewerItem {
  final String? id;
  final String? url;
  final File? file;
  final Uint8List? bytes;
  final bool isVideo;
  final bool isAsset;
  final String? mimeType;

  const MediaViewerItem({
    this.isAsset = false,
    required this.id,
    this.url,
    this.file,
    this.bytes,
    required this.isVideo,
    this.mimeType,
  }) : assert(
         url != null || file != null || bytes != null,
         'Either url, file, or bytes must be provided',
       );

  /// Create a network image item (CloudFile)
  factory MediaViewerItem.network(String? id, String url, {String? mimeType}) {
    return MediaViewerItem(
      id: id,
      url: url,
      isVideo: false,
      mimeType: mimeType,
    );
  }

  /// Create a network video item (CloudFile)
  factory MediaViewerItem.video(String? id, String url, {String? mimeType}) {
    return MediaViewerItem(
      id: id,
      url: url,
      isVideo: true,
      mimeType: mimeType ?? 'video/mp4',
    );
  }

  /// Create a local file image item (FilePicked)
  /// On web, bytes should be provided and file can be a stub; on native,
  /// file path is used
  factory MediaViewerItem.file(
    String? id,
    File? file, {
    Uint8List? bytes,
    String? mimeType,
  }) {
    return MediaViewerItem(
      id: id,
      file: file,
      bytes: bytes,
      isVideo: false,
      mimeType: mimeType,
    );
  }

  /// Create a local video file item (FilePicked)
  /// On web, URL is required; on native, converts file path to file:// URL
  factory MediaViewerItem.videoFile(
    String? id,
    File file, {
    String? url,
    String? mimeType,
  }) {
    // For video: web needs URL, native uses file:// URL
    final videoUrl = url ?? (!kIsWeb ? 'file://${file.path}' : null);

    return MediaViewerItem(
      id: id,
      url: videoUrl,
      file: file,
      isVideo: true,
      mimeType: mimeType ?? 'video/mp4',
    );
  }

  /// Create an asset media item
  factory MediaViewerItem.asset(
    String? id,
    String assetPath, {
    String? mimeType,
  }) {
    return MediaViewerItem(
      id: id,
      url: assetPath,
      isAsset: true,
      isVideo: assetPath.endsWith('.mp4') || assetPath.endsWith('.mov'),
      mimeType: mimeType,
    );
  }

  /// Get the source path (url or file path)
  /// On web, file.path is not available, so we return url instead
  String? get source => url ?? (kIsWeb ? null : file?.path);

  bool get isLocalFile =>
      file != null &&
      (url == null || url!.startsWith('file://') || url!.startsWith('/'));
}

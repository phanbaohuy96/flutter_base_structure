import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../core.dart';
import '../../l10n/localization_ext.dart';

/// # MediaPickerWidget
///
/// A comprehensive Flutter widget for picking, displaying, and managing media files (photos and videos).
/// Supports camera capture, gallery selection, automatic upload, and validation.
///
/// ## Features
/// - Photo and video selection from gallery
/// - Camera capture
/// - Automatic file upload with progress tracking
/// - File size validation
/// - Multiple media type configurations
/// - Grid display with customizable layout
/// - Video thumbnail generation
/// - Error handling and retry functionality
/// - Drag and drop support (web)
///
/// ## Basic Usage
///
/// ### Simple Photo Picker
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   _MyWidgetState createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   late MediaPickerController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = MediaPickerController(
///       onMediaPicked: (medias) {
///         print('Picked ${medias.length} media files');
///       },
///     );
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MediaPickerWidget(
///       controller: _controller,
///       config: const MediaPickerConfig(
///         mediaTypes: [MediaType.photo],
///         maxMedia: 5,
///       ),
///     );
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
/// }
/// ```
///
/// ### Advanced Configuration
/// ```dart
/// MediaPickerWidget(
///   controller: _controller,
///   config: const MediaPickerConfig(
///     mediaTypes: [MediaType.photo, MediaType.video],
///     maxMedia: 10,
///     minimumRequired: 2,
///     crossAxisCount: 3,
///     maxSizePerFileInMB: 25.0,
///     autoUpload: true,
///     pickDialogTitle: 'Select Media',
///     pickDialogMessage: 'Choose photos or videos',
///   ),
///   style: const MediaPickerStyle(
///     foregroundColor: Colors.blue,
///     backgroundColor: Colors.grey,
///     borderRadius: Radius.circular(12),
///   ),
///   onMediaPicked: (medias) {
///     // Handle media selection
///   },
///   onTap: (media) {
///     // Handle media tap
///   },
///   canBeDeleteWhen: (medias) => medias.length > 1,
/// )
/// ```
///
/// ### Camera Only Mode
/// ```dart
/// MediaPickerWidget(
///   controller: _controller,
///   config: const MediaPickerConfig(
///     mediaTypes: [MediaType.capture],
///   ),
/// )
/// ```
///
/// ### Pre-populated Media
/// ```dart
/// final controller = MediaPickerController(
///   medias: [
///     MediaPicked.create(
///       cloudFile: CloudFile(url: 'https://example.com/image.jpg'),
///       mimetype: 'image/jpeg',
///     ),
///   ],
/// );
/// ```
///
/// ## Controller Methods
///
/// ```dart
/// // Add media programmatically
/// controller.addAll([mediaPicked1, mediaPicked2]);
///
/// // Set media (replaces existing)
/// controller.set([mediaPicked1]);
///
/// // Remove specific media
/// controller.remove(mediaPicked);
///
/// // Upload unstaged medias
/// await controller.uploadUnstagedMedias();
///
/// // Check upload status
/// if (controller.isUploading) {
///   // Show loading indicator
/// }
/// ```
///
/// ## Configuration Options
///
/// ### MediaPickerConfig
/// - `mediaTypes`: List of allowed media types
///   [MediaType.photo, MediaType.video, MediaType.capture]
/// - `maxMedia`: Maximum number of media files allowed
/// - `minimumRequired`: Minimum number of media files required
/// - `crossAxisCount`: Number of columns in the grid (default: 4)
/// - `maxSizePerFileInMB`: Maximum file size in MB
/// - `autoUpload`: Whether to automatically upload selected files
/// - `pickDialogTitle`: Custom title for picker dialog
/// - `pickDialogMessage`: Custom message for picker dialog
/// - `mainAxisSpacing`: Vertical spacing between grid items
/// - `crossAxisSpacing`: Horizontal spacing between grid items
///
/// ### MediaPickerStyle
/// - `foregroundColor`: Color for icons and text
/// - `backgroundColor`: Background color for empty state
/// - `borderRadius`: Border radius for media items
/// - `emptyBorderSide`: Border style for empty state
///
/// ## Media Types
///
/// - `MediaType.photo`: Allow photo selection from gallery
/// - `MediaType.video`: Allow video selection from gallery
/// - `MediaType.capture`: Camera capture only mode
///
/// ## Callbacks
///
/// ```dart
/// MediaPickerController(
///   onMediaPicked: (List<MediaPicked> medias) {
///     // Called when media is picked
///   },
///   onUploadUnstagedDone: (List<MediaPicked> medias) {
///     // Called when upload completes
///   },
///   onRemoveMedia: (MediaPicked media) {
///     // Called when media is removed
///   },
///   onUploadError: (MediaPicked media, error, stackTrace) {
///     // Called when upload fails
///   },
/// )
/// ```
///
/// ## Error Handling
///
/// The widget automatically handles common errors:
/// - File size validation
/// - File type validation
/// - Upload failures with retry option
/// - Permission denied for camera access
///
/// Use `ErrorBoxController` for custom error display:
/// ```dart
/// final errorController = ErrorBoxController();
///
/// MediaPickerWidget(
///   controller: _controller,
///   errorController: errorController,
///   // ... other properties
/// )
/// ```

// MARK: - Enums and Extensions

enum MediaType { video, capture, photo }

extension MediaTypeListExtension on List<MediaType> {
  FileType get fileType {
    if (contains(MediaType.photo) && contains(MediaType.video)) {
      return FileType.media;
    }
    if (contains(MediaType.photo)) {
      return FileType.image;
    }
    if (contains(MediaType.video)) {
      return FileType.video;
    }
    return FileType.media;
  }

  bool get allowsPhoto =>
      contains(MediaType.photo) || contains(MediaType.capture);
  bool get allowsVideo => contains(MediaType.video);
  bool get isCaptureOnly => length == 1 && contains(MediaType.capture);
}

// MARK: - Data Models

class MediaPicked extends Equatable {
  const MediaPicked({
    String? key,
    this.mediaFile,
    this.mimetype,
    this.isInUploadProgress = false,
    this.hasError = false,
    this.videoThumbnail,
    this.index,
    this.cloudFile,
  }) : key = key ?? '';

  final String key;
  final FilePicked? mediaFile;
  final String? mimetype;
  final bool isInUploadProgress;
  final bool hasError;
  final Uint8List? videoThumbnail;
  final int? index;
  final CloudFile? cloudFile;

  // Factory constructor for empty state
  factory MediaPicked.empty() => MediaPicked(key: const Uuid().v4());

  // Factory constructor with auto-generated key
  factory MediaPicked.create({
    FilePicked? mediaFile,
    String? mimetype,
    bool isInUploadProgress = false,
    bool hasError = false,
    Uint8List? videoThumbnail,
    int? index,
    CloudFile? cloudFile,
  }) {
    return MediaPicked(
      key: const Uuid().v4(),
      mediaFile: mediaFile,
      mimetype: mimetype,
      isInUploadProgress: isInUploadProgress,
      hasError: hasError,
      videoThumbnail: videoThumbnail,
      index: index,
      cloudFile: cloudFile,
    );
  }

  bool get isVideo => mimetype?.contains('video') == true;
  bool get isLoading => isInUploadProgress;
  bool get isUploadError => hasError;
  bool get isEmpty =>
      mediaFile == null &&
      url.isNullOrEmpty &&
      cloudFile?.id?.isNotNullOrEmpty != true;

  String? get fileName =>
      mediaFile?.name ?? mediaFile?.path?.let(path.basename);

  String? get url => cloudFile?.url.isNotNullOrEmpty == true
      ? cloudFile?.url
      : cloudFile?.filenameDisk;

  MediaPicked copyWith({
    String? key,
    ValueGetter<FilePicked?>? mediaFile,
    ValueGetter<String?>? mimetype,
    bool? isInUploadProgress,
    bool? hasError,
    ValueGetter<Uint8List?>? videoThumbnail,
    ValueGetter<int?>? index,
    ValueGetter<CloudFile?>? cloudFile,
  }) {
    return MediaPicked(
      key: key ?? this.key,
      mediaFile: mediaFile?.call() ?? this.mediaFile,
      mimetype: mimetype?.call() ?? this.mimetype,
      isInUploadProgress: isInUploadProgress ?? this.isInUploadProgress,
      hasError: hasError ?? this.hasError,
      videoThumbnail: videoThumbnail?.call() ?? this.videoThumbnail,
      index: index?.call() ?? this.index,
      cloudFile: cloudFile?.call() ?? this.cloudFile,
    );
  }

  Future<Uint8List?> loadVideoThumbnail() async {
    if (videoThumbnail != null) {
      return videoThumbnail;
    }

    final uri = mediaFile?.path ?? url;
    if (uri == null) {
      return null;
    }

    try {
      return await VideoThumbnail.thumbnailData(
        video: uri,
        maxHeight: 100,
        quality: 70,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        key,
        mediaFile,
        mimetype,
        isInUploadProgress,
        hasError,
        videoThumbnail,
        index,
        cloudFile,
      ];
}

// MARK: - Controller

class MediaPickerController extends ValueNotifier<List<MediaPicked>>
    with StorageServiceMixin {
  MediaPickerController({
    List<MediaPicked> medias = const [],
    this.onUploadUnstagedDone,
    this.onRemoveMedia,
    this.onMediaPicked,
    this.onUploadError,
    this.allowMultiple = true,
    this.genFileName,
  }) : super(medias);

  // Callbacks
  final Function(List<MediaPicked>)? onUploadUnstagedDone;
  final Function(MediaPicked)? onRemoveMedia;
  final Function(List<MediaPicked>)? onMediaPicked;
  Function(MediaPicked, dynamic error, StackTrace stackTrace)? onUploadError;
  final String Function(MediaPicked pickedMedia)? genFileName;

  // Configuration
  final bool allowMultiple;

  // Private state
  int _uploadUnstagedMediaRequest = 0;

  bool get isUploading => _uploadUnstagedMediaRequest > 0;

  void addAll(Iterable<MediaPicked> medias) {
    final existingKeys = value.map((e) => e.key).toSet();
    final newMedias =
        medias.where((media) => !existingKeys.contains(media.key));
    value = [...value, ...newMedias];
  }

  void set(Iterable<MediaPicked> medias) {
    value = [...medias];
  }

  void remove(MediaPicked media) {
    value = value.where((e) => e.key != media.key).toList();
    onRemoveMedia?.call(media);
  }

  Future<void> uploadUnstagedMedias() async {
    final unstagedMedias = _getUnstagedMedias();
    if (unstagedMedias.isEmpty) {
      return;
    }

    _markMediasAsUploading(unstagedMedias);

    _uploadUnstagedMediaRequest++;

    try {
      await Future.wait(unstagedMedias.map(_uploadMedia));
    } finally {
      _uploadUnstagedMediaRequest--;
      if (_uploadUnstagedMediaRequest == 0) {
        onUploadUnstagedDone?.call(value);
      }
    }
  }

  List<MediaPicked> _getUnstagedMedias() {
    return value
        .where((media) => !media.isLoading && media.url.isNullOrEmpty)
        .toList();
  }

  void _markMediasAsUploading(List<MediaPicked> medias) {
    for (final media in medias) {
      _updateMedia(media.copyWith(isInUploadProgress: true));
    }
    notifyListeners();
  }

  Future<void> _uploadMedia(MediaPicked media) async {
    final file = media.mediaFile;
    if (file == null) {
      return;
    }

    try {
      _updateMedia(media.copyWith(hasError: false));

      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final fileName = media.fileName ?? file.path?.split('/').last ?? '';

      final cloudFile = await storageService.uploadBytes(
        bytes,
        fileName,
        mimeType: media.mimetype ?? file.mimeType,
        filePath: file.path,
      );

      _updateMedia(
        media.copyWith(
          isInUploadProgress: false,
          cloudFile: () => cloudFile,
          hasError: false,
        ),
      );
    } catch (e, s) {
      final errorMedia =
          media.copyWith(hasError: true, isInUploadProgress: false);
      _updateMedia(errorMedia);
      onUploadError?.call(errorMedia, e, s);
    }
  }

  void _updateMedia(MediaPicked updatedMedia) {
    final index = value.indexWhere((media) => media.key == updatedMedia.key);
    if (index != -1) {
      final newValue = [...value];
      newValue[index] = updatedMedia;
      value = newValue;
    }
  }
}

// MARK: - Widget Configuration

class MediaPickerConfig {
  const MediaPickerConfig({
    this.mediaTypes = const [MediaType.photo],
    this.pickDialogTitle,
    this.pickDialogMessage,
    this.autoUpload = true,
    this.maxMedia,
    this.minimumRequired,
    this.crossAxisCount = 4,
    this.maxSizePerFileInMB,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
  });

  final List<MediaType> mediaTypes;
  final String? pickDialogTitle;
  final String? pickDialogMessage;
  final bool autoUpload;
  final int? maxMedia;
  final int? minimumRequired;
  final int crossAxisCount;
  final double? maxSizePerFileInMB;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
}

class MediaPickerStyle {
  const MediaPickerStyle({
    this.foregroundColor,
    this.backgroundColor,
    this.borderRadius,
    this.emptyBorderSide = const BorderSide(color: Colors.grey, width: 1),
  });

  final Color? foregroundColor;
  final Color? backgroundColor;
  final Radius? borderRadius;
  final BorderSide? emptyBorderSide;
}

// MARK: - Main Widget

class MediaPickerWidget extends StatefulWidget {
  const MediaPickerWidget({
    Key? key,
    required this.controller,
    this.config = const MediaPickerConfig(),
    this.style = const MediaPickerStyle(),
    this.onMediaPicked,
    this.onTap,
    this.canBeDeleteWhen,
    this.errorController,
  }) : super(key: key);

  final MediaPickerController controller;
  final MediaPickerConfig config;
  final MediaPickerStyle style;
  final void Function(List<MediaPicked>)? onMediaPicked;
  final void Function(MediaPicked)? onTap;
  final bool Function(List<MediaPicked>)? canBeDeleteWhen;
  final ErrorBoxController? errorController;

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends CoreStateBase<MediaPickerWidget>
    with StorageServiceMixin {
  late CoreLocalizations l10n;

  @override
  void didUpdateWidget(covariant MediaPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.onUploadError ??= _onUploadError;
  }

  void _onUploadError(MediaPicked media, dynamic error, StackTrace stackTrace) {
    final errorData = ErrorData.fromObject(error: error);
    if (errorData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.coreL10n.errorWhenUploading)),
      );
    } else {
      onError(errorData);
    }
  }

  @override
  Widget build(BuildContext context) {
    l10n = context.coreL10n;

    return ValueListenableBuilder<List<MediaPicked>>(
      valueListenable: widget.controller,
      builder: (context, medias, _) {
        final canBeDelete = widget.canBeDeleteWhen?.call(medias) ?? true;
        final canAdd = widget.config.maxMedia == null ||
            medias.length < widget.config.maxMedia!;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: widget.config.crossAxisCount,
          childAspectRatio: 1.0,
          padding: EdgeInsets.zero,
          mainAxisSpacing: widget.config.mainAxisSpacing,
          crossAxisSpacing: widget.config.crossAxisSpacing,
          children: [
            ...medias.map(
              (media) => _MediaItemWidget(
                media: media,
                canDelete: canBeDelete,
                onTap: widget.onTap,
                onRemove: widget.controller.remove,
                onRetryUpload: widget.controller._uploadMedia,
                style: widget.style,
                borderRadius: widget.style.borderRadius,
                onViewMedia: _viewMedia,
              ),
            ),
            if (canAdd)
              _MediaEmptyStateWidget(
                medias: medias,
                config: widget.config,
                style: widget.style,
                errorController: widget.errorController,
                onTap: _showMediaPickerActionDialog,
                l10n: l10n,
              ),
          ],
        );
      },
    );
  }

  Future<void> _showMediaPickerActionDialog() async {
    if (widget.config.mediaTypes.isCaptureOnly) {
      return _openCamera();
    }

    return showActionDialog(
      context,
      titleBottomBtn: l10n.cancel,
      title: _getDialogTitle(),
      subTitle: widget.config.pickDialogMessage ?? '',
      actions: {
        l10n.camera: _openCamera,
        l10n.gallery: _openGallery,
      },
    );
  }

  String _getDialogTitle() {
    if (widget.config.pickDialogTitle.isNotNullOrEmpty) {
      return widget.config.pickDialogTitle!;
    }

    if (widget.config.mediaTypes.contains(MediaType.capture)) {
      return l10n.camera;
    }

    final hasPhoto = widget.config.mediaTypes.allowsPhoto;
    final hasVideo = widget.config.mediaTypes.allowsVideo;

    if (hasPhoto && hasVideo) {
      return l10n.choosePhotoOrVideo;
    }
    if (hasPhoto) {
      return l10n.choosePhoto;
    }
    if (hasVideo) {
      return l10n.chooseVideo;
    }
    return l10n.choosePhotoOrVideo;
  }

  Future<void> _openGallery() async {
    try {
      final pickedFiles = await PickFileHelper()
          .pickFiles(
            type: widget.config.mediaTypes.fileType,
            dialogTitle: _getDialogTitle(),
            allowMultiple: widget.controller.allowMultiple &&
                (widget.config.maxMedia == null ||
                    (widget.config.maxMedia! - widget.controller.value.length) >
                        1),
          )
          .catchError(
            (error, stackTrace) =>
                logUtils.eCatch('PickFileHelper.pickFiles', error, stackTrace),
          );

      if (pickedFiles.isNotEmpty) {
        _onMediaPicked(pickedFiles);
      }
    } catch (error, stackTrace) {
      logUtils.eCatch('_openGallery', error, stackTrace);
    }
  }

  Future<void> _openCamera() async {
    if (!kIsWeb) {
      final granted = await PermissionService()
          .requestPermission(Permission.camera, context);
      if (!granted) {
        return;
      }
    }

    try {
      final pickedFile = await PickFileHelper().takePicture().catchError(
            (error, stackTrace) => logUtils.eCatch<FilePicked?>(
              'PickFileHelper.takePicture',
              error,
              stackTrace,
            ),
          );

      if (pickedFile != null && pickedFile.valid) {
        imageCache.clearLiveImages();
        _onMediaPicked([pickedFile]);
      }
    } catch (error, stackTrace) {
      logUtils.eCatch('_openCamera', error, stackTrace);
    }
  }

  void _onMediaPicked(List<FilePicked> filePicked) {
    final validFiles = _validateFiles(filePicked);
    if (validFiles.isEmpty) {
      return;
    }

    final currentMaxIndex = widget.controller.value.isNotEmpty
        ? widget.controller.value
            .map((e) => e.index ?? 0)
            .reduce((a, b) => a > b ? a : b)
        : -1;

    final mediaPickedList = validFiles
        .mapIndex(
          (file, index) => MediaPicked.create(
            mediaFile: file,
            mimetype: file.mimeType ?? lookupMimeType(file.path ?? ''),
            index: currentMaxIndex + 1 + index,
          ),
        )
        .toList();

    // Limit to max media count
    final limitedList = widget.config.maxMedia != null
        ? mediaPickedList.take(
            widget.config.maxMedia! - widget.controller.value.length,
          )
        : mediaPickedList;

    widget.controller.addAll(limitedList);

    if (widget.config.autoUpload) {
      widget.controller.uploadUnstagedMedias();
    }

    widget.onMediaPicked?.call(widget.controller.value);
    widget.controller.onMediaPicked?.call(widget.controller.value);
  }

  List<FilePicked> _validateFiles(List<FilePicked> files) {
    final validFiles = <FilePicked>[];
    final maxSize = widget.config.maxSizePerFileInMB ?? double.infinity;

    for (final file in files) {
      if (file.sizeInMB > maxSize) {
        _showError(
          context.coreL10n.fileSizeOverXMB(maxSize.toStringAsMaxFixed(2)),
        );
        continue;
      }

      if (!_isFileTypeAllowed(file)) {
        continue;
      }

      validFiles.add(file);
    }

    return validFiles;
  }

  bool _isFileTypeAllowed(FilePicked file) {
    final isVideo = file.mimeType?.contains('video') == true;
    final isPhoto = file.mimeType?.contains('image') == true;

    final allowsVideo = widget.config.mediaTypes.allowsVideo;
    final allowsPhoto = widget.config.mediaTypes.allowsPhoto;

    if (isVideo && !allowsVideo) {
      _showError(context.coreL10n.onlyImageAllowed);
      return false;
    }

    if (isPhoto && !allowsPhoto) {
      _showError(context.coreL10n.onlyVideoAllowed);
      return false;
    }

    if (!isVideo && !isPhoto) {
      if (allowsPhoto && allowsVideo) {
        _showError(context.coreL10n.onlyImageOrVideoAllowed);
      }
      if (allowsPhoto) {
        _showError(context.coreL10n.onlyImageAllowed);
      }
      if (allowsVideo) {
        _showError(context.coreL10n.onlyVideoAllowed);
      }
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _viewMedia(MediaPicked media) {
    if (media.mediaFile == null && media.url.isNullOrEmpty) {
      return;
    }

    final uri = media.url.isNotNullOrEmpty
        ? storageAssetProvider.url(media.url!)
        : media.mediaFile!.path;

    if (uri != null) {
      openImageGallery(context: context, images: [uri]);
    }
  }
}

// MARK: - Supporting Widgets

class _MediaEmptyStateWidget extends StatelessWidget {
  const _MediaEmptyStateWidget({
    Key? key,
    required this.medias,
    required this.config,
    required this.style,
    required this.onTap,
    required this.l10n,
    this.errorController,
  }) : super(key: key);

  final List<MediaPicked> medias;
  final MediaPickerConfig config;
  final MediaPickerStyle style;
  final VoidCallback onTap;
  final CoreLocalizations l10n;
  final ErrorBoxController? errorController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, right: 6),
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: style.borderRadius?.let(BorderRadius.all),
        child: InkWell(
          onTap: onTap,
          borderRadius: style.borderRadius?.let(BorderRadius.all),
          child: AnimatedBuilder(
            animation: Listenable.merge(
              [if (errorController != null) errorController!],
            ),
            builder: (context, child) {
              final hasError = errorController?.value != null;
              return DottedBorder(
                color: hasError
                    ? Colors.red
                    : style.emptyBorderSide?.color ??
                        style.foregroundColor ??
                        context.themeColor.primary,
                strokeWidth: style.emptyBorderSide?.width ?? 1,
                dashPattern: const [5, 5],
                strokeCap: StrokeCap.round,
                borderType: BorderType.RRect,
                radius: style.borderRadius ?? const Radius.circular(0),
                child: Container(
                  alignment: Alignment.center,
                  color: style.backgroundColor ??
                      context.themeColor.primary
                          .withAlpha((0.09 * 255).round()),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 22,
                        color:
                            style.foregroundColor ?? context.themeColor.primary,
                      ),
                      if (config.maxMedia != null && config.maxMedia! > 1)
                        Text(
                          '${medias.length}/${config.maxMedia}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: style.foregroundColor ??
                                context.themeColor.primary,
                          ),
                        ),
                      if (config.minimumRequired != null)
                        Text(
                          '''(${medias.length < config.minimumRequired! ? l10n.required : l10n.optional})''',
                          style: context.textTheme.labelSmall,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MediaItemWidget extends StatelessWidget {
  const _MediaItemWidget({
    Key? key,
    required this.media,
    required this.canDelete,
    required this.onRemove,
    required this.onRetryUpload,
    required this.style,
    required this.onViewMedia,
    this.onTap,
    this.borderRadius,
  }) : super(key: key);

  final MediaPicked media;
  final bool canDelete;
  final void Function(MediaPicked)? onTap;
  final void Function(MediaPicked) onRemove;
  final Future<void> Function(MediaPicked) onRetryUpload;
  final void Function(MediaPicked) onViewMedia;
  final MediaPickerStyle style;
  final Radius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(media);
        } else if (!media.isVideo) {
          onViewMedia(media);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildMediaContent(constraints),
              if (canDelete) _buildDeleteButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaContent(BoxConstraints constraints) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: ClipRRect(
        borderRadius:
            borderRadius?.let(BorderRadius.all) ?? BorderRadius.circular(0),
        child: SizedBox(
          width: constraints.maxWidth - 6,
          height: constraints.maxHeight - 6,
          child: Stack(
            children: [
              if (media.isVideo)
                _buildVideoThumbnail(constraints)
              else
                _buildImageContent(constraints),
              if (media.isLoading || media.isUploadError)
                _buildLoadingOrErrorOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(BoxConstraints constraints) {
    return FutureBuilder<Uint8List?>(
      future: media.loadVideoThumbnail(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (snapshot.hasData)
              Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: constraints.maxWidth - 6,
                height: constraints.maxHeight - 6,
              )
            else
              _buildLoadingPlaceholder(constraints),
            const Center(
              child: Icon(Icons.play_arrow_rounded, size: 32),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageContent(BoxConstraints constraints) {
    final width = constraints.maxWidth - 6;
    final height = constraints.maxHeight - 6;

    if (media.mediaFile?.bytes != null) {
      return Image.memory(
        media.mediaFile!.bytes!,
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    }

    if (media.mediaFile?.path != null) {
      return Image.file(
        File(media.mediaFile!.path!),
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    }

    return ImageViewWrapper.item(
      media.url ?? '',
      fit: BoxFit.cover,
      width: width,
      height: height,
    );
  }

  Widget _buildLoadingPlaceholder(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth - 6,
      height: constraints.maxHeight - 6,
      decoration: BoxDecoration(
        color: Colors.white38,
        borderRadius: borderRadius?.let(BorderRadius.all),
      ),
      child: const Loading(brightness: Brightness.light, radius: 12),
    );
  }

  Widget _buildLoadingOrErrorOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white38,
        borderRadius: borderRadius?.let(BorderRadius.all),
      ),
      alignment: Alignment.center,
      child: media.isUploadError
          ? IconButton(
              onPressed: () => onRetryUpload(media),
              icon: const Icon(Icons.rotate_right, size: 28),
            )
          : const Loading(brightness: Brightness.light, radius: 12),
    );
  }

  Widget _buildDeleteButton() {
    return Positioned(
      right: -13,
      top: -13,
      child: IconButton(
        iconSize: 20,
        padding: EdgeInsets.zero,
        icon: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFFB4B53),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.close, size: 10, color: Colors.white),
        ),
        onPressed: () => onRemove(media),
      ),
    );
  }
}

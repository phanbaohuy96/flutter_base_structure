import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../core.dart';
import '../../l10n/localization_ext.dart';

class MediaPickerController extends ValueNotifier<List<MediaPicked>>
    with StorageServiceMixin {
  /// Call with [this.value] args
  Function(List<MediaPicked>)? onUploadUnstagedDone;

  /// Call when removed media picked
  Function(MediaPicked)? onRemoveMedia;

  /// Call when addAll
  Function(List<MediaPicked>)? onMediaPicked;

  /// Allow multiple pick
  bool allowMultiple;

  /// Call when gen file name
  String Function(MediaPicked pickedMedia)? genFileName;

  MediaPickerController({
    List<MediaPicked> medias = const [],
    this.onUploadUnstagedDone,
    this.onRemoveMedia,
    this.allowMultiple = true,
    this.genFileName,
    this.onMediaPicked,
  }) : super(medias);

  var _uploadUnstagedMediaRequest = 0;

  bool get isUploading => _uploadUnstagedMediaRequest != 0;

  void addAll(Iterable<MediaPicked> medias) {
    value = [
      ...value,
      ...medias.where(
        (insert) => !value.any((value) => insert.key == value.key),
      ),
    ];
    onMediaPicked?.call(value);
  }

  void remove(MediaPicked media) {
    value = [...value..removeWhere((e) => e.key == media.key)];
    onRemoveMedia?.call(media);
  }

  Future<void> uploadUnstagedMedias() async {
    final _unstagedMedias = <MediaPicked>[];
    for (var i = 0; i < value.length; i++) {
      var media = value[i];
      if (!media.isLoading && media.url.isNullOrEmpty) {
        media = media.copyWith(isInUploadProgress: true);
        value[i] = media;
        _unstagedMedias.add(media);
      }
    }
    notifyListeners();
    if (_unstagedMedias.isNotEmpty) {
      _uploadUnstagedMediaRequest++;
      await Future.wait([
        ..._unstagedMedias.map(
          _uploadMedia,
        ),
      ]);
      _uploadUnstagedMediaRequest--;
      if (_uploadUnstagedMediaRequest == 0) {
        _notifyUploadUnstagedDone();
      }
    }
  }

  Future<void> _uploadMedia(
    MediaPicked media,
  ) async {
    final file = media.mediaFile!;
    try {
      final cloudFile = await storageService.uploadBytes(
        file.bytes ?? await File(file.path!).readAsBytes(),
        media.fileName ?? file.path?.split('/').last ?? '',
        mimeType: media.mimetype,
        filePath: file.path,
      );
      _updateMedia(
        media.copyWith(
          isInUploadProgress: false,
          cloudFile: () => cloudFile,
        ),
      );
    } catch (e, stackTrace) {
      // value = [...value.where((e) => e.key != media.key)];
      logUtils
        ..e('_uploadMedia', e, stackTrace)
        ..d('retry upload media');
      // await _uploadMedia(media);
    }
  }

  void _updateMedia(MediaPicked media) {
    for (var i = 0; i < value.length; i++) {
      if (value[i].key == media.key) {
        value[i] = media;
        notifyListeners();
        break;
      }
    }
  }

  void _notifyUploadUnstagedDone() {
    onUploadUnstagedDone?.call(value);
  }
}

enum MediaType { video, capture, photo, both }

extension _MediaType on MediaType {
  FileType get fileType {
    switch (this) {
      case MediaType.photo:
        return FileType.image;
      case MediaType.video:
        return FileType.video;
      default:
        return FileType.media;
    }
  }
}

// ignore: must_be_immutable
class MediaPicked extends Equatable {
  final String key;
  final FilePicked? mediaFile;
  final String? mimetype;
  final bool isInUploadProgress;
  Uint8List? videoThumbnail;
  final int? index;
  final CloudFile? cloudFile;

  MediaPicked({
    String? key,
    this.mediaFile,
    this.mimetype,
    this.isInUploadProgress = false,
    this.videoThumbnail,
    this.index,
    this.cloudFile,
  }) : key = key ?? const Uuid().v4();

  bool get isVideo => mimetype?.contains('video') == true;

  MediaPicked copyWith({
    String? key,
    ValueGetter<FilePicked?>? mediaFile,
    ValueGetter<String?>? mimetype,
    bool? isInUploadProgress,
    ValueGetter<Uint8List?>? videoThumbnail,
    ValueGetter<int?>? index,
    ValueGetter<CloudFile?>? cloudFile,
  }) {
    return MediaPicked(
      key: key ?? this.key,
      mediaFile: mediaFile != null ? mediaFile() : this.mediaFile,
      mimetype: mimetype != null ? mimetype() : this.mimetype,
      isInUploadProgress: isInUploadProgress ?? this.isInUploadProgress,
      videoThumbnail:
          videoThumbnail != null ? videoThumbnail() : this.videoThumbnail,
      index: index != null ? index() : this.index,
      cloudFile: cloudFile != null ? cloudFile() : this.cloudFile,
    );
  }

  bool get isLoading => isInUploadProgress;
  bool get isEmpty => mediaFile == null && url.isNullOrEmpty;
  String? get fileName =>
      mediaFile?.name ?? mediaFile?.path?.let(path.basename);
  String? get url => cloudFile?.url.isNotNullOrEmpty == true
      ? cloudFile?.url
      : cloudFile?.filenameDisk;

  Future<Uint8List?> loadVideoThumbnail() async {
    if (videoThumbnail != null) {
      return videoThumbnail;
    }
    final uri = mediaFile?.path ?? url;
    return uri?.let((it) {
      return VideoThumbnail.thumbnailData(
        video: it,
        maxHeight: 100,
        quality: 70,
      ).then((value) => videoThumbnail = value);
    });
  }

  @override
  List<Object?> get props => [
        key,
        mediaFile,
        mimetype,
        isInUploadProgress,
        videoThumbnail,
        index,
        cloudFile,
      ];
}

class MediaPickerWidget extends StatefulWidget {
  final MediaPickerController controller;
  final void Function(MediaPicked)? onMediaPicked;
  final void Function(MediaPicked)? onTap;
  final String? pickDialogTitle;
  final String? pickDialogMessage;
  final bool autoUpload;
  final MediaType mediaType;
  final bool Function(List<MediaPicked>)? canBeDeleteWhen;
  final int? maxMedia;
  final int crossAxisCount;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const MediaPickerWidget({
    Key? key,
    required this.controller,
    this.onTap,
    this.onMediaPicked,
    this.mediaType = MediaType.photo,
    this.pickDialogTitle,
    this.pickDialogMessage,
    this.autoUpload = true,
    this.canBeDeleteWhen,
    this.maxMedia,
    this.crossAxisCount = 4,
    this.foregroundColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _MediaPickerWidgetState createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  final _emptyState = MediaPicked(key: const Uuid().v4());
  late CoreLocalizations l10n;

  double get borderRadius => 8;

  @override
  Widget build(BuildContext context) {
    l10n = context.coreL10n;
    return ValueListenableBuilder<List<MediaPicked>>(
      valueListenable: widget.controller,
      builder: (context, medias, snapshot) {
        final canBeDelete = widget.canBeDeleteWhen?.call(medias) ?? true;
        final canAdd =
            widget.maxMedia == null || medias.length < widget.maxMedia!;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: widget.crossAxisCount,
          childAspectRatio: 1.0,
          padding: EdgeInsets.zero,
          mainAxisSpacing: 18.0,
          crossAxisSpacing: 20.0,
          children: [
            ...[...medias, if (canAdd) _emptyState].map<Widget>((media) {
              if (media.isEmpty) {
                return _buildEmptyState(medias);
              }
              return _buildMedia(media, canBeDelete);
            }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(List<MediaPicked> medias) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, right: 6),
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: _showMediaPickerActionDialog,
          borderRadius: BorderRadius.circular(borderRadius),
          child: DottedBorder(
            color: widget.foregroundColor ?? context.themeColor.primary,
            strokeWidth: 1,
            dashPattern: const [5, 3],
            strokeCap: StrokeCap.round,
            borderType: BorderType.RRect,
            radius: const Radius.circular(8),
            child: Container(
              alignment: Alignment.center,
              color: widget.backgroundColor ??
                  context.themeColor.primary.withAlpha((0.09 * 255).round()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 22,
                    color: widget.foregroundColor ?? context.themeColor.primary,
                  ),
                  if (widget.maxMedia != null)
                    Text(
                      '${(widget.maxMedia ?? 0) - medias.length}/${widget.maxMedia}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: widget.foregroundColor ??
                            context.themeColor.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedia(MediaPicked media, bool canBeDelete) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(media),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Builder(
                    builder: (context) {
                      if (media.isVideo) {
                        return FutureBuilder<Uint8List?>(
                          future: media.loadVideoThumbnail(),
                          builder: (context, snapshot) {
                            return Stack(
                              children: [
                                snapshot.hasData.let((it) {
                                  if (it) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: constraints.maxWidth - 6,
                                      height: constraints.maxHeight - 6,
                                    );
                                  }
                                  return Center(
                                    child: Container(
                                      width: constraints.maxWidth - 6,
                                      height: constraints.maxHeight - 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white38,
                                        borderRadius:
                                            BorderRadius.circular(borderRadius),
                                      ),
                                      child: const Loading(
                                        brightness: Brightness.light,
                                        radius: 12,
                                      ),
                                    ),
                                  );
                                }),
                                const Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 32,
                                  ),
                                ),
                                if (media.isLoading)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.circular(
                                        borderRadius,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Loading(
                                      brightness: Brightness.light,
                                      radius: 12,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      }
                      return SizedBox(
                        width: constraints.maxWidth - 6,
                        height: constraints.maxHeight - 6,
                        child: Stack(
                          children: [
                            Builder(
                              builder: (context) {
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
                              },
                            ),
                            if (media.isLoading)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(
                                    borderRadius,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Loading(
                                  brightness: Brightness.light,
                                  radius: 12,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (canBeDelete == true)
                Positioned(
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
                      child: const Icon(
                        Icons.close,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => _removeMedia(media),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

extension MediaPickerWidgetAction on _MediaPickerWidgetState {
  void clearLiveCachedImages() {
    imageCache.clearLiveImages();
  }

  void _removeMedia(MediaPicked media) {
    widget.controller.remove(media);
  }

  Future<void> _showMediaPickerActionDialog() async {
    if (widget.mediaType == MediaType.capture) {
      return _openCamera();
    }
    return showActionDialog(
      context,
      titleBottomBtn: l10n.cancel,
      title: _dialogTitle,
      subTitle: widget.pickDialogMessage ?? '',
      actions: {
        l10n.camera: _openCamera,
        l10n.gallery: _openGallery,
      },
    );
  }

  Future<void> _openGallery() async {
    try {
      final pickedFiles = await PickFileHelper()
          .pickFiles(
            type: widget.mediaType.fileType,
            dialogTitle: _dialogTitle,
            allowMultiple: widget.controller.allowMultiple,
          )
          .catchError(
            (error, stackTrace) => logUtils.eCatch(
              'PickFileHelper.pickFiles',
              error,
              stackTrace,
            ),
          );
      if (pickedFiles.isNotEmpty) {
        _onMediaPicked(pickedFiles);
      }
    } catch (error, stackTrace) {
      logUtils.eCatch(
        '_openGallery',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _openCamera() async {
    if (await PermissionService().requestPermission(
      Permission.camera,
      context,
    )) {
      final pickedFile = await PickFileHelper().takePicture().catchError(
            (error, stackTrace) => logUtils.eCatch<FilePicked?>(
              'PickFileHelper.takePicture',
              error,
              stackTrace,
            ),
          );

      if (pickedFile != null &&
          (pickedFile.path.isNotNullOrEmpty || pickedFile.bytes != null)) {
        clearLiveCachedImages();
        _onMediaPicked([pickedFile]);
      }
    }
  }

  void _onMediaPicked(List<FilePicked> filePicked) {
    final existedFiles = widget.controller.value;
    final currentIndex = existedFiles.isNotEmpty
        ? (existedFiles.reduce((value, element) {
                  return (element.index ?? 0) > (value.index ?? 0)
                      ? element
                      : value;
                }).index ??
                0) +
            1
        : 0;
    widget.controller.addAll(
      [
        ...filePicked
            .mapIndex(
          (e, i) => MediaPicked(
            key: const Uuid().v4(),
            mediaFile: e,
            mimetype: lookupMimeType(e.path ?? ''),
            index: currentIndex + i,
          ),
        )
            .let((it) {
          if (widget.maxMedia != null) {
            return it.take(widget.maxMedia! - widget.controller.value.length);
          }

          return it;
        }),
      ],
    );
    if (widget.autoUpload) {
      widget.controller.uploadUnstagedMedias();
    }
  }

  String get _dialogTitle {
    if (widget.pickDialogTitle.isNotNullOrEmpty) {
      return widget.pickDialogTitle!;
    }
    switch (widget.mediaType) {
      case MediaType.photo:
        return l10n.choosePhoto;
      case MediaType.capture:
        return l10n.camera;
      case MediaType.video:
        return l10n.chooseVideo;
      case MediaType.both:
        return l10n.choosePhotoOrVideo;
    }
  }
}

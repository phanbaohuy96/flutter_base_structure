import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/utils.dart';

part 'cloud_file.g.dart';

@JsonSerializable(explicitToJson: true)
class CloudFile {
  @JsonKey(name: 'id', fromJson: asOrNull)
  final String? id;
  @JsonKey(name: 'filename_disk', fromJson: asOrNull)
  final String? filenameDisk;
  @JsonKey(name: 'filename_download', fromJson: asOrNull)
  final String? filenameDownload;
  @JsonKey(name: 'url', fromJson: asOrNull)
  final String? url;
  @JsonKey(name: 'mime_type', fromJson: asOrNull)
  final String? mimeType;
  @JsonKey(name: 'filesize', fromJson: asOrNull)
  final double? fileSize; //bytes

  CloudFile({
    this.id,
    this.filenameDisk,
    this.filenameDownload,
    this.url,
    this.mimeType,
    this.fileSize,
  });

  factory CloudFile.fromJson(Map<String, dynamic> json) =>
      _$CloudFileFromJson(json);

  Map<String, dynamic> toJson() => _$CloudFileToJson(this);

  CloudFile copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? filenameDisk,
    ValueGetter<String?>? filenameDownload,
    ValueGetter<String?>? url,
    ValueGetter<String?>? mimeType,
    ValueGetter<double?>? fileSize,
  }) {
    return CloudFile(
      id: id != null ? id() : this.id,
      filenameDisk: filenameDisk != null ? filenameDisk() : this.filenameDisk,
      filenameDownload:
          filenameDownload != null ? filenameDownload() : this.filenameDownload,
      url: url != null ? url() : this.url,
      mimeType: mimeType != null ? mimeType() : this.mimeType,
      fileSize: fileSize != null ? fileSize() : this.fileSize,
    );
  }
}

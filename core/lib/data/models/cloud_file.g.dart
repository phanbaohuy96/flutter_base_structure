// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudFile _$CloudFileFromJson(Map<String, dynamic> json) => CloudFile(
      id: asOrNull(json['id']),
      filenameDisk: asOrNull(json['filename_disk']),
      filenameDownload: asOrNull(json['filename_download']),
      url: asOrNull(json['url']),
      mimeType: asOrNull(CloudFile._readMimeType(json, 'mime_type')),
      fileSize: asOrNull(json['filesize']),
    );

Map<String, dynamic> _$CloudFileToJson(CloudFile instance) => <String, dynamic>{
      'id': instance.id,
      'filename_disk': instance.filenameDisk,
      'filename_download': instance.filenameDownload,
      'url': instance.url,
      'mime_type': instance.mimeType,
      'filesize': instance.fileSize,
    };

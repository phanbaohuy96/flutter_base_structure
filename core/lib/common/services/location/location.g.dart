// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      type: $enumDecodeNullable(_$PositionTypeEnumMap, json['type'],
          unknownValue: PositionType.unknow),
      coordinates: asOrNull(json['coordinates']),
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'type': _$PositionTypeEnumMap[instance.type],
      'coordinates': instance.coordinates,
    };

const _$PositionTypeEnumMap = {
  PositionType.point: 'Point',
  PositionType.unknow: 'unknow',
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      lng: asOrNull(json['lng']),
      lat: asOrNull(json['lat']),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'lng': instance.lng,
      'lat': instance.lat,
    };

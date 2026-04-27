import 'package:fl_utils/fl_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

enum PositionType {
  @JsonValue('Point')
  point,
  unknow,
}

@JsonSerializable(explicitToJson: true)
class Position {
  @JsonKey(name: 'type', unknownEnumValue: PositionType.unknow)
  PositionType? type;
  @JsonKey(name: 'coordinates', fromJson: asOrNull)
  List<double>? coordinates;

  Position({this.type, this.coordinates});

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

  Map<String, dynamic> toJson() => _$PositionToJson(this);

  Location? get location {
    try {
      switch (type) {
        case PositionType.point:
          return Location(lng: coordinates?[0], lat: coordinates?[1]);
        default:
      }
    } catch (_) {}
    return null;
  }
}

@JsonSerializable(explicitToJson: true)
class Location {
  @JsonKey(name: 'lng', fromJson: asOrNull)
  final double? lng;
  @JsonKey(name: 'lat', fromJson: asOrNull)
  final double? lat;

  Location({this.lng, this.lat});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  bool get isValid => lat != null && lng != null;

  /// Return metter distance
  double? distanceFrom(Location? other) {
    if (!isValid || !(other?.isValid == true)) {
      return null;
    }
    return Geolocator.distanceBetween(lat!, lng!, other!.lat!, other.lng!);
  }
}

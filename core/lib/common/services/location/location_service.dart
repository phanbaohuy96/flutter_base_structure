import 'package:geolocator/geolocator.dart' as locator;

import '../../utils.dart';
import 'location.dart';

part 'location_service.impl.dart';

abstract class LocationService {
  Stream<locator.ServiceStatus> get serviceStatusStream;

  Future<Location?> getLastKnownLocation();
}

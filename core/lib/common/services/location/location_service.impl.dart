part of 'location_service.dart';

class LocationServiceImpl implements LocationService {
  @override
  Future<Location?> getLastKnownLocation() async {
    final position = await _determinePosition();

    if (position == null) {
      return null;
    }
    return Location(
      lat: position.latitude,
      lng: position.longitude,
    );
  }

  Future<locator.Position?> _determinePosition() async {
    bool serviceEnabled;
    locator.LocationPermission permission;

    serviceEnabled = await locator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logUtils.d('Location services are disabled.');
      return null;
    }
    permission = await locator.Geolocator.checkPermission();
    if (permission == locator.LocationPermission.denied) {
      permission = await locator.Geolocator.requestPermission();
      if (permission == locator.LocationPermission.denied) {
        logUtils.d('Location permissions are denied');
        return null;
      }
    }

    if (permission == locator.LocationPermission.deniedForever) {
      logUtils.d(
        '''Location permissions are permanently denied, we cannot request permissions.''',
      );
      return null;
    }

    final currentLocation = await locator.Geolocator.getCurrentPosition();

    return currentLocation;
  }

  @override
  Stream<locator.ServiceStatus> get serviceStatusStream =>
      locator.Geolocator.getServiceStatusStream();
}

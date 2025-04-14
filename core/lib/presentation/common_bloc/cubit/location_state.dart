part of 'location_cubit.dart';

abstract class LocationState {
  final Location? location;

  LocationState(this.location);
}

class LocationInitial extends LocationState {
  LocationInitial({
    Location? location,
  }) : super(location);
}

class LocationRefreshing extends LocationState {
  LocationRefreshing({
    Location? location,
  }) : super(location);
}

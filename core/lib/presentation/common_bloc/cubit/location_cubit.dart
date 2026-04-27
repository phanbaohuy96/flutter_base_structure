import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as locator;
import 'package:injectable/injectable.dart';

import '../../../core.dart';

part 'location_state.dart';

@injectable
class LocationCubit extends Cubit<LocationState> {
  final LocationService _locationService;

  StreamSubscription? _serviceStatusStream;

  LocationCubit(this._locationService) : super(LocationInitial()) {
    if (!kIsWeb) {
      _serviceStatusStream = _locationService.serviceStatusStream.listen((
        event,
      ) {
        if (event == locator.ServiceStatus.enabled) {
          refreshLocation();
        }
      });
    }
  }

  Stream<Location?> refreshLocation() async* {
    if (state is LocationRefreshing) {
      yield state.location;
      return;
    }

    final location = await _locationService.getLastKnownLocation();
    if (location != null) {
      emit(LocationInitial(location: location));

      yield location;
    } else {
      yield state.location;
    }
  }

  Future<Location?> getLastKnownLocation() async {
    return refreshLocation().first;
  }

  @override
  Future<void> close() {
    _serviceStatusStream?.cancel();
    return super.close();
  }
}

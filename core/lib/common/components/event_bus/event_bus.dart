import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';

abstract class BusEvent {}

@lazySingleton
class EventBusManager {
  final EventBus eventBus;

  EventBusManager(this.eventBus);

  Stream<T> on<T extends BusEvent>() {
    return eventBus.on<T>();
  }

  void fire(BusEvent event) {
    eventBus.fire(event);
  }
}

@module
abstract class EventBusModule {
  @lazySingleton
  EventBus get eventBus => EventBus();
}

import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';

abstract class BusEvent {}

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
  @injectable
  EventBus get eventBus => EventBus();

  @singleton
  EventBusManager get manager => EventBusManager(eventBus);
}

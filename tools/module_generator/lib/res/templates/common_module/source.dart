import 'bloc/bloc.dart';
import 'bloc/event.dart';
import 'bloc/state.dart';
import 'coordinator.dart';
import 'module.dart';
import 'route.dart';
import 'views/action.dart';
import 'views/screen.dart';

final commonModuleRes = {
  'bloc': {
    'bloc': commonModuleBloc,
    'state': commonModuleState,
    'event': commonModuleEvent,
  },
  'views': {'screen': commonModuleScreen, 'action': commonModuleAction},
  'module': commonModule,
  'route': commonModuleRoute,
  'coordinator': commonModuleCoordinator,
};

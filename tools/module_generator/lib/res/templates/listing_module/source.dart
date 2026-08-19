import 'bloc/bloc.dart';
import 'bloc/event.dart';
import 'bloc/state.dart';
import 'coordinator.dart';
import 'module.dart';
import 'route.dart';
import 'views/action.dart';
import 'views/screen.dart';

final listingModuleRes = {
  'bloc': {
    'bloc': listingModuleBloc,
    'state': listingModuleState,
    'event': listingModuleEvent,
  },
  'views': {'screen': listingModuleScreen, 'action': listingModuleAction},
  'module': listingModule,
  'route': listingModuleRoute,
  'coordinator': listingModuleCoordinator,
};

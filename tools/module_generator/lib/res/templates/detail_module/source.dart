import 'bloc/bloc.dart';
import 'bloc/event.dart';
import 'bloc/state.dart';
import 'coordinator.dart';
import 'module.dart';
import 'route.dart';
import 'views/action.dart';
import 'views/screen.dart';

final detailModuleRes = {
  'bloc': {
    'bloc': detailModuleBloc,
    'state': detailModuleState,
    'event': detailModuleEvent,
  },
  'views': {'screen': detailModuleScreen, 'action': detailModuleAction},
  'module': detailModule,
  'route': detailModuleRoute,
  'coordinator': detailModuleCoordinator,
};

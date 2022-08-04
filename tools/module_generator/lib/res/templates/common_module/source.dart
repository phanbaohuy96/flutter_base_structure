import 'bloc/bloc.dart';
import 'bloc/event.dart';
import 'bloc/state.dart';
import 'interactor/interactor.dart';
import 'interactor/interactor.impl.dart';
import 'module.dart';
import 'repository/repository.dart';
import 'repository/repository.impl.dart';
import 'route.dart';
import 'views/action.dart';
import 'views/screen.dart';

final commonModuleRes = {
  'bloc': {
    'bloc': commonModuleBloc,
    'state': commonModuleState,
    'event': commonModuleEvent,
  },
  'interactor': {
    'interactor': commonModuleInteractor,
    'interactor.impl': commonModuleInteractorImpl,
  },
  'repository': {
    'repository': commonModuleRepository,
    'repository.impl': commonModuleRepositoryImpl,
  },
  'views': {
    'screen': commonModuleScreen,
    'action': commonModuleAction,
  },
  'module': commonModule,
  'route': commonModuleRoute,
};

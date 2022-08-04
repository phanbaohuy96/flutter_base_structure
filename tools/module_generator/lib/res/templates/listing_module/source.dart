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

final listingModuleRes = {
  'bloc': {
    'bloc': listingModuleBloc,
    'state': listingModuleState,
    'event': listingModuleEvent,
  },
  'interactor': {
    'interactor': listingModuleInteractor,
    'interactor.impl': listingModuleInteractorImpl,
  },
  'repository': {
    'repository': listingModuleRepository,
    'repository.impl': listingModuleRepositoryImpl,
  },
  'views': {
    'screen': listingModuleScreen,
    'action': listingModuleAction,
  },
  'module': listingModule,
  'route': listingModuleRoute,
};

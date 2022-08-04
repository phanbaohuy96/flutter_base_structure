const commonModuleBloc = '''import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../base/base.dart';
import '../interactor/%%MODULE_NAME%%_interactor.dart';
import '../repository/%%MODULE_NAME%%_repository.dart';

part '%%MODULE_NAME%%_event.dart';
part '%%MODULE_NAME%%_state.dart';

class %%CLASS_NAME%%Bloc extends AppBlocBase<%%CLASS_NAME%%Event, %%CLASS_NAME%%State> {
  late final _interactor = %%CLASS_NAME%%InteractorImpl(
    %%CLASS_NAME%%RepositoryImpl(),
  );
  
  %%CLASS_NAME%%Bloc() : super(%%CLASS_NAME%%Initial(viewModel: const _ViewModel())) {
    on<%%CLASS_NAME%%Event>(_on%%CLASS_NAME%%Event);
  }

  Future<void> _on%%CLASS_NAME%%Event(
    %%CLASS_NAME%%Event event,
    Emitter<%%CLASS_NAME%%State> emit,
  ) async {}
}''';

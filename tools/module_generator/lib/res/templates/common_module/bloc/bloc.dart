import '../../../../common/definitions.dart';

const commonModuleBloc = '''import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../base/base.dart';
import '../interactor/${moduleNameKey}_interactor.dart';
import '../repository/${moduleNameKey}_repository.dart';

part '${moduleNameKey}_event.dart';
part '${moduleNameKey}_state.dart';

class ${classNameKey}Bloc extends AppBlocBase<${classNameKey}Event, ${classNameKey}State> {
  late final _interactor = ${classNameKey}InteractorImpl(
    ${classNameKey}RepositoryImpl(),
  );
  
  ${classNameKey}Bloc() : super(${classNameKey}Initial(viewModel: const _ViewModel())) {
    on<${classNameKey}Event>(_on${classNameKey}Event);
  }

  Future<void> _on${classNameKey}Event(
    ${classNameKey}Event event,
    Emitter<${classNameKey}State> emit,
  ) async {}
}''';

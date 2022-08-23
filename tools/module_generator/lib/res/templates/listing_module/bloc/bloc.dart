import '../../../../common/definitions.dart';

const listingModuleBloc = '''import 'dart:async';

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
    on<GetDataEvent>(_onGetDataEvent);
    on<LoadMoreDataEvent>(_onLoadMoreDataEvent);
  }

  Future<void> _onGetDataEvent(
    GetDataEvent event,
    Emitter<${classNameKey}State> emit,
  ) async {
    final data = await _interactor.getData();
    emit(
      state.copyWith(
        viewModel: state.viewModel.copyWith(
          data: data,
          canLoadMore: _interactor.pagination.canNext,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreDataEvent(
    LoadMoreDataEvent event,
    Emitter<${classNameKey}State> emit,
  ) async {
    final moreData = await _interactor.loadMoreData();
    emit(
      state.copyWith(
        viewModel: state.viewModel.copyWith(
          data: [...state.viewModel.data, ...moreData],
          canLoadMore: _interactor.pagination.canNext,
        ),
      ),
    );
  }
}
''';

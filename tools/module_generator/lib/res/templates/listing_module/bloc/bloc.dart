const listingModuleBloc = '''import 'dart:async';

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
    on<GetDataEvent>(_onGetDataEvent);
    on<LoadMoreDataEvent>(_onLoadMoreDataEvent);
  }

  Future<void> _onGetDataEvent(
    GetDataEvent event,
    Emitter<%%CLASS_NAME%%State> emit,
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
    Emitter<%%CLASS_NAME%%State> emit,
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

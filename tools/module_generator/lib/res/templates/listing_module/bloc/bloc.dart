import '../../../../common/definitions.dart';

const listingModuleBloc =
    '''import 'dart:async';

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '$modelImportKey';
import '$modelFilterImportKey';
import '${libImportKey}domain/usecases/$moduleNameKey/${moduleNameKey}_usecase.dart';

part '${moduleNameKey}_bloc.freezed.dart';
part '${moduleNameKey}_event.dart';
part '${moduleNameKey}_state.dart';

@Injectable()
class ${classNameKey}Bloc
    extends CoreBlocBase<${classNameKey}Event, ${classNameKey}State> {
  ${classNameKey}Bloc(
    @factoryParam ${modelNameKey}Filter? filter,
    this._usecase,
  ) : super(${classNameKey}Initial(data: _StateData(filter: filter))) {
    on<Get${modelNameKey}sEvent>(_onGet${modelNameKey}s);
    on<LoadMore${modelNameKey}sEvent>(_onLoadMore${modelNameKey}s);
  }

  final ${classNameKey}Usecase _usecase;

  Future<void> _onGet${modelNameKey}s(
    Get${modelNameKey}sEvent event,
    Emitter<${classNameKey}State> emit,
  ) async {
    final filter = event.filter ?? state.filter;
    final data = await _usecase.fetchData(filter: filter);
    emit(
      state.copyWith<${classNameKey}Loaded>(
        data: state.data.copyWith(
          items: data,
          filter: filter,
          canLoadMore: _usecase.canNext,
        ),
      ),
    );
  }

  Future<void> _onLoadMore${modelNameKey}s(
    LoadMore${modelNameKey}sEvent event,
    Emitter<${classNameKey}State> emit,
  ) async {
    final moreData = await _usecase.loadMoreData(filter: state.filter);
    emit(
      state.copyWith<${classNameKey}Loaded>(
        data: state.data.copyWith(
          items: [...state.items, ...moreData],
          canLoadMore: _usecase.canNext,
        ),
      ),
    );
  }
}
''';

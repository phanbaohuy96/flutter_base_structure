import '../../../../common/definations.dart';

const listingModuleBloc = '''import 'dart:async';

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart' hide Order;

import '$importPartKey../domain/usecases/$moduleNameKey/${moduleNameKey}_usecase.dart';
import '${importPartKey}base/base.dart';

part '${moduleNameKey}_bloc.freezed.dart';
part '${moduleNameKey}_event.dart';
part '${moduleNameKey}_state.dart';

@Injectable()
class ${classNameKey}Bloc extends AppBlocBase<${classNameKey}Event, ${classNameKey}State> {
  final ${classNameKey}Usecase _usecase;
  
  ${classNameKey}Bloc(this._usecase) : 
    super(${classNameKey}Initial(data: const _StateData())) {
    on<Get${modelNameKey}sEvent>(_onGet${modelNameKey}sEvent);
    on<LoadMore${modelNameKey}sEvent>(_onLoadMore${modelNameKey}sEvent);
  }

  Future<void> _onGet${modelNameKey}sEvent(
    Get${modelNameKey}sEvent event,
    Emitter<${classNameKey}State> emit,
  ) async {
    final data = await _usecase.fetchData();
    emit(
      state.copyWith<${classNameKey}Initial>(
        data: state.data.copyWith(
          items: data,
          canLoadMore: _usecase.canNext,
        ),
      ),
    );
  }

  Future<void> _onLoadMore${modelNameKey}sEvent(
    LoadMore${modelNameKey}sEvent event,
    Emitter<${classNameKey}State> emit,
  ) async {
    final moreData = await _usecase.loadMoreData();
    emit(
      state.copyWith<${classNameKey}Initial>(
        data: state.data.copyWith(
          items: [...state.items, ...moreData],
          canLoadMore: _usecase.canNext,
        ),
      ),
    );
  }
}
''';

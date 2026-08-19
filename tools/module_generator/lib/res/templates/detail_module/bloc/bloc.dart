import '../../../../common/definitions.dart';

const detailModuleBloc =
    '''import 'dart:async';

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '$modelImportKey';
import '${libImportKey}domain/usecases/$moduleNameKey/${moduleNameKey}_usecase.dart';

part '${moduleNameKey}_bloc.freezed.dart';
part '${moduleNameKey}_event.dart';
part '${moduleNameKey}_state.dart';

@Injectable()
class ${classNameKey}Bloc
    extends CoreBlocBase<${classNameKey}Event, ${classNameKey}State> {
  ${classNameKey}Bloc(@factoryParam $modelNameKey? detail, this._usecase)
    : super(${classNameKey}Initial(data: _StateData(detail: detail))) {
    on<Get${classNameKey}Event>(_onGet$classNameKey);
  }

  final ${classNameKey}Usecase _usecase;

  Future<void> _onGet$classNameKey(
    Get${classNameKey}Event event,
    Emitter<${classNameKey}State> emit,
  ) async {
    final detail = await _usecase.get${classNameKey}ById(event.id);
    emit(
      state.copyWith<${classNameKey}Loaded>(
        data: state.data.copyWith(detail: detail),
      ),
    );
  }
}
''';

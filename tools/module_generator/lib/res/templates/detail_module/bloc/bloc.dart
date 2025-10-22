import '../../../../common/definitions.dart';

const detailModuleBloc = '''import 'dart:async';

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
  
  ${classNameKey}Bloc(
    @factoryParam $modelNameKey? detail, 
    this._usecase,
  ) : super(${classNameKey}Initial(data: _StateData(detail: detail))) {
    on<Get${classNameKey}Event>(_onGet${classNameKey}Event);
  }

  Future<void> _onGet${classNameKey}Event(
    Get${classNameKey}Event event,
    Emitter<${classNameKey}State> emit,
  ) async {
    final detail = await _usecase.get${classNameKey}ById(event.id);
    emit(
      state.copyWith<${classNameKey}Initial>(
        data: state.data.copyWith(
          detail: detail,
        ),
      ),
    );
  }
}
''';

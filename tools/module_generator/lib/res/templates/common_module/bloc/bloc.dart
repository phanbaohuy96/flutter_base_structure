import '../../../../common/definitions.dart';

const commonModuleBloc = '''import 'dart:async';

import 'package:bloc/bloc.dart';
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
    on<${classNameKey}Event>(_on${classNameKey}Event);
  }

  Future<void> _on${classNameKey}Event(
    ${classNameKey}Event event,
    Emitter<${classNameKey}State> emit,
  ) async {}
}''';

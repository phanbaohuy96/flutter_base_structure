import '../../../../common/definitions.dart';

const detailUsecase =
    '''import 'dart:async';

import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

part '${moduleNameKey}_usecase.impl.dart';

abstract class ${classNameKey}Usecase {
  Future<$modelNameKey?> getDetailById(String id);
}
''';

const detailUsecaseImpl =
    '''part of '${moduleNameKey}_usecase.dart';

@Injectable(as: ${classNameKey}Usecase)
class ${classNameKey}UsecaseImpl extends ${classNameKey}Usecase {
  ${classNameKey}UsecaseImpl(
    this._repository,
  );

  final ${classNameKey}Repository _repository;

  @override
  Future<$modelNameKey?> getDetailById(String id) async {
    return _repository.get$modelNameKey(id);
  }
}''';

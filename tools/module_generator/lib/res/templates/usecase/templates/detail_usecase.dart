import '../../../../common/definitions.dart';

const detailUsecase =
    '''import 'dart:async';

import 'package:injectable/injectable.dart';

import '$modelImportKey';

part '${moduleNameKey}_usecase.impl.dart';

abstract class ${classNameKey}Usecase {
  Future<$modelNameKey?> get${classNameKey}ById(String id);
}
''';

const detailUsecaseImpl =
    '''part of '${moduleNameKey}_usecase.dart';

@Injectable(as: ${classNameKey}Usecase)
class ${classNameKey}UsecaseImpl extends ${classNameKey}Usecase {
  @override
  Future<$modelNameKey?> get${classNameKey}ById(String id) async {
    // TODO(template): inject your repository (see `make run_module_generator`
    // option 4) and map its DTO onto `$modelNameKey` here.
    return null;
  }
}
''';

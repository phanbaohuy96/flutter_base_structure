import '../../../../common/definitions.dart';

const usecase =
    '''import 'dart:async';

import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

part '${moduleNameKey}_usecase.impl.dart';

abstract class ${classNameKey}Usecase {
  Future<dynamic> sampleFunc();
}
''';

const usecaseImpl =
    '''part of '${moduleNameKey}_usecase.dart';

@Injectable(as: ${classNameKey}Usecase)
class ${classNameKey}UsecaseImpl extends ${classNameKey}Usecase {
  ${classNameKey}UsecaseImpl(this._repository);

  final ${classNameKey}Repository _repository;

  @override
  Future<dynamic> sampleFunc() async {
    // TODO: translate the repository result into a typed domain outcome
    // (e.g. a sealed Result class) so callers can switch on intent rather
    // than null-check or catch.
    return _repository.sampleFunc();
  }
}''';

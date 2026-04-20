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
  @override
  Future<dynamic> sampleFunc() async {
    return Future.value();
  }
}''';

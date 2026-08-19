import '../../../common/definitions.dart';

const repository =
    '''import 'dart:async';

import 'package:core/data/data_source/remote/data_repository.dart';
import 'package:injectable/injectable.dart';

part '${moduleNameKey}_repository.impl.dart';

abstract class ${classNameKey}Repository {
  Future<dynamic> sampleFunc();
}
''';

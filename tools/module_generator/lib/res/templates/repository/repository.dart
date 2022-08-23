import '../../../common/definitions.dart';

const repository = '''import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../../data_repository.dart';

part '${moduleNameKey}_repository.impl.dart';

abstract class ${classNameKey}Repository {
  Future<dynamic> sampleFunc();
}
''';

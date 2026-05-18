import '../../../common/definations.dart';

const repository = '''import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:core/data/data_source/remote/data_repository.dart';

part '${moduleNameKey}_repository.impl.dart';

abstract class ${classNameKey}Repository {
  Future<dynamic> sampleFunc();
}
''';

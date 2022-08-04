const repository = '''import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../../data_repository.dart';

part '%%MODULE_NAME%%_repository.impl.dart';

abstract class %%CLASS_NAME%%Repository {
  Future<dynamic> sampleFunc();
}
''';

import '../../../../common/definitions.dart';

const usecase =
    '''import 'dart:async';

import 'package:injectable/injectable.dart';

import '$modelImportKey';

part '${moduleNameKey}_usecase.impl.dart';

/// Domain entry point for the $classNameKey screen.
///
/// Keep this narrowly scoped to what $classNameKey needs — a use case that
/// collects unrelated workflows behind one facade is harder to test and
/// forces every caller to depend on everything.
abstract class ${classNameKey}Usecase {
  Future<$modelNameKey?> load();
}
''';

const usecaseImpl =
    '''part of '${moduleNameKey}_usecase.dart';

@Injectable(as: ${classNameKey}Usecase)
class ${classNameKey}UsecaseImpl extends ${classNameKey}Usecase {
  @override
  Future<$modelNameKey?> load() async {
    // TODO(template): inject your repository (see `make run_module_generator`
    // option 4) and translate its result into a domain outcome here, so
    // callers switch on intent rather than null-checking transport types.
    return null;
  }
}
''';

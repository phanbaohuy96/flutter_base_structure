import '../../../../common/definitions.dart';

const listingModuleRepository = '''part '${moduleNameKey}_repository.impl.dart';

abstract class ${classNameKey}Repository {
  //TODO: Update to your model
  Future<List<Model>> getData(
    int offset,
    int limit,
  );
}''';

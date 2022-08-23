import '../../../../common/definitions.dart';

const listingModuleRepositoryImpl =
    '''part of '${moduleNameKey}_repository.dart';

class ${classNameKey}RepositoryImpl extends ${classNameKey}Repository {
  @override
  //TODO: Update to your model
  Future<List<Model>> getData(
    int offset,
    int limit,
  ) {
    return Future.value(<Model>[]);
  }
}''';

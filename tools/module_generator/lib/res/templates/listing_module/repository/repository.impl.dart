const listingModuleRepositoryImpl =
    '''part of '%%MODULE_NAME%%_repository.dart';

class %%CLASS_NAME%%RepositoryImpl extends %%CLASS_NAME%%Repository {
  @override
  //TODO: Update to your model
  Future<List<Model>> getData(
    int offset,
    int limit,
  ) {
    return Future.value(<Model>[]);
  }
}''';

import '../../../../common/definitions.dart';

const listingModuleInteractor =
    '''import '../../../../../../domain/entities/pagination.entity.dart';
import '../repository/${moduleNameKey}_repository.dart';

part '${moduleNameKey}_interactor.impl.dart';

abstract class ${classNameKey}Interactor {
  Pagination get pagination;

  //TODO: Update to your model
  Future<List<Model>> getData();

  //TODO: Update to your model
  Future<List<Model>> loadMoreData();
}
''';

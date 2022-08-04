const listingModuleInteractor =
    '''import '../../../../../../domain/entities/pagination.entity.dart';
import '../repository/%%MODULE_NAME%%_repository.dart';

part '%%MODULE_NAME%%_interactor.impl.dart';

abstract class %%CLASS_NAME%%Interactor {
  Pagination get pagination;

  //TODO: Update to your model
  Future<List<Model>> getData();

  //TODO: Update to your model
  Future<List<Model>> loadMoreData();
}
''';

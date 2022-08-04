const listingModuleInteractorImpl =
    '''part of '%%MODULE_NAME%%_interactor.dart';

class %%CLASS_NAME%%InteractorImpl extends %%CLASS_NAME%%Interactor {
  final %%CLASS_NAME%%Repository _repository;

  %%CLASS_NAME%%InteractorImpl(this._repository);

  var _pagination = Pagination();

  @override
  Pagination get pagination => _pagination;

  @override
  //TODO: Update to your model
  Future<List<Model>> getData() async {
    _pagination = Pagination();
    return _getData();
  }

  @override
  //TODO: Update to your model
  Future<List<Model>> loadMoreData() {
    return _getData();
  }

  //TODO: Update to your model
  Future<List<Model>> _getData() async {
    final response = await _repository.getData(
      _pagination.total,
      _pagination.size,
    );
    _pagination = Pagination(
      offset: _pagination.total,
      total: _pagination.total + response.length,
    );
    return response;
  }
}
''';

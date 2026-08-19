import '../../../../common/definitions.dart';

/// Template for the paginated listing usecase.
const listingUsecase =
    '''import 'dart:async';

import 'package:core/domain/use_case/listing_use_case.dart';
import 'package:injectable/injectable.dart';

import '$modelImportKey';
import '$modelFilterImportKey';

part '${moduleNameKey}_usecase.impl.dart';

abstract class ${classNameKey}Usecase {
  /// Whether the last fetch returned a full page, i.e. another page may exist.
  bool get canNext;

  Future<List<$modelNameKey>> fetchData({
    ${modelNameKey}Filter filter = const ${modelNameKey}Filter(),
  });

  Future<List<$modelNameKey>> loadMoreData({
    ${modelNameKey}Filter filter = const ${modelNameKey}Filter(),
  });
}
''';

const listingUsecaseImpl =
    '''part of '${moduleNameKey}_usecase.dart';

@Injectable(as: ${classNameKey}Usecase)
class ${classNameKey}UsecaseImpl extends ${classNameKey}Usecase {
  late final _listingUsecase =
      ListingUseCase<$modelNameKey, ${modelNameKey}Filter>(_fetchPage);

  @override
  bool get canNext => _listingUsecase.canNext;

  @override
  Future<List<$modelNameKey>> fetchData({
    ${modelNameKey}Filter filter = const ${modelNameKey}Filter(),
  }) {
    return _listingUsecase.getData(filter);
  }

  @override
  Future<List<$modelNameKey>> loadMoreData({
    ${modelNameKey}Filter filter = const ${modelNameKey}Filter(),
  }) {
    return _listingUsecase.loadMoreData(filter);
  }

  Future<List<$modelNameKey>> _fetchPage(
    int offset,
    int limit,
    int page, [
    ${modelNameKey}Filter? filter,
  ]) async {
    // TODO(template): inject your repository (see `make run_module_generator`
    // option 4) and call it here, forwarding `filter.query`, `limit` and
    // `page`, then map the DTOs onto `$modelNameKey`.
    return const [];
  }
}
''';

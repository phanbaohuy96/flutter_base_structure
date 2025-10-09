import '../../../../common/definitions.dart';

/// Temlate for common usecase
const listingUsecase = '''import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:core/domain/use_case/listing_use_case.dart';
import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import '../../entities/filter/${moduleNameKey}_filter.entity.dart';

part '${moduleNameKey}_usecase.impl.dart';

abstract class ${classNameKey}Usecase {
  bool get canNext;

  Future<List<$modelNameKey>> fetchData({
    ${modelNameKey}Filter filter = const ${modelNameKey}Filter(),
  });

  Future<List<$modelNameKey>> loadMoreData({
    ${modelNameKey}Filter filter = const ${modelNameKey}Filter(),
  });
}
''';

const listingUsecaseImpl = '''part of '${moduleNameKey}_usecase.dart';

@Injectable(as: ${classNameKey}Usecase)
class ${classNameKey}UsecaseImpl extends ${classNameKey}Usecase {
  ${classNameKey}UsecaseImpl(
    this._repository,
  );

  final ${classNameKey}Repository _repository;

  late final _listingUsecase =
      ListingUseCase<$modelNameKey, ${modelNameKey}Filter>(
    (offset, limit, page, [filter]) => _repository.getActivities(
      /// TODO: Integrate with your filter and pagination
      /// Example:
      /// 'filters': filter?.filter,
      /// 'limit': limit,
      /// 'page': page,
    ).then(
      (value) => [...?value.data],
    ),
  );

  @override
  bool get canNext => _listingUsecase.pagination.canNext;

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
}''';

import '../../../common/definitions.dart';

const filter =
    '''import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '$moduleNameKey.entity.freezed.dart';

/// Query parameters for a `$classNameKey` listing.
///
/// Kept separate from the entity so listing blocs can pass search/sort state
/// through `ListingUseCase<$classNameKey, ${classNameKey}Filter>` without
/// widening the entity itself.
@freezed
abstract class ${classNameKey}Filter with _\$${classNameKey}Filter {
  const factory ${classNameKey}Filter({String? keyword}) =
      _${classNameKey}Filter;

  /// Rebuilds the filter from a deep link's query parameters.
  ///
  /// The inverse of [query]; keep the two in step so a filtered listing can
  /// round-trip through a URL.
  factory ${classNameKey}Filter.fromQuery(
    Map<String, dynamic> queryParameters,
  ) => ${classNameKey}Filter(keyword: asOrNull(queryParameters['keyword']));

  const ${classNameKey}Filter._();

  /// The filter as API query parameters.
  // TODO(template): map the filter fields onto your API's parameter names.
  Map<String, dynamic> get query => {
    if (keyword != null) 'keyword': keyword,
  };
}
''';

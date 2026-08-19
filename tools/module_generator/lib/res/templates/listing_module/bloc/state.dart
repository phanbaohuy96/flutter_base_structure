import '../../../../common/definitions.dart';

const listingModuleState =
    '''// ignore_for_file: unused_element, unused_element_parameter
part of '${moduleNameKey}_bloc.dart';

@freezed
abstract class _StateData with _\$StateData {
  const factory _StateData({
    @Default(<$modelNameKey>[]) final List<$modelNameKey> items,
    @Default(false) final bool canLoadMore,
    final ${modelNameKey}Filter? filter,
  }) = __StateData;
}

abstract class ${classNameKey}State {
  ${classNameKey}State(this.data);

  final _StateData data;

  T copyWith<T extends ${classNameKey}State>({_StateData? data}) =>
      resolveState<T, ${classNameKey}State, _StateData>(
        _factories,
        fallbackType: runtimeType,
        data: data ?? this.data,
      );

  List<$modelNameKey> get items => data.items;
  bool get canLoadMore => data.canLoadMore;

  /// The active filter, defaulted so callers never have to null-check it.
  ${modelNameKey}Filter get filter =>
      data.filter ?? const ${modelNameKey}Filter();
}

class ${classNameKey}Initial extends ${classNameKey}State {
  ${classNameKey}Initial({_StateData data = const _StateData()}) : super(data);
}

class ${classNameKey}Loaded extends ${classNameKey}State {
  ${classNameKey}Loaded({_StateData data = const _StateData()}) : super(data);
}

final _factories = <Type, ${classNameKey}State Function(_StateData)>{
  ${classNameKey}Initial: (data) => ${classNameKey}Initial(data: data),
  ${classNameKey}Loaded: (data) => ${classNameKey}Loaded(data: data),
};
''';

import '../../../../common/definitions.dart';

const listingModuleState =
    '''// ignore_for_file: unused_element
part of '${moduleNameKey}_bloc.dart';

@freezed 
sealed class _StateData with _\$StateData {
  const factory _StateData({
    @Default([]) final List<$modelNameKey> items,
    @Default(false) final bool canLoadMore,
  }) = __StateData;
}

abstract class ${classNameKey}State {
  final _StateData data;

  ${classNameKey}State(this.data);

  T copyWith<T extends ${classNameKey}State>({
    _StateData? data,
  }) =>
      resolveState<${classNameKey}State, _StateData>(
        _factories,
        requested: T == ${classNameKey}State ? runtimeType : T,
        data: data ?? this.data,
      ) as T;

  List<$modelNameKey> get items => data.items;
  bool get canLoadMore => data.canLoadMore;
}

class ${classNameKey}Initial extends ${classNameKey}State {
  ${classNameKey}Initial({
    required _StateData data,
  }) : super(data);
}

final _factories = <Type, ${classNameKey}State Function(_StateData)>{
  ${classNameKey}Initial: (data) => ${classNameKey}Initial(
        data: data,
      ),
};''';

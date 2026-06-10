import '../../../../common/definitions.dart';

const detailModuleState =
    '''// ignore_for_file: unused_element
part of '${moduleNameKey}_bloc.dart';

@freezed 
sealed class _StateData with _\$StateData {
  const factory _StateData({
    final $modelNameKey? detail,
  }) = __StateData;
}


abstract class ${classNameKey}State {
  final _StateData data;

  ${classNameKey}State(this.data);

  T copyWith<T extends ${classNameKey}State>({
    _StateData? data,
  }) =>
      resolveState<T, ${classNameKey}State, _StateData>(
        _factories,
        fallbackType: runtimeType,
        data: data ?? this.data,
      );

  $modelNameKey? get detail => data.detail;
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

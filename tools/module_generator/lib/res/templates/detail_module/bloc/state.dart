import '../../../../common/definitions.dart';

const detailModuleState = '''// ignore_for_file: unused_element
part of '${moduleNameKey}_bloc.dart';

@freezed
class _StateData with _\$StateData {
  const factory _StateData({
    final $modelNameKey? detail,
  }) = __StateData;
}


abstract class ${classNameKey}State {
  final _StateData data;

  ${classNameKey}State(this.data);

  T copyWith<T extends ${classNameKey}State>({
    _StateData? data,
  }) {
    return _factories[T == ${classNameKey}State ? runtimeType : T]!(
      data ?? this.data,
    );
  }

  $modelNameKey? get detail => data.detail;
}

class ${classNameKey}Initial extends ${classNameKey}State {
  ${classNameKey}Initial({
    required _StateData data,
  }) : super(data);
}

final _factories = <
    Type,
    Function(
  _StateData data,
)>{
  ${classNameKey}Initial: (data) => ${classNameKey}Initial(
        data: data,
      ),
};''';

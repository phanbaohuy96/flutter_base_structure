import '../../../../common/definitions.dart';

const listingModuleState = '''part of '${moduleNameKey}_bloc.dart';

class _ViewModel {
  //TODO: Update to your model
  final List<Model> data;
  final bool? canLoadMore;

  const _ViewModel({
    this.canLoadMore,
    this.data = const [],
  });

  _ViewModel copyWith({
    //TODO: Update to your model
    List<Model>? data,
    bool? canLoadMore,
  }) {
    return _ViewModel(
      data: data ?? this.data,
      canLoadMore: canLoadMore ?? this.canLoadMore,
    );
  }
}

abstract class ${classNameKey}State {
  final _ViewModel viewModel;

  ${classNameKey}State(this.viewModel);

  T copyWith<T extends ${classNameKey}State>({
    _ViewModel? viewModel,
  }) {
    return _factories[T == ${classNameKey}State ? runtimeType : T]!(
      viewModel ?? this.viewModel,
    );
  }
}

class ${classNameKey}Initial extends ${classNameKey}State {
  ${classNameKey}Initial({
    _ViewModel viewModel = const _ViewModel(),
  }) : super(viewModel);
}

final _factories = <
    Type,
    Function(
  _ViewModel viewModel,
)>{
  ${classNameKey}Initial: (viewModel) => ${classNameKey}Initial(
        viewModel: viewModel,
      ),
};''';

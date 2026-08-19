import '../../../../common/definitions.dart';

const detailModuleAction =
    '''part of '${moduleNameKey}_screen.dart';

extension ${classNameKey}Action on _${classNameKey}ScreenState {
  void _blocListener(BuildContext context, ${classNameKey}State state) {
    hideLoading();
  }

  void onRefresh() {
    final id = widget.args?.id ?? widget.args?.initial?.id;
    if (id == null) {
      hideLoading();
      return;
    }
    bloc.add(Get${classNameKey}Event(id));
  }
}
''';

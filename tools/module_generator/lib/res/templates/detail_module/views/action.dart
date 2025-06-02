import '../../../../common/definations.dart';

const detailModuleAction = '''part of '${moduleNameKey}_screen.dart';

extension ${classNameKey}Action on _${classNameKey}ScreenState {
  void _blocListener(BuildContext context, ${classNameKey}State state) {
    hideLoading();
  }

  void onRefresh() {
    (widget.args?.id ?? widget.args?.initial?.id)?.let((id) {
      bloc.add(Get${classNameKey}Event(id));
    });
  }
}
''';

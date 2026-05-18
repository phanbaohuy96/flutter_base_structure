import '../../../../common/definations.dart';

const listingModuleAction = '''part of '${moduleNameKey}_screen.dart';

extension ${classNameKey}Action on _${classNameKey}ScreenState {
  void _blocListener(BuildContext context, ${classNameKey}State state) {
    hideLoading();
  }

  void onRefresh() {
    bloc.add(Get${modelNameKey}sEvent());
  }

  void loadMore() {
    bloc.add(LoadMore${modelNameKey}sEvent());
  }
}
''';

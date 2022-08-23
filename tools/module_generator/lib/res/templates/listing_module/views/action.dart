import '../../../../common/definitions.dart';

const listingModuleAction = '''part of '${moduleNameKey}_screen.dart';

extension ${classNameKey}Action on _${classNameKey}ScreenState {
  void _blocListener(BuildContext context, ${classNameKey}State state) {
    _refreshController
      ..refreshCompleted()
      ..loadComplete();
  }

  void onRefresh() {
    bloc.add(GetDataEvent());
  }

  void loadMore() {
    bloc.add(LoadMoreDataEvent());
  }
}
''';

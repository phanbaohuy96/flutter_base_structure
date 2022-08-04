import '../../../../common/definations.dart';

const commonModuleAction = '''part of '${moduleNameKey}_screen.dart';

extension ${classNameKey}Action on _${classNameKey}ScreenState {
  void _blocListener(BuildContext context, ${classNameKey}State state) {}
}''';

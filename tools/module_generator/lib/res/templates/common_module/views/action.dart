import '../../../../common/definitions.dart';

const commonModuleAction =
    '''part of '${moduleNameKey}_screen.dart';

extension on _${classNameKey}ScreenState {
  void _blocListener(BuildContext context, ${classNameKey}State state) {}
}''';

import 'definations.dart';
import 'file_helper.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

/// input: test_module
/// output: TestModule
/// input: testModule
/// output: TestModule
String formatClassName(String inputName) {
  final regex = RegExp(r'[A-Z]?[a-z]+');
  return regex
      .allMatches(inputName)
      .map((e) => e.group(0)?.capitalize() ?? '')
      .join('');
}

/// input: test_module
/// output: test_module
/// input: testModule
/// output: test_module
///
String formatModuleName(String inputName) {
  final regex = RegExp(r'[A-Z]?[a-z]+');
  return regex
      .allMatches(inputName)
      .map((e) => e.group(0)?.toLowerCase() ?? '')
      .join('_');
}

// eg: openTemplateAndReplaceContent('common_module/module.txt', 'className', 'moduleName')
Future<String> openTemplateAndReplaceContent({
  required String relativeFilePathFromTemplate,
  required String className,
  required String moduleName,
}) async {
  final content = await FilesHelper.readFile(
    pathFile:
        'tools/pub_module_generator/res/templates/$relativeFilePathFromTemplate',
  );
  return (content ?? '')
      .replaceAll(classNameKey, className)
      .replaceAll(moduleNameKey, moduleName);
}

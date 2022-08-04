import 'definations.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String replaceContent({
    required String className,
    required String moduleName,
  }) {
    return replaceAll(classNameKey, className)
        .replaceAll(moduleNameKey, moduleName);
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

// // eg: openTemplateAndReplaceContent('common_module/module', 'className', 'moduleName')
// String openTemplateAndReplaceContent({
//   required String relativeFilePathFromTemplate,
//   required String className,
//   required String moduleName,
// }) {
//   final parts = relativeFilePathFromTemplate.split('/');
//   dynamic current = templates;
//   for (var part in parts) {
//     current = current[part];
//   }

//   String content = current is String ? current : '';

//   return content
//       .replaceAll(classNameKey, className)
//       .replaceAll(moduleNameKey, moduleName);
// }

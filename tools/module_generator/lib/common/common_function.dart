import 'definitions.dart';
import 'utils.dart';

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

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndex<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndex(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}

/// input: test_module
/// output: TestModule
/// input: testModule
/// output: TestModule
String formatClassName(String inputName) {
  return inputName.titleCase.replaceAll(' ', '');
}

/// input: test_module
/// output: test_module
/// input: testModule
/// output: test_module
///
String formatModuleName(String inputName) {
  return inputName.snakeCase;
}

/// input: test_module
/// output: testModule
/// input: testModule
/// output: testModule
String camelCase(String inputName) {
  return inputName.camelCase;
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

import 'dart:convert';
import 'dart:io';

import 'definations.dart';
import 'utils.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String replaceContent({
    required String className,
    required String moduleName,
    int? partCount,
    String? modelName,
  }) {
    final c1 = replaceAll(classNameKey, className)
        .replaceAll(moduleNameKey, moduleName)
        .replaceAll(modelNameKey, modelName ?? '');
    if (partCount != null) {
      return c1.replaceAll(
        importPartKey,
        List.generate(partCount, (index) => '../').join(''),
      );
    }
    return c1;
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

String prettyJsonStr(Map<dynamic, dynamic> json) {
  final encoder = JsonEncoder.withIndent('  ', (data) => data.toString());
  return encoder.convert(json);
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T that) op) => op(this);
}

extension FileEx on File {
  String get name => path.split(Platform.pathSeparator).last;
}

extension NullableStringIsNullOrEmptyExtension on String? {
  /// Returns `true` if the String is either null or empty.
  bool get isNullOrEmpty => this?.isEmpty ?? true;
}

extension ToolNullableStringIsNotNullOrEmptyExtension on String? {
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

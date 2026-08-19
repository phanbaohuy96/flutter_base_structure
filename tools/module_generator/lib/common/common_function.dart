import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'definitions.dart';
import 'utils.dart';

/// Normalises a user-supplied directory into a clean package-relative POSIX
/// path: quotes stripped, `./` prefix and trailing separators removed.
///
/// The old code derived import depth from `'/'.allMatches(dir).length`, so a
/// stray trailing slash or a `./` prefix silently shifted every emitted import
/// by one level. Normalising once, here, is what makes [resolveImportAnchors]
/// safe to compute from the directory alone.
String normalizeDir(String dir) {
  var value = dir.replaceAll("'", '').replaceAll('"', '').trim();
  value = value.replaceAll('\\', '/');
  while (value.startsWith('./')) {
    value = value.substring(2);
  }
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}

/// Import prefixes for a file emitted into [fileDir] (package-relative).
///
/// Every anchor is computed with [p.relative] from the emitting file's own
/// directory, so files at different depths inside the same module — `bloc/`,
/// `views/`, and the module root that holds the route and coordinator — each
/// get a prefix that actually resolves.
Map<String, String> resolveImportAnchors(String fileDir, {String? modelPath}) {
  final from = normalizeDir(fileDir);

  String prefixTo(String target) {
    final relative = p.posix.relative(target, from: from);
    if (relative == '.') {
      return '';
    }
    return '$relative/';
  }

  return {
    libImportKey: prefixTo('lib'),
    presentationImportKey: prefixTo('lib/presentation'),
    if (modelPath != null) ...{
      modelImportKey: p.posix.relative(normalizeDir(modelPath), from: from),
      modelFilterImportKey: p.posix.relative(
        normalizeDir(
          modelPath,
        ).replaceAll('.entity.dart', '_filter.entity.dart'),
        from: from,
      ),
    },
  };
}

extension StringExtension on String {
  /// Uppercases the first character and leaves the rest untouched.
  ///
  /// Deliberately does not lowercase the tail: doing so turned `userProfile`
  /// into `Userprofile`.
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String replaceContent({
    required String className,
    required String moduleName,
    String? fileDir,
    String? modelName,
    String? modelPath,
  }) {
    final replacements = <String, String>{
      classNameKey: className,
      moduleNameKey: moduleName,
      modelNameKey: modelName ?? '',
      routeNameKey: moduleName.paramCase,
      if (fileDir != null)
        ...resolveImportAnchors(fileDir, modelPath: modelPath),
    };

    // Create pattern with word boundaries for exact matches
    final pattern = replacements.keys
        .map((key) => RegExp.escape(key))
        .join('|');
    final regex = RegExp('($pattern)');

    return replaceAllMapped(regex, (match) => replacements[match.group(0)]!);
  }
}

extension ExtendedIterable<E> on Iterable<E> {
  /// Like `Iterable<T>.map` but callback have index as second argument
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

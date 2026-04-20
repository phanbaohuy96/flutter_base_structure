// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../common/file_helper.dart';

class ExportFile {
  final String fileName;
  final String folder;
  final List<String> ignore;

  ExportFile({
    required this.fileName,
    required this.folder,
    this.ignore = const [],
  });

  factory ExportFile.fromMap(Map<dynamic, dynamic> map) {
    final ignoreList = map['ignore'] as List<dynamic>?;
    return ExportFile(
      fileName: map['file_name'] as String,
      folder: map['folder'] as String,
      ignore: ignoreList?.cast<String>() ?? [],
    );
  }

  @override
  String toString() =>
      'ExportFile(fileName: $fileName, folder: $folder, ignore: $ignore)';

  String get filePath => '$folder$fileName';

  /// Check if a file path should be ignored based on the ignore patterns
  bool shouldIgnore(String filePath) {
    if (ignore.isEmpty) return false;

    for (final pattern in ignore) {
      if (_matchesPattern(filePath, pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Simple glob pattern matching
  bool _matchesPattern(String filePath, String pattern) {
    // Normalize both paths to use forward slashes
    final normalizedPath = filePath.replaceAll('\\', '/');
    final normalizedPattern = pattern.replaceAll('\\', '/');

    // If the pattern contains **, it can match anywhere in the path
    // If not, it should match from the beginning
    final containsDoubleStar = normalizedPattern.contains('**');

    // Convert glob pattern to regex
    var regexPattern = '';

    for (var i = 0; i < normalizedPattern.length; i++) {
      final char = normalizedPattern[i];
      final nextChar = i + 1 < normalizedPattern.length
          ? normalizedPattern[i + 1]
          : '';

      if (char == '*' && nextChar == '*') {
        // Handle ** pattern
        final afterDoubleStar = i + 2 < normalizedPattern.length
            ? normalizedPattern[i + 2]
            : '';
        if (afterDoubleStar == '/') {
          regexPattern += '.*?/'; // **/ matches any number of directories
          i += 2; // Skip the next * and /
        } else {
          regexPattern += '.*'; // ** at end matches anything
          i += 1; // Skip the next *
        }
      } else if (char == '*') {
        regexPattern += '[^/]*'; // * matches anything except / (greedy)
      } else if (char == '?') {
        regexPattern += '[^/]'; // ? matches single character except /
      } else if (char == '.') {
        regexPattern += r'\.'; // Escape literal dots
      } else if (RegExp(r'[\^$+()[\]{}|]').hasMatch(char)) {
        regexPattern += '\\$char'; // Escape regex special characters
      } else {
        regexPattern += char;
      }
    }

    // For patterns with **, match anywhere in the path
    // For other patterns, match from the beginning
    if (!containsDoubleStar) {
      regexPattern = '^$regexPattern\$';
    }

    // Create regex with case-insensitive matching
    final regex = RegExp(regexPattern, caseSensitive: false);

    return regex.hasMatch(normalizedPath);
  }
}

Future<void> generateExport({required List<YamlMap> config}) async {
  final exportConfigs = config.map((e) => ExportFile.fromMap(e.value));

  for (final c in exportConfigs) {
    final contents = [
      ...(await getFilesFromDirector(c.folder, c)).map((e) {
        final cleanPath = e.replaceFirst(c.folder, '');
        return path.posix.joinAll(path.split(cleanPath));
      }),
    ]..sort();

    contents
      ..removeWhere((e) => e.contains('''\'${c.fileName}\''''))
      ..add('');

    await FilesHelper.writeFile(
      pathFile: c.filePath,
      content: contents.join('\n'),
    );
  }
}

Future<List<String>> getFilesFromDirector(
  String directory, [
  ExportFile? exportConfig,
]) async {
  final contents = <String>[];
  final dir = Directory(directory);

  final entities = await dir.list().toList();
  for (final f in entities.whereType<File>()) {
    if (['.DS_Store'].any((ext) => f.path.contains(ext))) {
      continue;
    }

    // Check if this file should be ignored
    if (exportConfig != null && exportConfig.shouldIgnore(f.path)) {
      continue;
    }

    final fileContent = f.readAsStringSync();
    if (!fileContent.contains('part of \'')) {
      contents.add('export \'${f.path}\';');
    }
  }
  for (final f in entities.whereType<Directory>()) {
    // Check if this directory should be ignored
    if (exportConfig != null && exportConfig.shouldIgnore(f.path)) {
      continue;
    }
    contents.addAll(await getFilesFromDirector(f.path, exportConfig));
  }

  return contents;
}

import 'dart:async';
import 'dart:io';

class FilesHelper {
  FilesHelper._();

  static Future<bool> existsDir(String dir) async {
    final folderDir = Directory(dir);
    return await folderDir.exists();
  }

  static Future<bool> createFolder(String folder) async {
    final folderDir = Directory(folder);
    final checkExist = await folderDir.exists();
    if (checkExist) {
      return true;
    }

    final create = await folderDir.create(recursive: true);
    return create.path.isNotEmpty;
  }

  static Future<bool> writeFile({
    required String pathFile,
    required String content,
    bool overrideFile = true,
  }) async {
    final runBash = File(pathFile);
    final runBashExists = await runBash.exists();

    if (!runBashExists) {
      await runBash.create();

      await runBash.writeAsString(content);
    } else if (overrideFile) {
      await runBash.delete();
      await runBash.create();

      await runBash.writeAsString(content);
    } else {
      print('''[Warning] $pathFile already exists but do not allow to override
[Warning] Consider to add the missing content below manually:

$content''');
    }

    return runBash.path.isNotEmpty;
  }

  static Future<String?> readFile({required String pathFile}) async {
    final runBash = File(pathFile);
    final runBashExists = await runBash.exists();
    if (!runBashExists) {
      return '';
    }
    final result = await runBash.readAsString();
    return result;
  }

  static Future<List<FileSystemEntity>> dirContents(String path) {
    final dir = Directory(path);
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen(
      (file) => files.add(file),
      // should also register onError
      onDone: () => completer.complete(files),
    );
    return completer.future;
  }
}

class YamlWriter {
  /// The amount of spaces for each level.
  final int spaces;

  /// Initialize the writer with the amount of [spaces] per level.
  YamlWriter({this.spaces = 2});

  /// Write a dart structure to a YAML string. [yaml] should be a [Map] or [List].
  String write(dynamic yaml) {
    return _writeInternal(yaml).trim();
  }

  /// Write a dart structure to a YAML string. [yaml] should be a [Map] or [List].
  String _writeInternal(dynamic yaml, {int indent = 0}) {
    final lines = [];

    if (yaml is List) {
      lines.addAll(_writeList(yaml, indent: indent));
    } else if (yaml is Map) {
      lines.addAll(_writeMap(yaml, indent: indent));
    } else if (yaml is String) {
      lines.add(
        yaml.contains(' ')
            ? "\"${yaml.replaceAll("\"", "\\\"")}\""
            : "${yaml.replaceAll("\"", "\\\"")}",
      );
    } else {
      lines.add(yaml.toString());
    }

    return lines.join('\n');
  }

  /// Write a list to a YAML string.
  /// Pass the list in as [yaml] and indent it to the [indent] level.
  List<String> _writeList(List yaml, {int indent = 0}) {
    final lines = <String>[];

    for (var item in yaml) {
      lines.add(
        '${_indent(indent)}- ${_writeInternal(item, indent: indent + 1)}',
      );
    }

    return lines;
  }

  /// Write a map to a YAML string.
  /// Pass the map in as [yaml] and indent it to the [indent] level.
  List<String> _writeMap(Map yaml, {int indent = 0}) {
    final lines = <String>[];

    for (var key in yaml.keys) {
      var value = yaml[key];
      if (value is bool) {
        lines.add('${_indent(indent)}${key.toString()}: $value');
      } else {
        lines.addAll([
          '${_indent(indent)}${key.toString()}:',
          '${_writeInternal(value, indent: indent + 1)}',
        ]);
      }
    }

    return lines;
  }

  /// Create an indented string for the level with the spaces config.
  /// [indent] is the level of indent whereas [spaces] is the
  /// amount of spaces that the string should be indented by.
  String _indent(int indent) {
    return ''.padLeft(indent * spaces, ' ');
  }
}

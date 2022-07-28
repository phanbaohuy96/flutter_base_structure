import 'dart:async';
import 'dart:io';

import 'utils.dart';

class FilesHelper {
  FilesHelper._();
  static Future<bool> createFolder(String folder) async {
    final folderDir = Directory(folder);
    final checkExist = await folderDir.exists();
    if (checkExist) {
      printLog('[Warning] Folder $folder is exist!');
      return true;
    }

    final create = await folderDir.create(recursive: true);
    return create.path.isNotEmpty;
  }

  static Future<bool>? writeFile({
    required String pathFile,
    required String content,
    bool isCreateNew = true,
  }) async {
    final runBash = File(pathFile);
    final runBashExists = await runBash.exists();

    if (!runBashExists) {
      runBash.createSync();
    } else if (isCreateNew) {
      runBash.deleteSync();
      runBash.createSync();
    }

    await runBash.writeAsString(content);
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
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }
}

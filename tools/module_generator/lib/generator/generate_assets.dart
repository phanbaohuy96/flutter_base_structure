import 'dart:async';
import 'dart:io';

import '../common/common_function.dart';
import '../common/definitions.dart';
import '../common/file_helper.dart';
import '../res/templates/asset/assets.dart';

class AssetFile {
  final String variableName;
  final String filePath;

  AssetFile({required this.variableName, required this.filePath});
}

Future<void> generateAsset({
  required List<String> paths,
  required String output,
}) async {
  await FilesHelper.createFolder(output);
  final listAssets = <AssetFile>[];
  for (final p in paths) {
    final dir = Directory(p);

    final List<FileSystemEntity> entities = await dir.list().toList();
    for (final f in entities.whereType<File>()) {
      final fileName = f.path.split('/').last.split('.').first;

      listAssets.add(AssetFile(
        variableName: camelCase(fileName),
        filePath: f.path,
      ));
    }
  }
  listAssets.sort((a, b) => a.variableName.compareTo(b.variableName));
  var contentFile = '';
  for (final a in listAssets) {
    final line = '  static const String ${a.variableName} = \'${a.filePath}\';';
    if (line.length > 80) {
      contentFile += '''\n  static const String ${a.variableName} =
      '${a.filePath}';''';
    } else {
      contentFile += '\n$line';
    }
  }
  await FilesHelper.writeFile(
    pathFile: '${output}assets.dart',
    content: assetsRes.replaceFirst(contentKey, contentFile),
  );
}

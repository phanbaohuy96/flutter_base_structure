import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../common/common_function.dart';
import '../common/definations.dart';
import '../common/file_helper.dart';
import '../res/templates/asset/assets.dart';
import '../res/templates/asset/image_assets.dart';
import '../res/templates/asset/other_assets.dart';
import '../res/templates/asset/rive_assets.dart';
import '../res/templates/asset/svg_assets.dart';

class AssetFile {
  final String variableName;
  final String filePath;

  AssetFile({required this.variableName, required this.filePath});
}

Future<void> generateAsset({
  required List<String> paths,
  required String output,
  String? root,
}) async {
  final validExtension = ['png', 'jpg', 'jpeg', 'svg', 'riv', 'json'];

  await FilesHelper.createFolder(output);
  final listAssets = <AssetFile>[];
  for (final p in paths) {
    final dir = Directory(p);

    final entities = await dir.list().toList();
    for (final f in entities.whereType<File>()) {
      var isValidExtension = validExtension
          .any((extension) => path.extension(f.path).contains(extension));
      if (isValidExtension) {
        final fileName = f.path.split('/').last.split('.').first;

        listAssets.add(AssetFile(
          variableName: camelCase(fileName),
          filePath: f.path,
        ));
      }
    }
  }
  listAssets.sort((a, b) => a.variableName.compareTo(b.variableName));
  var svgContentFile = '';
  var imageContentFile = '';
  var riveContentFile = '';
  var otherContentFile = '';
  for (final a in listAssets) {
    var append = '';

    append += root != null ? '\n\n  // [$root/${a.filePath}]' : '';
    final line = '  final String ${a.variableName} = \'${a.filePath}\';';
    if (line.length > 80) {
      append += '''\n  final String ${a.variableName} =
      '${a.filePath}';''';
    } else {
      append += '\n$line';
    }
    if (['.png', '.jpg', '.jpeg'].any((ext) => a.filePath.contains(ext))) {
      imageContentFile += append;
    } else if (['.svg'].any((ext) => a.filePath.contains(ext))) {
      svgContentFile += append;
    } else if (['.riv'].any((ext) => a.filePath.contains(ext))) {
      if (riveContentFile.isEmpty) {
        final riveFilePath = 'rive.yaml';

        if (File(riveFilePath).existsSync()) {
          final yamlMap =
              loadYaml(File(riveFilePath).readAsStringSync()) as Map;

          final artboards = yamlMap['artboards'] as Map;

          artboards.keys.forEach((key) {
            var append = '\n';

            final line =
                '  final ${(formatClassName('${key}Artboard'))} ${camelCase('${(formatClassName('${key}Artboard'))}')} = ${(formatClassName('${key}Artboard'))}();';

            if (line.length > 80) {
              append +=
                  '\n  final ${(formatClassName('${key}Artboard'))} ${camelCase('${(formatClassName('${key}Artboard'))}')} =\n${(formatClassName('${key}Artboard'))}();';
            } else {
              append += '\n$line';
            }

            riveContentFile += append;
          });
        }
      }

      riveContentFile += append;
    } else if (['.DS_Store'].every((ext) => !a.filePath.contains(ext))) {
      otherContentFile += append;
    }
  }
  await FilesHelper.writeFile(
    pathFile: '${output}assets.dart',
    content: assetsRes,
  );

  await FilesHelper.writeFile(
    pathFile: '${output}image_assets.dart',
    content: imageAssetsRes.replaceFirst(contentKey, imageContentFile),
  );

  await FilesHelper.writeFile(
    pathFile: '${output}svg_assets.dart',
    content: svgAssetsRes.replaceFirst(contentKey, svgContentFile),
  );

  await FilesHelper.writeFile(
    pathFile: '${output}rive_assets.dart',
    content: _generateRiveContentFile(
        riveAssetsRes.replaceFirst(contentKey, riveContentFile)),
  );

  await FilesHelper.writeFile(
    pathFile: '${output}other_assets.dart',
    content: otherAssetsRes.replaceFirst(contentKey, otherContentFile),
  );
}

Future<void> removeUnusedAssets({
  required List<String> resPaths,
  required String output,
  String? root,
}) async {
  final listAssets = <AssetFile>[];
  for (final p in resPaths) {
    final dir = Directory(p);

    final entities = await dir.list().toList();
    for (final f in entities.whereType<File>()) {
      final fileName = f.path.split('/').last.split('.').first;

      listAssets.add(AssetFile(
        variableName: camelCase(fileName),
        filePath: f.path,
      ));
    }
  }
  listAssets.sort((a, b) => a.variableName.compareTo(b.variableName));
  var svgAssetFile = <AssetFile>[];
  var imageAssetFile = <AssetFile>[];
  var otherAssetFile = <AssetFile>[];
  for (final a in listAssets) {
    final variable = a.variableName;
    if (['.png', '.jpg', '.jpeg'].any((ext) => a.filePath.contains(ext))) {
      imageAssetFile.add(AssetFile(
        variableName: 'Assets.image.$variable',
        filePath: a.filePath,
      ));
    } else if (['.svg'].any((ext) => a.filePath.contains(ext))) {
      svgAssetFile.add(AssetFile(
        variableName: 'Assets.svg.$variable',
        filePath: a.filePath,
      ));
    } else if (['.DS_Store'].every((ext) => !a.filePath.contains(ext))) {
      otherAssetFile.add(AssetFile(
        variableName: 'Assets.other.$variable',
        filePath: a.filePath,
      ));
    }
  }

  final allDartFiles = await _getAllDartFilePathsInDir('lib/');

  for (final f in allDartFiles) {
    final content = await f.readAsString();

    svgAssetFile.removeWhere((svg) {
      var regex = RegExp('\\b(${svg.variableName})\\b', caseSensitive: false);
      return regex.hasMatch(content);
    });
    imageAssetFile.removeWhere((image) {
      var regex = RegExp('\\b(${image.variableName})\\b', caseSensitive: false);
      return regex.hasMatch(content);
    });
    otherAssetFile.removeWhere((other) {
      var regex = RegExp('\\b(${other.variableName})\\b', caseSensitive: false);
      return regex.hasMatch(content);
    });
  }
  for (final svg in svgAssetFile) {
    print('removed svg asset: ${svg.filePath}');
    await File(svg.filePath).delete();
  }
  for (final image in imageAssetFile) {
    final dir = ([...image.filePath.split('/')]..removeLast()).join('/') + '/';
    print('removed image asset: ${image.filePath}');
    await File(image.filePath).delete();

    await File(image.filePath).name.let((name) async {
      await File(dir + '2.0x/' + name).let((file) async {
        if (await file.exists()) {
          print('removed image asset: ${file.path}');
          await file.delete();
        }
      });

      await File(dir + '3.0x/' + name).let((file) async {
        if (await file.exists()) {
          print('removed image asset: ${file.path}');
          await file.delete();
        }
      });
    });
  }
  for (final other in otherAssetFile) {
    print('removed other asset: ${other.filePath}');
    await File(other.filePath).delete();
  }

  await generateAsset(
    paths: resPaths,
    output: output,
    root: root,
  );
}

Future<List<File>> _getAllDartFilePathsInDir(String dir) async {
  final paths = <File>[];
  final _dir = Directory(dir);

  final entities = await _dir.list().toList();
  for (final e in entities) {
    if (e is File && e.path.contains('.dart')) {
      paths.add(e);
    } else if (e is Directory) {
      paths.addAll(await _getAllDartFilePathsInDir(e.path));
    }
  }
  return paths;
}

String _generateRiveContentFile(String riveContentFile) {
  var filePath = 'rive.yaml';
  if (File(filePath).existsSync()) {
    final yamlMap = loadYaml(File(filePath).readAsStringSync()) as Map;

    final artboards = yamlMap['artboards'] as Map;

    artboards.forEach((key, value) {
      final states = value['states'];

      var statesContent = '';

      if (states?.isNotEmpty == true) {
        final statesList = [];
        states!.forEach((element) {
          statesList.add('\'${camelCase(element)}\'');
          var append = '';

          final line = '  final String ${(camelCase(element))} = \'$element\';';

          if (line.length > 80) {
            append +=
                '\n  final String ${(camelCase(element))} =\n\'$element;\'';
          } else {
            append += '\n$line';
          }

          statesContent += append;
        });
        statesContent +=
            '\n  List<String> get statesList => ${statesList.toString()};';
      }

      riveContentFile +=
          '\n${riveAssetsStatesRes.replaceAll(contentKey, statesContent).replaceAll(classNameKey, formatClassName(key))}';

      final inputs = value['inputs'];

      var inputsContent = '';

      if (inputs?.isNotEmpty == true) {
        final inputsList = [];
        inputs!.forEach((element) {
          inputsList.add('\'${camelCase(element)}\'');
          var append = '';

          final line = '  final String ${(camelCase(element))} = \'$element\';';

          if (line.length > 80) {
            append +=
                '\n  final String ${(camelCase(element))} =\n\'$element;\'';
          } else {
            append += '\n$line';
          }

          inputsContent += append;
        });
        inputsContent +=
            '\n  List<String> get inputsList => ${inputsList.toString()};';
      }

      riveContentFile +=
          '\n${riveAssetsInputsRes.replaceAll(contentKey, inputsContent).replaceAll(classNameKey, formatClassName(key))}';

      final machines = value['machines'];

      var machinesContent = '';

      if (machines?.isNotEmpty == true) {
        final machinesList = [];

        machines!.forEach((element) {
          machinesList.add('\'${camelCase(element)}\'');

          var append = '';

          final line = '  final String ${(camelCase(element))} = \'$element\';';

          if (line.length > 80) {
            append +=
                '\n  final String ${(camelCase(element))} =\n\'$element;\'';
          } else {
            append += '\n$line';
          }

          machinesContent += append;
        });

        machinesContent +=
            '\n  List<String> get machinesList => ${machinesList.toString()};';
      }

      riveContentFile +=
          '\n${riveAssetsMachinesRes.replaceAll(contentKey, machinesContent).replaceAll(classNameKey, formatClassName(key))}';

      riveContentFile +=
          '\n${riveAssetsArtboardRes.replaceAll(classNameKey, formatClassName(key)).replaceAll(artboardKey, key)}';
    });
  }

  return riveContentFile;
}

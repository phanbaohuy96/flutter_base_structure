import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../common/common_function.dart';
import '../common/definitions.dart';
import '../common/file_helper.dart';
import '../res/templates/asset/assets.dart';
import '../res/templates/asset/audio_assets.dart';
import '../res/templates/asset/gif_assets.dart';
import '../res/templates/asset/image_assets.dart';
import '../res/templates/asset/other_assets.dart';
import '../res/templates/asset/rive_assets.dart';
import '../res/templates/asset/svg_assets.dart';

// Asset type constants
class AssetConstants {
  static const imageExtensions = ['.png', '.jpg', '.jpeg'];
  static const svgExtensions = ['.svg'];
  static const gifExtensions = ['.gif'];
  static const audioExtensions = ['.mp3', '.wav', '.ogg'];
  static const riveExtensions = ['.riv'];
  static const ignoredExtensions = [
    '.DS_Store', // macOS system file
    'Thumbs.db', // Windows system file
    '.gitkeep', // Git placeholder file
    '.gitignore', // Git ignore file
  ];
  static const riveConfigFile = 'rive.yaml';
}

enum AssetType {
  image('image'),
  svg('svg'),
  gif('gif'),
  audio('audio'),
  rive('rive'),
  other('other');

  const AssetType(this.folderName);
  final String folderName;
}

class AssetFile {
  final String variableName;
  final String filePath;
  final AssetType type;

  AssetFile({
    required this.variableName,
    required this.filePath,
    required this.type,
  });
}

class AssetTypeDetector {
  static AssetType detectAssetType(String filePath) {
    final lowerPath = filePath.toLowerCase();
    final fileName = filePath.split('/').last;

    // Check for ignored files first
    if (AssetConstants.ignoredExtensions.any(fileName.contains)) {
      throw ArgumentError('Ignored file type: $filePath');
    }

    if (AssetConstants.imageExtensions.any(lowerPath.endsWith)) {
      return AssetType.image;
    } else if (AssetConstants.svgExtensions.any(lowerPath.endsWith)) {
      return AssetType.svg;
    } else if (AssetConstants.gifExtensions.any(lowerPath.endsWith)) {
      return AssetType.gif;
    } else if (AssetConstants.audioExtensions.any(lowerPath.endsWith)) {
      return AssetType.audio;
    } else if (AssetConstants.riveExtensions.any(lowerPath.endsWith)) {
      return AssetType.rive;
    } else {
      return AssetType.other;
    }
  }

  static AssetFile createAssetFile(String filePath, {String? prefix}) {
    final fileName = filePath.split('/').last.split('.').first;

    // Validate that we have a proper file name
    if (fileName.isEmpty) {
      throw ArgumentError('Invalid file name for asset: $filePath');
    }

    final variableName = camelCase(fileName);

    // Validate that the camelCase conversion resulted in a valid variable name
    if (variableName.isEmpty) {
      throw ArgumentError(
        'Could not generate valid variable name for: $filePath',
      );
    }

    final assetType = detectAssetType(filePath);

    final fullVariableName = prefix != null
        ? '$prefix.${assetType.folderName}.$variableName'
        : variableName;

    return AssetFile(
      variableName: fullVariableName,
      filePath: filePath,
      type: assetType,
    );
  }
}

class AssetProcessor {
  static Future<List<AssetFile>> collectAssets(
    List<String> paths, {
    String? prefix,
  }) async {
    final listAssets = <AssetFile>[];

    for (final path in paths) {
      try {
        final dir = Directory(path);
        if (!await dir.exists()) {
          print('Warning: Directory does not exist: $path');
          continue;
        }

        final entities = await dir.list().toList();

        for (final entity in entities.whereType<File>()) {
          try {
            final assetFile = AssetTypeDetector.createAssetFile(
              entity.path,
              prefix: prefix,
            );
            listAssets.add(assetFile);
          } catch (e) {
            // Skip ignored files or files with errors
            print('Skipping file: ${entity.path} - $e');
            continue;
          }
        }
      } catch (e) {
        print('Error processing directory $path: $e');
        continue;
      }
    }

    listAssets.sort((a, b) => a.variableName.compareTo(b.variableName));
    return listAssets;
  }

  static Map<AssetType, List<AssetFile>> groupAssetsByType(
    List<AssetFile> assets,
  ) {
    final groupedAssets = <AssetType, List<AssetFile>>{};

    for (final assetType in AssetType.values) {
      groupedAssets[assetType] = assets
          .where((asset) => asset.type == assetType)
          .toList();
    }

    return groupedAssets;
  }

  static String generateAssetContent(List<AssetFile> assets, String? root) {
    var content = '';

    for (final asset in assets) {
      var append = '';
      append += root != null ? '\n\n  // [$root/${asset.filePath}]' : '';

      final line =
          '  final String ${asset.variableName} = \'${asset.filePath}\';';
      if (line.length > 80) {
        append += '''\n  final String ${asset.variableName} =
      '${asset.filePath}';''';
      } else {
        append += '\n$line';
      }

      content += append;
    }

    return content;
  }
}

Future<void> generateAsset({
  required List<String> paths,
  required String output,
  String? root,
}) async {
  try {
    await FilesHelper.createFolder(output);

    // Collect and process assets
    final allAssets = await AssetProcessor.collectAssets(paths);
    final groupedAssets = AssetProcessor.groupAssetsByType(allAssets);

    print(
      'Found ${allAssets.length} assets across ${groupedAssets.length} types',
    );

    // Generate content for each asset type
    final imageContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.image] ?? [],
      root,
    );
    final svgContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.svg] ?? [],
      root,
    );
    final gifContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.gif] ?? [],
      root,
    );
    final audioContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.audio] ?? [],
      root,
    );
    final otherContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.other] ?? [],
      root,
    );

    // Generate Rive content with special handling
    var riveContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.rive] ?? [],
      root,
    );
    riveContent = _generateRiveContentFile(
      riveAssetsRes.replaceFirst(contentKey, riveContent),
    );

    // Write all asset files
    await _writeAssetFiles(output, {
      'assets.dart': assetsRes,
      'image_assets.dart': imageAssetsRes.replaceFirst(
        contentKey,
        imageContent,
      ),
      'svg_assets.dart': svgAssetsRes.replaceFirst(contentKey, svgContent),
      'gif_assets.dart': gifAssetsRes.replaceFirst(contentKey, gifContent),
      'audio_assets.dart': audioAssetsRes.replaceFirst(
        contentKey,
        audioContent,
      ),
      'other_assets.dart': otherAssetsRes.replaceFirst(
        contentKey,
        otherContent,
      ),
      'rive_assets.dart': riveContent,
    });

    print('Successfully generated asset files in $output');
  } catch (e, stackTrace) {
    print('Error generating assets: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> _writeAssetFiles(String output, Map<String, String> files) async {
  for (final entry in files.entries) {
    await FilesHelper.writeFile(
      pathFile: '$output${entry.key}',
      content: entry.value,
    );
  }
}

Future<void> removeUnusedAssets({
  required List<String> resPaths,
  required String output,
  String? root,
}) async {
  try {
    print('Starting unused asset removal process...');

    // Collect assets with Assets.type.name pattern for usage checking
    final allAssets = await AssetProcessor.collectAssets(
      resPaths,
      prefix: 'Assets',
    );
    final groupedAssets = AssetProcessor.groupAssetsByType(allAssets);

    print('Found ${allAssets.length} total assets to check for usage');

    // Get all Dart files for usage checking
    final allDartFiles = await _getAllDartFilePathsInDir('lib/');
    print('Scanning ${allDartFiles.length} Dart files for asset usage...');

    // Remove assets that are found in Dart files
    await _removeUsedAssetsFromLists(groupedAssets, allDartFiles);

    // Count unused assets
    final unusedCount = groupedAssets.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    print('Found $unusedCount unused assets');

    if (unusedCount > 0) {
      // Delete unused assets from filesystem
      await _deleteUnusedAssets(groupedAssets);

      // Regenerate asset files
      print('Regenerating asset files...');
      await generateAsset(paths: resPaths, output: output, root: root);
      print('Asset cleanup completed successfully!');
    } else {
      print('No unused assets found. Nothing to clean up.');
    }
  } catch (e, stackTrace) {
    print('Error during asset cleanup: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> _removeUsedAssetsFromLists(
  Map<AssetType, List<AssetFile>> groupedAssets,
  List<File> dartFiles,
) async {
  for (final file in dartFiles) {
    final content = await file.readAsString();

    for (final assetList in groupedAssets.values) {
      assetList.removeWhere((asset) {
        final regex = RegExp(
          '\\b(${asset.variableName})\\b',
          caseSensitive: false,
        );
        return regex.hasMatch(content);
      });
    }
  }
}

Future<void> _deleteUnusedAssets(
  Map<AssetType, List<AssetFile>> groupedAssets,
) async {
  for (final entry in groupedAssets.entries) {
    final assetType = entry.key;
    final assets = entry.value;

    for (final asset in assets) {
      print('removed ${assetType.folderName} asset: ${asset.filePath}');
      await File(asset.filePath).delete();

      // Special handling for images - delete resolution variants
      if (assetType == AssetType.image) {
        await _deleteImageVariants(asset.filePath);
      }
    }
  }
}

Future<void> _deleteImageVariants(String imagePath) async {
  final file = File(imagePath);
  final dir = '${([...imagePath.split('/')]..removeLast()).join('/')}/';
  final fileName = file.path.split('/').last;

  // Delete 2.0x and 3.0x variants
  for (final scale in ['2.0x', '3.0x']) {
    final variantFile = File('$dir$scale/$fileName');
    if (await variantFile.exists()) {
      print('removed image asset: ${variantFile.path}');
      await variantFile.delete();
    }
  }
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
  const riveConfigPath = AssetConstants.riveConfigFile;

  if (!File(riveConfigPath).existsSync()) {
    print('Warning: Rive config file not found: $riveConfigPath');
    return riveContentFile;
  }

  try {
    final yamlMap = loadYaml(File(riveConfigPath).readAsStringSync()) as Map;
    final artboards = yamlMap['artboards'] as Map?;

    if (artboards == null) {
      print('Warning: No artboards found in $riveConfigPath');
      return riveContentFile;
    }

    artboards.forEach((key, value) {
      riveContentFile += _generateRiveArtboardContent(key, value);
    });

    return riveContentFile;
  } catch (e) {
    print('Error processing Rive config file: $e');
    return riveContentFile;
  }
}

String _generateRiveArtboardContent(String artboardKey, dynamic artboardValue) {
  var content = '';

  // Generate states content
  final states = artboardValue['states'];
  if (states?.isNotEmpty == true) {
    final statesContent = _generateRiveStatesContent(states);
    content +=
        '\n${riveAssetsStatesRes.replaceAll(contentKey, statesContent).replaceAll(classNameKey, formatClassName(artboardKey))}';
  }

  // Generate inputs content
  final inputs = artboardValue['inputs'];
  if (inputs?.isNotEmpty == true) {
    final inputsContent = _generateRiveInputsContent(inputs);
    content +=
        '\n${riveAssetsInputsRes.replaceAll(contentKey, inputsContent).replaceAll(classNameKey, formatClassName(artboardKey))}';
  }

  // Generate machines content
  final machines = artboardValue['machines'];
  if (machines?.isNotEmpty == true) {
    final machinesContent = _generateRiveMachinesContent(machines);
    content +=
        '\n${riveAssetsMachinesRes.replaceAll(contentKey, machinesContent).replaceAll(classNameKey, formatClassName(artboardKey))}';
  }

  // Generate artboard content
  content +=
      '\n${riveAssetsArtboardRes.replaceAll(classNameKey, formatClassName(artboardKey)).replaceAll(artboardKey, artboardKey)}';

  return content;
}

String _generateRiveStatesContent(List<dynamic> states) {
  var content = '';
  final statesList = <String>[];

  for (final element in states) {
    final camelCaseName = camelCase(element);
    statesList.add("'$camelCaseName'");

    final line = '  final String $camelCaseName = \'$element\';';
    if (line.length > 80) {
      content += '\n  final String $camelCaseName =\n      \'$element\';';
    } else {
      content += '\n$line';
    }
  }

  content += '\n  List<String> get statesList => ${statesList.toString()};';
  return content;
}

String _generateRiveInputsContent(List<dynamic> inputs) {
  var content = '';
  final inputsList = <String>[];

  for (final element in inputs) {
    final camelCaseName = camelCase(element);
    inputsList.add("'$camelCaseName'");

    final line = '  final String $camelCaseName = \'$element\';';
    if (line.length > 80) {
      content += '\n  final String $camelCaseName =\n      \'$element\';';
    } else {
      content += '\n$line';
    }
  }

  content += '\n  List<String> get inputsList => ${inputsList.toString()};';
  return content;
}

String _generateRiveMachinesContent(List<dynamic> machines) {
  var content = '';
  final machinesList = <String>[];

  for (final element in machines) {
    final camelCaseName = camelCase(element);
    machinesList.add("'$camelCaseName'");

    final line = '  final String $camelCaseName = \'$element\';';
    if (line.length > 80) {
      content += '\n  final String $camelCaseName =\n      \'$element\';';
    } else {
      content += '\n$line';
    }
  }

  content += '\n  List<String> get machinesList => ${machinesList.toString()};';
  return content;
}

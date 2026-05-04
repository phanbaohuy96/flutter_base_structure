import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
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

class AssetConstants {
  static const imageExtensions = ['.png', '.jpg', '.jpeg'];
  static const svgExtensions = ['.svg'];
  static const gifExtensions = ['.gif'];
  static const audioExtensions = ['.mp3', '.wav', '.ogg'];
  static const riveExtensions = ['.riv'];
  static const ignoredFileNames = [
    '.DS_Store',
    'Thumbs.db',
    '.gitkeep',
    '.gitignore',
  ];
  static const riveConfigFile = 'rive.yaml';

  static final scaleDirectoryRegex = RegExp(r'^\d+(\.\d*)?x$');
  static final filenameScaleRegex = RegExp(
    r'@\d+(\.\d*)?x$',
    caseSensitive: false,
  );
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

enum AssetStructure { flat, tree }

class AssetGenerationException implements Exception {
  final String message;

  const AssetGenerationException(this.message);

  @override
  String toString() => 'AssetGenerationException: $message';
}

class AssetGenerationResult {
  final List<AssetFile> assets;
  final List<String> warnings;

  const AssetGenerationResult({required this.assets, required this.warnings});
}

class RemoveUnusedAssetsResult {
  final List<AssetFile> unusedAssets;
  final List<AssetFile> usedAssets;
  final List<String> warnings;
  final bool dryRun;

  const RemoveUnusedAssetsResult({
    required this.unusedAssets,
    required this.usedAssets,
    this.warnings = const [],
    required this.dryRun,
  });
}

class AssetFile {
  final String variableName;
  final String filePath;
  final String absolutePath;
  final AssetType type;
  final List<String> folderSegments;

  AssetFile({
    required this.variableName,
    required this.filePath,
    required this.absolutePath,
    required this.type,
    this.folderSegments = const [],
  });

  String get accessor => 'Assets.${type.folderName}.$variableName';
}

class AssetContent {
  final String fields;
  final String nestedClasses;

  const AssetContent({required this.fields, required this.nestedClasses});

  const AssetContent.empty() : fields = '', nestedClasses = '';
}

class AssetTypeDetector {
  static AssetType detectAssetType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    final fileName = path.basename(filePath);

    if (AssetConstants.ignoredFileNames.contains(fileName)) {
      throw ArgumentError('Ignored file type: $filePath');
    }

    if (AssetConstants.imageExtensions.contains(extension)) {
      return AssetType.image;
    } else if (AssetConstants.svgExtensions.contains(extension)) {
      return AssetType.svg;
    } else if (AssetConstants.gifExtensions.contains(extension)) {
      return AssetType.gif;
    } else if (AssetConstants.audioExtensions.contains(extension)) {
      return AssetType.audio;
    } else if (AssetConstants.riveExtensions.contains(extension)) {
      return AssetType.rive;
    } else {
      return AssetType.other;
    }
  }

  static AssetFile createAssetFile(String filePath, {String? prefix}) {
    final fileName = path.basenameWithoutExtension(filePath);
    if (fileName.isEmpty) {
      throw ArgumentError('Invalid file name for asset: $filePath');
    }

    final variableName = _toDartIdentifier(fileName);
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
      filePath: _toPosixPath(filePath),
      absolutePath: path.absolute(filePath),
      type: assetType,
    );
  }
}

class AssetProcessor {
  static Future<List<AssetFile>> collectAssets(
    List<String> paths, {
    String? prefix,
    String projectDir = '.',
    bool recursive = true,
  }) async {
    final warnings = <String>[];
    final assets = await collectAssetsWithWarnings(
      paths,
      prefix: prefix,
      projectDir: projectDir,
      recursive: recursive,
      warnings: warnings,
    );

    for (final warning in warnings) {
      print(warning);
    }

    return assets;
  }

  static Future<List<AssetFile>> collectAssetsWithWarnings(
    List<String> paths, {
    String? prefix,
    String projectDir = '.',
    bool recursive = true,
    List<String>? warnings,
  }) async {
    final projectPath = path.absolute(projectDir);
    final assetsByPath = <String, AssetFile>{};

    for (final assetPath in paths) {
      final resolvedPath = _resolvePath(projectPath, assetPath);
      final file = File(resolvedPath);
      final dir = Directory(resolvedPath);

      if (await file.exists()) {
        await _addFile(
          file,
          projectPath,
          assetsByPath,
          prefix: prefix,
          warnings: warnings,
        );
      } else if (await dir.exists()) {
        await for (final entity in dir.list(
          recursive: recursive,
          followLinks: false,
        )) {
          if (entity is File) {
            await _addFile(
              entity,
              projectPath,
              assetsByPath,
              prefix: prefix,
              warnings: warnings,
            );
          }
        }
      } else {
        print('Warning: Asset path does not exist: $assetPath');
      }
    }

    final assets = assetsByPath.values.toList()
      ..sort((a, b) {
        final typeCompare = a.type.folderName.compareTo(b.type.folderName);
        if (typeCompare != 0) return typeCompare;
        final nameCompare = a.variableName.compareTo(b.variableName);
        if (nameCompare != 0) return nameCompare;
        return a.filePath.compareTo(b.filePath);
      });

    return assets;
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

  static void validateNoDuplicateAccessors(List<AssetFile> assets) {
    final grouped = <String, List<AssetFile>>{};

    for (final asset in assets) {
      grouped.putIfAbsent(asset.accessor, () => []).add(asset);
    }

    final duplicates = grouped.entries
        .where((entry) => entry.value.length > 1)
        .toList();

    if (duplicates.isEmpty) return;

    final buffer = StringBuffer('Duplicate generated asset accessors found:');
    for (final duplicate in duplicates) {
      buffer.writeln('\n- ${duplicate.key}');
      for (final asset in duplicate.value) {
        buffer.writeln('  - ${asset.filePath}');
      }
    }
    buffer.writeln(
      '\nRename one of the files or enable folder structure mode.',
    );

    throw StateError(buffer.toString());
  }

  static AssetContent generateAssetContent(
    List<AssetFile> assets,
    String? root, {
    AssetStructure structure = AssetStructure.flat,
  }) {
    final content = StringBuffer();
    final flatAssets = structure == AssetStructure.tree
        ? <AssetFile>[]
        : assets;

    for (final asset in flatAssets) {
      _writeAssetField(content, asset, asset.variableName, root);
    }

    return AssetContent(
      fields: content.toString().trimRight(),
      nestedClasses: '',
    );
  }

  static AssetContent generateTreeAssetContent(
    List<AssetFile> assets,
    String? root,
  ) {
    return _generateFolderAccessors(assets, root);
  }

  static Future<void> _addFile(
    File file,
    String projectPath,
    Map<String, AssetFile> assetsByPath, {
    String? prefix,
    List<String>? warnings,
  }) async {
    final fileName = path.basename(file.path);
    if (AssetConstants.ignoredFileNames.contains(fileName)) return;

    final assetPath = _toPosixPath(path.relative(file.path, from: projectPath));
    if (_hasScaleDirectory(assetPath)) return;

    final baseName = path.basenameWithoutExtension(file.path);
    if (AssetConstants.filenameScaleRegex.hasMatch(baseName)) {
      warnings?.add(
        'Warning: $assetPath looks like a @Nx image variant. Flutter only '
        'treats scale folders like 2x/ or 3.0x/ as resolution variants.',
      );
    }

    try {
      final assetType = AssetTypeDetector.detectAssetType(assetPath);
      final variableName = _toDartIdentifier(baseName);
      final fullVariableName = prefix != null
          ? '$prefix.${assetType.folderName}.$variableName'
          : variableName;

      assetsByPath.putIfAbsent(
        assetPath,
        () => AssetFile(
          variableName: fullVariableName,
          filePath: assetPath,
          absolutePath: file.path,
          type: assetType,
          folderSegments: _folderSegmentsFor(assetPath),
        ),
      );
    } catch (e) {
      print('Skipping file: ${file.path} - $e');
    }
  }
}

Future<AssetGenerationResult> generateAsset({
  required List<String> paths,
  required String output,
  String? root,
  String projectDir = '.',
  bool recursive = true,
  AssetStructure structure = AssetStructure.flat,
  bool failOnDuplicates = true,
  Map<String, List<String>> semanticGroups = const {},
  bool verbose = false,
}) async {
  try {
    final projectPath = path.absolute(projectDir);
    final outputPath = _resolvePath(projectPath, output);
    await FilesHelper.createFolder(outputPath);

    final warnings = <String>[];
    final allAssets = await AssetProcessor.collectAssetsWithWarnings(
      paths,
      projectDir: projectPath,
      recursive: recursive,
      warnings: warnings,
    );

    if (failOnDuplicates || structure == AssetStructure.flat) {
      AssetProcessor.validateNoDuplicateAccessors(allAssets);
    }

    final groupedAssets = AssetProcessor.groupAssetsByType(allAssets);
    final semanticAssets = structure == AssetStructure.tree
        ? _buildSemanticAssets(allAssets, semanticGroups)
        : const <AssetFile>[];
    final treeAssets = [...allAssets, ...semanticAssets];
    final treeContent = structure == AssetStructure.tree
        ? AssetProcessor.generateTreeAssetContent(treeAssets, root)
        : _typedAssetFacadeContent();

    print(
      'Found ${allAssets.length} assets across ${groupedAssets.length} types',
    );
    for (final warning in warnings) {
      print(warning);
    }

    final imageContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.image] ?? [],
      root,
      structure: structure,
    );
    final svgContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.svg] ?? [],
      root,
      structure: structure,
    );
    final gifContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.gif] ?? [],
      root,
      structure: structure,
    );
    final audioContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.audio] ?? [],
      root,
      structure: structure,
    );
    final otherContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.other] ?? [],
      root,
      structure: structure,
    );

    final riveContent = AssetProcessor.generateAssetContent(
      groupedAssets[AssetType.rive] ?? [],
      root,
      structure: structure,
    );
    final riveFileContent = _generateRiveContentFile(
      riveAssetsRes
          .replaceFirst(contentKey, riveContent.fields)
          .replaceFirst(nestedContentKey, riveContent.nestedClasses),
      projectPath,
    );

    final assetFiles = structure == AssetStructure.tree
        ? {
            'assets.dart': assetsRes
                .replaceFirst(importPartKey, '')
                .replaceFirst('\n\nclass Assets', '\nclass Assets')
                .replaceFirst(contentKey, treeContent.fields)
                .replaceFirst(nestedContentKey, treeContent.nestedClasses),
          }
        : {
            'assets.dart': assetsRes
                .replaceFirst(importPartKey, _typedAssetPartDirectives)
                .replaceFirst(contentKey, treeContent.fields)
                .replaceFirst(nestedContentKey, treeContent.nestedClasses),
            'image_assets.dart': imageAssetsRes
                .replaceFirst(contentKey, imageContent.fields)
                .replaceFirst(nestedContentKey, imageContent.nestedClasses),
            'svg_assets.dart': svgAssetsRes
                .replaceFirst(contentKey, svgContent.fields)
                .replaceFirst(nestedContentKey, svgContent.nestedClasses),
            'gif_assets.dart': gifAssetsRes
                .replaceFirst(contentKey, gifContent.fields)
                .replaceFirst(nestedContentKey, gifContent.nestedClasses),
            'audio_assets.dart': audioAssetsRes
                .replaceFirst(contentKey, audioContent.fields)
                .replaceFirst(nestedContentKey, audioContent.nestedClasses),
            'other_assets.dart': otherAssetsRes
                .replaceFirst(contentKey, otherContent.fields)
                .replaceFirst(nestedContentKey, otherContent.nestedClasses),
            'rive_assets.dart': riveFileContent,
          };

    await _deleteStaleAssetFiles(outputPath, assetFiles.keys.toSet());
    await _writeAssetFiles(outputPath, assetFiles);

    if (verbose) {
      print('Generated asset files:');
      for (final asset in allAssets) {
        print(' - ${asset.accessor}: ${asset.filePath}');
      }
    }

    print('Successfully generated asset files in $outputPath');
    return AssetGenerationResult(assets: allAssets, warnings: warnings);
  } catch (e, stackTrace) {
    print('Error generating assets: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> _deleteStaleAssetFiles(
  String output,
  Set<String> generatedFileNames,
) async {
  const assetFileNames = {
    'assets.dart',
    'image_assets.dart',
    'svg_assets.dart',
    'gif_assets.dart',
    'audio_assets.dart',
    'other_assets.dart',
    'rive_assets.dart',
  };

  for (final fileName in assetFileNames.difference(generatedFileNames)) {
    final file = File(path.join(output, fileName));
    if (await file.exists()) {
      await file.delete();
    }
  }
}

Future<void> _writeAssetFiles(String output, Map<String, String> files) async {
  await Future.wait(
    files.entries.map(
      (entry) => FilesHelper.writeFile(
        pathFile: path.join(output, entry.key),
        content: entry.value,
      ),
    ),
  );
}

Future<RemoveUnusedAssetsResult> removeUnusedAssets({
  required List<String> resPaths,
  required String output,
  String? root,
  String projectDir = '.',
  bool recursive = true,
  AssetStructure structure = AssetStructure.flat,
  bool failOnDuplicates = true,
  Map<String, List<String>> semanticGroups = const {},
  bool dryRun = true,
  List<String> scanRoots = const ['lib'],
  bool verbose = false,
}) async {
  try {
    final projectPath = path.absolute(projectDir);
    print('Starting unused asset scan${dryRun ? ' (dry-run)' : ''}...');

    final allAssets = await AssetProcessor.collectAssets(
      resPaths,
      projectDir: projectPath,
      recursive: recursive,
    );

    if (failOnDuplicates || structure == AssetStructure.flat) {
      AssetProcessor.validateNoDuplicateAccessors(allAssets);
    }
    print('Found ${allAssets.length} total assets to check for usage');

    final scannedFiles = await _getAllTextFilesInDirs(projectPath, scanRoots);
    print('Scanning ${scannedFiles.length} files for asset usage...');

    final usageScanner = _AssetUsageScanner(
      allAssets,
      structure,
      semanticGroups: semanticGroups,
    );
    final usedAssetSet = <AssetFile>{};
    final warnings = <String>{};

    for (final file in scannedFiles) {
      final content = await file.readAsString();
      final usageResult = usageScanner.findUsedAssets(content);
      usedAssetSet.addAll(usageResult.assets);
      warnings.addAll(usageResult.warnings);
      if (usedAssetSet.length == allAssets.length) break;
    }

    for (final warning in warnings) {
      print(warning);
    }

    final usedAssets = <AssetFile>[];
    final unusedAssets = <AssetFile>[];
    for (final asset in allAssets) {
      if (usedAssetSet.contains(asset)) {
        usedAssets.add(asset);
      } else {
        unusedAssets.add(asset);
      }
    }

    print('Found ${unusedAssets.length} unused asset candidates');
    for (final asset in unusedAssets) {
      print(
        '${dryRun ? 'candidate' : 'removed'} ${asset.type.folderName} asset: ${asset.filePath}',
      );
    }

    if (!dryRun && unusedAssets.isNotEmpty) {
      await _deleteUnusedAssets(unusedAssets, projectPath);
      print('Regenerating asset files...');
      await generateAsset(
        paths: resPaths,
        output: output,
        root: root,
        projectDir: projectPath,
        recursive: recursive,
        structure: structure,
        failOnDuplicates: failOnDuplicates,
        semanticGroups: semanticGroups,
      );
      print('Asset cleanup completed successfully!');
    } else if (dryRun && unusedAssets.isNotEmpty) {
      print('Dry-run only. Re-run with --apply to delete these candidates.');
    } else {
      print('No unused assets found. Nothing to clean up.');
    }

    if (verbose) {
      for (final asset in usedAssets) {
        print('used ${asset.accessor}: ${asset.filePath}');
      }
    }

    return RemoveUnusedAssetsResult(
      unusedAssets: unusedAssets,
      usedAssets: usedAssets,
      warnings: warnings.toList(),
      dryRun: dryRun,
    );
  } catch (e, stackTrace) {
    print('Error during asset cleanup: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

class _AssetUsageScanner {
  final Map<String, AssetFile> _assetsByPath;
  final Map<String, AssetFile> _assetsByAccessor;
  final Map<_DynamicAssetUsage, List<AssetFile>> _dynamicUsageCache = {};
  final RegExp? _pathPattern;
  final RegExp? _accessorPattern;

  _AssetUsageScanner(
    List<AssetFile> assets,
    AssetStructure structure, {
    Map<String, List<String>> semanticGroups = const {},
  }) : this._({
         for (final asset in assets) asset.filePath: asset,
       }, _buildAssetsByAccessor(assets, structure, semanticGroups));

  _AssetUsageScanner._(this._assetsByPath, this._assetsByAccessor)
    : _pathPattern = _buildUsagePattern(_assetsByPath.keys),
      _accessorPattern = _buildUsagePattern(
        _assetsByAccessor.keys,
        wordBoundaries: true,
      );

  _AssetUsageResult findUsedAssets(String content) {
    final assets = <AssetFile>{};
    final warnings = <String>{};

    final pathPattern = _pathPattern;
    if (pathPattern != null) {
      for (final match in pathPattern.allMatches(content)) {
        final asset = _assetsByPath[match.group(0)];
        if (asset != null) assets.add(asset);
      }
    }

    final accessorPattern = _accessorPattern;
    if (accessorPattern != null) {
      for (final match in accessorPattern.allMatches(content)) {
        final asset = _assetsByAccessor[match.group(0)];
        if (asset != null) assets.add(asset);
      }
    }

    for (final usage in _findDynamicAssetUsages(content)) {
      final retainedAssets = _assetsMatchingDynamicUsage(usage);
      if (retainedAssets.isEmpty) continue;

      assets.addAll(retainedAssets);
      warnings.add(
        'Warning: kept ${retainedAssets.length} assets under '
        '${usage.prefix}${usage.extension ?? ''} because a dynamic asset path '
        'was found.',
      );
    }

    return _AssetUsageResult(assets: assets, warnings: warnings);
  }

  List<AssetFile> _assetsMatchingDynamicUsage(_DynamicAssetUsage usage) {
    return _dynamicUsageCache.putIfAbsent(
      usage,
      () => _assetsByPath.entries
          .where((entry) {
            final assetPath = entry.key;
            if (!assetPath.startsWith(usage.prefix)) return false;
            final extension = usage.extension;
            return extension == null || assetPath.endsWith(extension);
          })
          .map((entry) => entry.value)
          .toList(),
    );
  }
}

class _AssetUsageResult {
  final Set<AssetFile> assets;
  final Set<String> warnings;

  const _AssetUsageResult({required this.assets, required this.warnings});
}

class _DynamicAssetUsage {
  final String prefix;
  final String? extension;

  const _DynamicAssetUsage({required this.prefix, this.extension});

  @override
  bool operator ==(Object other) {
    return other is _DynamicAssetUsage &&
        other.prefix == prefix &&
        other.extension == extension;
  }

  @override
  int get hashCode => Object.hash(prefix, extension);
}

Iterable<_DynamicAssetUsage> _findDynamicAssetUsages(String content) sync* {
  final usages = <_DynamicAssetUsage>{};
  final interpolationPattern = RegExp(
    r'''["'](assets/[^"'\$]*(?:\$\w+|\$\{[^}]+\})[^"']*)["']''',
  );
  final concatenationPattern = RegExp(
    r'''["'](assets/[^"']*/)["']\s*\+[^;\n]*(?:\+\s*["']([^"']+)["'])''',
  );

  for (final match in interpolationPattern.allMatches(content)) {
    final usage = _dynamicUsageFromInterpolatedPath(match.group(1)!);
    if (usage != null) usages.add(usage);
  }

  for (final match in concatenationPattern.allMatches(content)) {
    usages.add(
      _DynamicAssetUsage(
        prefix: match.group(1)!,
        extension: _extensionFromSuffix(match.group(2)),
      ),
    );
  }

  yield* usages;
}

_DynamicAssetUsage? _dynamicUsageFromInterpolatedPath(String value) {
  final dynamicStart = _firstDynamicTokenStart(value);
  if (dynamicStart == -1) return null;

  final prefix = value.substring(0, dynamicStart);
  if (!prefix.startsWith('assets/') || !prefix.endsWith('/')) return null;

  return _DynamicAssetUsage(
    prefix: prefix,
    extension: _extensionFromSuffix(value.substring(dynamicStart)),
  );
}

int _firstDynamicTokenStart(String value) {
  final variableIndex = value.indexOf(RegExp(r'\$\w'));
  final expressionIndex = value.indexOf(r'${');

  if (variableIndex == -1) return expressionIndex;
  if (expressionIndex == -1) return variableIndex;
  return variableIndex < expressionIndex ? variableIndex : expressionIndex;
}

String? _extensionFromSuffix(String? value) {
  if (value == null) return null;
  final extensionTarget = value.startsWith('.') ? 'asset$value' : value;
  final extension = path.posix.extension(extensionTarget).toLowerCase();
  return extension.isEmpty ? null : extension;
}

Map<String, AssetFile> _buildAssetsByAccessor(
  List<AssetFile> assets,
  AssetStructure structure,
  Map<String, List<String>> semanticGroups,
) {
  final assetsByAccessor = <String, AssetFile>{};
  for (final asset in assets) {
    assetsByAccessor[asset.accessor] = asset;
  }

  if (structure == AssetStructure.tree) {
    final assetsByFilePath = {
      for (final asset in assets) asset.filePath: asset,
    };
    _addTreeAccessors(assetsByAccessor, assetsByFilePath, assets);
    _addTreeAccessors(
      assetsByAccessor,
      assetsByFilePath,
      _buildSemanticAssets(assets, semanticGroups),
    );
  }

  return assetsByAccessor;
}

void _addTreeAccessors(
  Map<String, AssetFile> assetsByAccessor,
  Map<String, AssetFile> assetsByFilePath,
  List<AssetFile> assets,
) {
  for (final entry in _buildTreeAccessorsByPath(assets).entries) {
    final asset = assetsByFilePath[entry.key];
    if (asset != null) {
      assetsByAccessor[entry.value] = asset;
    }
  }
}

RegExp? _buildUsagePattern(
  Iterable<String> values, {
  bool wordBoundaries = false,
}) {
  final sortedValues =
      values.where((value) => value.isNotEmpty).toSet().toList()
        ..sort((a, b) => b.length.compareTo(a.length));
  if (sortedValues.isEmpty) return null;

  final pattern = sortedValues.map(RegExp.escape).join('|');
  return RegExp(
    wordBoundaries ? '\\b(?:$pattern)\\b' : pattern,
    caseSensitive: true,
  );
}

Future<void> _deleteUnusedAssets(
  List<AssetFile> assets,
  String projectPath,
) async {
  for (final asset in assets) {
    final file = File(asset.absolutePath);
    if (await file.exists()) {
      await file.delete();
    }

    if (asset.type == AssetType.image) {
      await _deleteImageVariants(asset, projectPath);
    }
  }
}

Future<void> _deleteImageVariants(AssetFile asset, String projectPath) async {
  final assetFile = File(asset.absolutePath);
  final parentDir = Directory(path.dirname(assetFile.path));
  if (!await parentDir.exists()) return;

  await for (final entity in parentDir.list(followLinks: false)) {
    if (entity is! Directory) continue;
    if (!AssetConstants.scaleDirectoryRegex.hasMatch(
      path.basename(entity.path),
    )) {
      continue;
    }

    final variantFile = File(
      path.join(entity.path, path.basename(asset.filePath)),
    );
    if (await variantFile.exists()) {
      print(
        'removed image asset variant: ${_toPosixPath(path.relative(variantFile.path, from: projectPath))}',
      );
      await variantFile.delete();
    }
  }
}

Future<List<File>> _getAllTextFilesInDirs(
  String projectPath,
  List<String> scanRoots,
) async {
  final files = <File>[];
  const textExtensions = {
    '.dart',
    '.yaml',
    '.yml',
    '.json',
    '.md',
    '.xml',
    '.gradle',
    '.kt',
    '.swift',
  };

  for (final root in scanRoots) {
    final resolvedRoot = _resolvePath(projectPath, root);
    final file = File(resolvedRoot);
    final dir = Directory(resolvedRoot);

    if (await file.exists()) {
      if (textExtensions.contains(path.extension(file.path).toLowerCase())) {
        files.add(file);
      }
    } else if (await dir.exists()) {
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File &&
            textExtensions.contains(
              path.extension(entity.path).toLowerCase(),
            )) {
          files.add(entity);
        }
      }
    }
  }

  return files;
}

String _generateRiveContentFile(String riveContentFile, String projectPath) {
  final riveConfigPath = path.join(projectPath, AssetConstants.riveConfigFile);

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

  final states = artboardValue['states'];
  if (states?.isNotEmpty == true) {
    final statesContent = _generateRiveStatesContent(states);
    content +=
        '\n${riveAssetsStatesRes.replaceAll(contentKey, statesContent).replaceAll(classNameKey, formatClassName(artboardKey))}';
  }

  final inputs = artboardValue['inputs'];
  if (inputs?.isNotEmpty == true) {
    final inputsContent = _generateRiveInputsContent(inputs);
    content +=
        '\n${riveAssetsInputsRes.replaceAll(contentKey, inputsContent).replaceAll(classNameKey, formatClassName(artboardKey))}';
  }

  final machines = artboardValue['machines'];
  if (machines?.isNotEmpty == true) {
    final machinesContent = _generateRiveMachinesContent(machines);
    content +=
        '\n${riveAssetsMachinesRes.replaceAll(contentKey, machinesContent).replaceAll(classNameKey, formatClassName(artboardKey))}';
  }

  content +=
      '\n${riveAssetsArtboardRes.replaceAll(classNameKey, formatClassName(artboardKey)).replaceAll(artboardKey, artboardKey)}';

  return content;
}

String _generateRiveStatesContent(List<dynamic> states) {
  var content = '';
  final statesList = <String>[];

  for (final element in states) {
    final camelCaseName = _toDartIdentifier(element.toString());
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
    final camelCaseName = _toDartIdentifier(element.toString());
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
    final camelCaseName = _toDartIdentifier(element.toString());
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

const _typedAssetPartDirectives = '''part 'audio_assets.dart';
part 'gif_assets.dart';
part 'image_assets.dart';
part 'other_assets.dart';
part 'rive_assets.dart';
part 'svg_assets.dart';
''';

AssetContent _typedAssetFacadeContent() {
  return const AssetContent(
    fields: '''

  static const ImageAssets image = ImageAssets();

  static const SvgAssets svg = SvgAssets();

  static const GifAssets gif = GifAssets();

  static const AudioAssets audio = AudioAssets();

  static const RiveAssets rive = RiveAssets();

  static const OtherAssets other = OtherAssets();''',
    nestedClasses: '',
  );
}

List<AssetFile> _buildSemanticAssets(
  List<AssetFile> assets,
  Map<String, List<String>> semanticGroups,
) {
  if (semanticGroups.isEmpty) return const [];

  final semanticAssets = <AssetFile>[];
  final usedGroupNames = <String>{};

  for (final entry in semanticGroups.entries) {
    final groupName = _toDartIdentifier(entry.key);
    if (groupName.isEmpty) {
      throw AssetGenerationException(
        'Invalid semantic asset group: ${entry.key}',
      );
    }
    if (!usedGroupNames.add(groupName)) {
      throw AssetGenerationException(
        'Duplicate semantic asset group: $groupName',
      );
    }

    for (final groupPath in entry.value) {
      final prefix = _normalizeAssetPrefix(groupPath);

      for (final asset in assets) {
        if (!asset.filePath.startsWith(prefix)) continue;

        final relativePath = asset.filePath.substring(prefix.length);
        final relativeSegments = _folderSegmentsFor(relativePath);
        final semanticSegments = [groupName, ...relativeSegments];
        if (_isPhysicalTreeAlias(asset.folderSegments, semanticSegments)) {
          continue;
        }

        semanticAssets.add(
          AssetFile(
            variableName: asset.variableName,
            filePath: asset.filePath,
            absolutePath: asset.absolutePath,
            type: asset.type,
            folderSegments: semanticSegments,
          ),
        );
      }
    }
  }

  return semanticAssets;
}

bool _isPhysicalTreeAlias(
  List<String> physicalSegments,
  List<String> segments,
) {
  if (physicalSegments.length != segments.length) return false;
  for (var index = 0; index < physicalSegments.length; index++) {
    if (physicalSegments[index] != segments[index]) return false;
  }
  return true;
}

String _normalizeAssetPrefix(String value) {
  final normalized = _toPosixPath(path.posix.normalize(value));
  return normalized.endsWith('/') ? normalized : '$normalized/';
}

AssetContent _generateFolderAccessors(List<AssetFile> assets, String? root) {
  final rootNode = _buildFolderTree(assets);
  if (rootNode.children.isEmpty) return const AssetContent.empty();

  final fields = StringBuffer();
  final nestedClasses = StringBuffer();
  final rootMemberNames = <String>{};

  for (final node in _sortedNodes(rootNode.children)) {
    final memberName = _uniqueMemberName(node.name, rootMemberNames);
    final className = _folderClassName(node.segments);
    fields.writeln('\n  static const $className $memberName = $className();');
    _writeFolderClass(nestedClasses, node, root);
  }

  return AssetContent(
    fields: fields.toString().trimRight(),
    nestedClasses: nestedClasses.toString().trimRight(),
  );
}

_AssetFolderNode _buildFolderTree(List<AssetFile> assets) {
  final root = _AssetFolderNode('', const []);

  for (final asset in assets) {
    if (asset.folderSegments.isEmpty) continue;

    var node = root;
    for (final segment in asset.folderSegments) {
      node = node.children.putIfAbsent(
        segment,
        () => _AssetFolderNode(segment, [...node.segments, segment]),
      );
    }
    node.assets.add(asset);
  }

  return root;
}

void _writeFolderClass(
  StringBuffer buffer,
  _AssetFolderNode node,
  String? root,
) {
  final className = _folderClassName(node.segments);
  final memberNames = <String>{};

  buffer.writeln('\nclass $className {');
  buffer.writeln('  const $className();');

  for (final child in _sortedNodes(node.children)) {
    final childMemberName = _uniqueMemberName(child.name, memberNames);
    final childClassName = _folderClassName(child.segments);
    buffer.writeln(
      '\n  $childClassName get $childMemberName => const $childClassName();',
    );
  }

  final sortedAssets = [...node.assets]
    ..sort((a, b) {
      final nameCompare = a.variableName.compareTo(b.variableName);
      if (nameCompare != 0) return nameCompare;
      return a.filePath.compareTo(b.filePath);
    });
  for (final asset in sortedAssets) {
    final memberName = _uniqueAssetMemberName(asset, memberNames);
    _writeAssetField(buffer, asset, memberName, root);
  }

  buffer.writeln('}');

  for (final child in _sortedNodes(node.children)) {
    _writeFolderClass(buffer, child, root);
  }
}

List<_AssetFolderNode> _sortedNodes(Map<String, _AssetFolderNode> nodes) {
  return nodes.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

void _writeAssetField(
  StringBuffer buffer,
  AssetFile asset,
  String memberName,
  String? root,
) {
  if (root != null) {
    buffer.writeln('\n  // [$root/${asset.filePath}]');
  }

  final line = '  String get $memberName => \'${asset.filePath}\';';
  if (line.length > 80) {
    buffer.writeln('  String get $memberName =>\n      \'${asset.filePath}\';');
  } else {
    buffer.writeln(line);
  }
}

Map<String, String> _buildTreeAccessorsByPath(List<AssetFile> assets) {
  final rootNode = _buildFolderTree(assets);
  final accessorsByPath = <String, String>{};
  final rootMemberNames = <String>{};

  for (final node in _sortedNodes(rootNode.children)) {
    final memberName = _uniqueMemberName(node.name, rootMemberNames);
    _collectTreeAccessors(node, 'Assets.$memberName', accessorsByPath);
  }

  return accessorsByPath;
}

void _collectTreeAccessors(
  _AssetFolderNode node,
  String prefix,
  Map<String, String> accessorsByPath,
) {
  final memberNames = <String>{};
  final sortedAssets = [...node.assets]
    ..sort((a, b) {
      final nameCompare = a.variableName.compareTo(b.variableName);
      if (nameCompare != 0) return nameCompare;
      return a.filePath.compareTo(b.filePath);
    });

  for (final child in _sortedNodes(node.children)) {
    final childMemberName = _uniqueMemberName(child.name, memberNames);
    _collectTreeAccessors(child, '$prefix.$childMemberName', accessorsByPath);
  }

  for (final asset in sortedAssets) {
    final memberName = _uniqueAssetMemberName(asset, memberNames);
    accessorsByPath[asset.filePath] = '$prefix.$memberName';
  }
}

String _uniqueAssetMemberName(AssetFile asset, Set<String> usedNames) {
  if (usedNames.add(asset.variableName)) return asset.variableName;

  final extension = _toDartIdentifier(
    path.extension(asset.filePath).replaceFirst('.', ''),
  );
  final suffix = extension.isEmpty ? 'Asset' : formatClassName(extension);
  return _uniqueMemberName('${asset.variableName}$suffix', usedNames);
}

String _uniqueMemberName(String name, Set<String> usedNames) {
  if (usedNames.add(name)) return name;

  final baseName = '${name}Assets';
  if (usedNames.add(baseName)) return baseName;

  var index = 2;
  while (!usedNames.add('$baseName$index')) {
    index++;
  }
  return '$baseName$index';
}

String _folderClassName(List<String> segments) {
  final segmentName = segments.map(formatClassName).join();
  return '${segmentName}Assets';
}

class _AssetFolderNode {
  final String name;
  final List<String> segments;
  final Map<String, _AssetFolderNode> children = {};
  final List<AssetFile> assets = [];

  _AssetFolderNode(this.name, this.segments);
}

List<String> _folderSegmentsFor(String assetPath) {
  final dir = path.posix.dirname(assetPath);
  if (dir == '.') return const [];

  final segments = dir
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.isNotEmpty && segments.first == 'assets') {
    segments.removeAt(0);
  }

  return segments
      .map(_toDartIdentifier)
      .where((segment) => segment.isNotEmpty)
      .toList();
}

String _toDartIdentifier(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^A-Za-z0-9_]+'), ' ');
  var identifier = camelCase(cleaned);

  if (identifier.isEmpty) return identifier;
  if (RegExp(r'^\d').hasMatch(identifier)) {
    identifier = 'asset$identifier';
  }
  if (_reservedWords.contains(identifier)) {
    identifier = '${identifier}Asset';
  }

  return identifier;
}

bool _hasScaleDirectory(String assetPath) {
  final segments = path.posix.split(assetPath);
  if (segments.length <= 1) return false;

  return segments
      .take(segments.length - 1)
      .any(AssetConstants.scaleDirectoryRegex.hasMatch);
}

String _resolvePath(String projectPath, String targetPath) {
  return path.normalize(
    path.isAbsolute(targetPath)
        ? targetPath
        : path.join(projectPath, targetPath),
  );
}

String _toPosixPath(String value) {
  return path.split(value).join('/');
}

const _reservedWords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
};

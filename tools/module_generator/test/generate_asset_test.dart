import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/generate_asset.dart';
import 'package:module_generator/generator/generate_assets.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('asset_generator_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('reads assets from pubspec and output from assets.yaml', () async {
    await _writeFile(tempDir, 'pubspec.yaml', '''
name: test_app
flutter:
  assets:
    - assets/images/
''');
    await _writeFile(tempDir, 'assets.yaml', '''
flutter:
  assets_generated: lib/generated/
''');

    final config = await readConfig(projectDir: tempDir.path);
    final assetConfig = AssetConfig.fromYaml(config!);

    expect(assetConfig.assetPaths, ['assets/images/']);
    expect(assetConfig.outputPath, 'lib/generated/');
  });

  test('collects nested assets and skips resolution variant folders', () async {
    await _writeFile(tempDir, 'assets/images/logo.png', 'base');
    await _writeFile(tempDir, 'assets/images/2.0x/logo.png', '2x');
    await _writeFile(tempDir, 'assets/images/icons/add.svg', '<svg />');

    final assets = await AssetProcessor.collectAssets([
      'assets/images/',
    ], projectDir: tempDir.path);

    expect(assets.map((asset) => asset.filePath), [
      'assets/images/logo.png',
      'assets/images/icons/add.svg',
    ]);
    expect(assets.map((asset) => asset.accessor), [
      'Assets.image.logo',
      'Assets.svg.add',
    ]);
  });

  test('warns for filename-style resolution variants', () async {
    await _writeFile(tempDir, 'assets/images/logo.png', 'base');
    await _writeFile(tempDir, 'assets/images/logo@2x.png', '2x');
    final warnings = <String>[];

    final assets = await AssetProcessor.collectAssetsWithWarnings(
      ['assets/images/'],
      projectDir: tempDir.path,
      warnings: warnings,
    );

    expect(assets.map((asset) => asset.filePath), [
      'assets/images/logo.png',
      'assets/images/logo@2x.png',
    ]);
    expect(warnings.single, contains('@Nx image variant'));
  });

  test('detects duplicate flat accessors', () async {
    await _writeFile(tempDir, 'assets/images/home/logo.png', 'home');
    await _writeFile(tempDir, 'assets/images/market/logo.png', 'market');

    final assets = await AssetProcessor.collectAssets([
      'assets/images/',
    ], projectDir: tempDir.path);

    expect(
      () => AssetProcessor.validateNoDuplicateAccessors(assets),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'tree folder segments follow asset path from assets directory',
    () async {
      await _writeFile(
        tempDir,
        'assets/images/svg/ic_user_avatar.svg',
        '<svg />',
      );
      await _writeFile(tempDir, 'assets/icons/ic_en.svg', '<svg />');

      final assets = await AssetProcessor.collectAssets([
        'assets/images/',
        'assets/icons/',
      ], projectDir: tempDir.path);

      expect(assets.map((asset) => asset.filePath), [
        'assets/icons/ic_en.svg',
        'assets/images/svg/ic_user_avatar.svg',
      ]);
      expect(assets.map((asset) => asset.folderSegments), [
        ['icons'],
        ['images', 'svg'],
      ]);
    },
  );

  test('tree structure does not emit nested assets as typed flat aliases', () {
    final assets = [
      AssetFile(
        variableName: 'logo',
        filePath: 'assets/images/png/logo.png',
        absolutePath: path.join(tempDir.path, 'assets/images/png/logo.png'),
        type: AssetType.image,
        folderSegments: ['images', 'png'],
      ),
      AssetFile(
        variableName: 'nativeSplashIcon',
        filePath: 'assets/images/native_splash_icon.png',
        absolutePath: path.join(
          tempDir.path,
          'assets/images/native_splash_icon.png',
        ),
        type: AssetType.image,
        folderSegments: ['images'],
      ),
    ];

    final content = AssetProcessor.generateTreeAssetContent(
      assets,
      'apps/main',
    );

    expect(content.fields, contains('static const ImagesAssets images'));
    expect(content.fields, isNot(contains('final String nativeSplashIcon')));
    expect(content.fields, isNot(contains('final String logo')));
    expect(content.nestedClasses, contains('String get nativeSplashIcon'));
    expect(content.nestedClasses, contains('ImagesPngAssets get png'));
    expect(content.nestedClasses, contains('String get logo'));
  });

  test(
    'remove unused assets is dry-run by default and keeps raw path usages',
    () async {
      await _writeFile(tempDir, 'pubspec.yaml', '''
name: test_app
flutter:
  assets:
    - assets/images/
''');
      await _writeFile(tempDir, 'assets.yaml', '''
flutter:
  assets_generated: lib/generated/
''');
      await _writeFile(tempDir, 'assets/images/used.png', 'used');
      await _writeFile(tempDir, 'assets/images/raw.png', 'raw');
      await _writeFile(tempDir, 'assets/images/unused.png', 'unused');
      await _writeFile(tempDir, 'lib/main.dart', '''
const generated = Assets.image.used;
const raw = 'assets/images/raw.png';
''');

      final result = await removeUnusedAssetsWithOptions(
        RemoveUnusedAssetsOptions(
          projectDir: tempDir.path,
          structure: AssetStructure.flat,
        ),
      );

      expect(result.dryRun, isTrue);
      expect(result.usedAssets.map((asset) => asset.filePath), [
        'assets/images/raw.png',
        'assets/images/used.png',
      ]);
      expect(result.unusedAssets.single.filePath, 'assets/images/unused.png');
      expect(
        await File(
          path.join(tempDir.path, 'assets/images/unused.png'),
        ).exists(),
        isTrue,
      );
    },
  );

  test('remove unused assets keeps tree accessor usages', () async {
    await _writeFile(tempDir, 'pubspec.yaml', '''
name: test_app
flutter:
  assets:
    - assets/images/
''');
    await _writeFile(tempDir, 'assets.yaml', '''
flutter:
  assets_generated: lib/generated/
  asset_generation:
    structure: tree
''');
    await _writeFile(tempDir, 'assets/images/icons/used.png', 'used');
    await _writeFile(tempDir, 'assets/images/icons/unused.png', 'unused');
    await _writeFile(tempDir, 'lib/main.dart', '''
const generated = Assets.images.icons.used;
''');

    final result = await removeUnusedAssetsWithOptions(
      RemoveUnusedAssetsOptions(projectDir: tempDir.path),
    );

    expect(result.usedAssets.single.filePath, 'assets/images/icons/used.png');
    expect(
      result.unusedAssets.single.filePath,
      'assets/images/icons/unused.png',
    );
  });
}

Future<void> _writeFile(
  Directory tempDir,
  String relativePath,
  String content,
) async {
  final file = File(path.join(tempDir.path, relativePath));
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/generate_asset.dart';
import 'package:module_generator/generator/generate_assets.dart' as generator;
import 'package:module_generator/generator/generate_assets.dart'
    show AssetFile, AssetProcessor, AssetStructure, AssetType;
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

  test('reads semantic asset groups from config', () async {
    await _writeFile(tempDir, 'pubspec.yaml', '''
name: test_app
flutter:
  assets:
    - assets/lotties/
''');
    await _writeFile(tempDir, 'assets.yaml', '''
flutter:
  assets_generated: lib/generated/
  asset_generation:
    semantic_groups:
      lotties:
        - assets/lotties/
      data:
        - assets/data/
''');

    final config = await readConfig(projectDir: tempDir.path);
    final assetConfig = AssetConfig.fromYaml(config!);

    expect(assetConfig.semanticGroups, {
      'lotties': ['assets/lotties/'],
      'data': ['assets/data/'],
    });
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

  test('generate asset supports semantic tree aliases', () async {
    await _writeFile(tempDir, 'assets/lotties/onboarding/intro.json', '{}');
    await _writeFile(tempDir, 'assets/data/countries.json', '{}');

    await generator.generateAsset(
      paths: ['assets/lotties/', 'assets/data/'],
      output: 'lib/generated/',
      projectDir: tempDir.path,
      structure: AssetStructure.tree,
      semanticGroups: {
        'animation': ['assets/lotties/'],
        'data': ['assets/data/'],
      },
    );

    final generated = await File(
      path.join(tempDir.path, 'lib/generated/assets.dart'),
    ).readAsString();

    expect(generated, contains('static const AnimationAssets animation'));
    expect(generated, contains('static const DataAssets data'));
    expect(generated, contains('AnimationOnboardingAssets get onboarding'));
    expect(generated, contains('String get intro'));
    expect(generated, contains('String get countries'));
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

  test('remove unused assets keeps semantic alias usages', () async {
    await _writeFile(tempDir, 'pubspec.yaml', '''
name: test_app
flutter:
  assets:
    - assets/lotties/
''');
    await _writeFile(tempDir, 'assets.yaml', '''
flutter:
  assets_generated: lib/generated/
  asset_generation:
    structure: tree
    semantic_groups:
      animation:
        - assets/lotties/
''');
    await _writeFile(tempDir, 'assets/lotties/onboarding/intro.json', '{}');
    await _writeFile(tempDir, 'assets/lotties/onboarding/unused.json', '{}');
    await _writeFile(tempDir, 'lib/main.dart', '''
const intro = Assets.animation.onboarding.intro;
''');

    final result = await removeUnusedAssetsWithOptions(
      RemoveUnusedAssetsOptions(projectDir: tempDir.path),
    );

    expect(
      result.usedAssets.single.filePath,
      'assets/lotties/onboarding/intro.json',
    );
    expect(
      result.unusedAssets.single.filePath,
      'assets/lotties/onboarding/unused.json',
    );
  });

  test('remove unused assets keeps dynamic interpolation matches', () async {
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
    await _writeFile(tempDir, 'assets/images/durians/monthong.png', 'used');
    await _writeFile(tempDir, 'assets/images/durians/other.png', 'used');
    await _writeFile(tempDir, 'assets/images/durians/readme.txt', 'unused');
    await _writeFile(tempDir, 'assets/images/icons/add.svg', '<svg />');
    await _writeFile(tempDir, 'lib/main.dart', r'''
String durianPath(String value) => 'assets/images/durians/$value.png';
''');

    final result = await removeUnusedAssetsWithOptions(
      RemoveUnusedAssetsOptions(projectDir: tempDir.path),
    );

    expect(result.usedAssets.map((asset) => asset.filePath), [
      'assets/images/durians/monthong.png',
      'assets/images/durians/other.png',
    ]);
    expect(
      result.unusedAssets.map((asset) => asset.filePath),
      unorderedEquals([
        'assets/images/icons/add.svg',
        'assets/images/durians/readme.txt',
      ]),
    );
    expect(result.warnings.single, contains('dynamic asset path'));
  });

  test('remove unused assets keeps dynamic concatenation matches', () async {
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
    await _writeFile(tempDir, 'assets/images/icons/add.svg', '<svg />');
    await _writeFile(tempDir, 'assets/images/icons/remove.svg', '<svg />');
    await _writeFile(tempDir, 'assets/images/icons/add.png', 'unused');
    await _writeFile(tempDir, 'assets/images/other.svg', '<svg />');
    await _writeFile(tempDir, 'lib/main.dart', '''
String iconPath(String name) => 'assets/images/icons/' + name + '.svg';
''');

    final result = await removeUnusedAssetsWithOptions(
      RemoveUnusedAssetsOptions(projectDir: tempDir.path),
    );

    expect(result.usedAssets.map((asset) => asset.filePath), [
      'assets/images/icons/add.svg',
      'assets/images/icons/remove.svg',
    ]);
    expect(
      result.unusedAssets.map((asset) => asset.filePath),
      unorderedEquals([
        'assets/images/icons/add.png',
        'assets/images/other.svg',
      ]),
    );
    expect(result.warnings.single, contains('dynamic asset path'));
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

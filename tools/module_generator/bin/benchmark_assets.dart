import 'dart:io';

import 'package:module_generator/common/file_helper.dart';
import 'package:module_generator/generator/generate_assets.dart';
import 'package:path/path.dart' as path;

Future<void> main(List<String> arguments) async {
  final assetCount = arguments.isEmpty ? 1000 : int.parse(arguments.first);
  final projectDir = await Directory.systemTemp.createTemp(
    'asset_generator_benchmark_',
  );

  try {
    final setupStopwatch = Stopwatch()..start();
    await _writeBenchmarkProject(projectDir, assetCount);
    setupStopwatch.stop();

    final generateStopwatch = Stopwatch()..start();
    final generationResult = await generateAsset(
      paths: const ['assets/images/', 'assets/lotties/', 'assets/data/'],
      output: 'lib/generated/',
      projectDir: projectDir.path,
      structure: AssetStructure.tree,
      semanticGroups: const {
        'animation': ['assets/lotties/'],
        'data': ['assets/data/'],
      },
    );
    generateStopwatch.stop();

    final cleanupStopwatch = Stopwatch()..start();
    final cleanupResult = await removeUnusedAssets(
      resPaths: const ['assets/images/', 'assets/lotties/', 'assets/data/'],
      output: 'lib/generated/',
      projectDir: projectDir.path,
      structure: AssetStructure.tree,
      semanticGroups: const {
        'animation': ['assets/lotties/'],
        'data': ['assets/data/'],
      },
      dryRun: true,
    );
    cleanupStopwatch.stop();

    print('Asset generator benchmark');
    print('project: ${projectDir.path}');
    print('assets: ${generationResult.assets.length}');
    print('setup_ms: ${setupStopwatch.elapsedMilliseconds}');
    print('generate_ms: ${generateStopwatch.elapsedMilliseconds}');
    print('remove_unused_ms: ${cleanupStopwatch.elapsedMilliseconds}');
    print('used_assets: ${cleanupResult.usedAssets.length}');
    print('unused_assets: ${cleanupResult.unusedAssets.length}');
    print('warnings: ${cleanupResult.warnings.length}');
  } finally {
    await projectDir.delete(recursive: true);
  }
}

Future<void> _writeBenchmarkProject(
  Directory projectDir,
  int assetCount,
) async {
  await _writeFile(projectDir, 'pubspec.yaml', '''
name: asset_generator_benchmark
flutter:
  assets:
    - assets/images/
    - assets/lotties/
    - assets/data/
''');
  await _writeFile(projectDir, 'assets.yaml', '''
flutter:
  assets_generated: lib/generated/
  asset_generation:
    structure: tree
    semantic_groups:
      animation:
        - assets/lotties/
      data:
        - assets/data/
''');

  for (var index = 0; index < assetCount; index++) {
    final section = index % 20;
    await _writeFile(
      projectDir,
      'assets/images/section_$section/icon_$index.png',
      'image $index',
    );
  }

  final jsonCount = (assetCount / 10).ceil();
  for (var index = 0; index < jsonCount; index++) {
    await _writeFile(
      projectDir,
      'assets/lotties/onboarding/animation_$index.json',
      '{}',
    );
    await _writeFile(projectDir, 'assets/data/data_$index.json', '{}');
  }

  await _writeFile(projectDir, 'lib/main.dart', r'''
const firstIcon = Assets.images.section0.icon0;
const firstAnimation = Assets.animation.onboarding.animation0;
String dynamicIcon(String value) => 'assets/images/section_1/$value.png';
''');
}

Future<void> _writeFile(
  Directory projectDir,
  String relativePath,
  String content,
) async {
  await FilesHelper.writeFile(
    pathFile: path.join(projectDir.path, relativePath),
    content: content,
  );
}

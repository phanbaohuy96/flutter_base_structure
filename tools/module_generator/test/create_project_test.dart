import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/generator/create_project.dart';
import 'package:path/path.dart' as path;

const _oldDisplayName = 'My Flutter Base';
const _oldSlug = 'my_flutter_base';
const _oldBasePackage = 'com.pbh.myflutterbase';
const _oldPackagePath = 'com/pbh/myflutterbase';
const _oldSigningDir = 'my_flutter_base';

void main() {
  late Directory tempDir;
  late Directory templateDir;
  late Directory outputBaseDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('create_project_test_');
    templateDir = Directory(path.join(tempDir.path, 'template'));
    outputBaseDir = Directory(path.join(tempDir.path, 'output'));
    await _createTemplateFixture(templateDir);
    await outputBaseDir.create(recursive: true);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('derives flavor identities from base package and display name', () {
    final identity = ProjectIdentity(
      displayName: 'Example Mobile',
      slug: 'example_mobile',
      basePackage: 'com.example.mobile',
    );

    expect(identity.devPackage, 'com.example.mobile.dev');
    expect(identity.stagingPackage, 'com.example.mobile.staging');
    expect(identity.sandboxPackage, 'com.example.mobile.sandbox');
    expect(identity.prodPackage, 'com.example.mobile');
    expect(identity.devDisplayName, 'Example Mobile DEV');
    expect(identity.packagePath, 'com/example/mobile');
  });

  test('rejects invalid slug and package inputs', () async {
    final generator = CreateProjectGenerator();
    final destination = path.join(outputBaseDir.path, 'invalid');

    await expectLater(
      generator.run(
        CreateProjectOptions(
          templateRoot: templateDir.path,
          destination: destination,
          identity: ProjectIdentity(
            displayName: 'Bad App',
            slug: 'Bad-App',
            basePackage: 'com.bad.app',
          ),
          runPostGeneration: false,
        ),
      ),
      throwsA(isA<CreateProjectException>()),
    );

    await expectLater(
      generator.run(
        CreateProjectOptions(
          templateRoot: templateDir.path,
          destination: destination,
          identity: ProjectIdentity(
            displayName: 'Bad App',
            slug: 'bad_app',
            basePackage: 'Com.Bad.App',
          ),
          runPostGeneration: false,
        ),
      ),
      throwsA(isA<CreateProjectException>()),
    );
  });

  test('copies template and rewrites project identity', () async {
    final destination = path.join(outputBaseDir.path, 'example_mobile');

    final result = await CreateProjectGenerator().run(
      CreateProjectOptions(
        templateRoot: templateDir.path,
        destination: destination,
        identity: ProjectIdentity(
          displayName: 'Example Mobile',
          slug: 'example_mobile',
          basePackage: 'com.example.mobile',
        ),
        runPostGeneration: false,
      ),
    );

    expect(result.destination, destination);
    expect(result.remainingIdentityFiles, isEmpty);
    expect(File(path.join(destination, '.git', 'HEAD')).existsSync(), isFalse);
    expect(
      File(path.join(destination, '.claude', 'settings.json')).existsSync(),
      isFalse,
    );
    expect(File(path.join(destination, 'AGENTS.md')).existsSync(), isTrue);

    final pubspec = await _read(destination, 'apps/main/pubspec.yaml');
    expect(pubspec, contains('name: example_mobile'));
    expect(pubspec, contains('description: "Example Mobile"'));

    final identifiers = await _read(
      destination,
      'apps/main/app_identifier.yaml',
    );
    expect(identifiers, contains('package: "com.example.mobile.dev"'));
    expect(identifiers, contains('name: "Example Mobile DEV"'));
    expect(identifiers, contains('package: "com.example.mobile"'));

    final buildGradle = await _read(
      destination,
      'apps/main/android/app/build.gradle',
    );
    expect(buildGradle, contains("namespace 'com.example.mobile'"));

    final mainActivity = await _read(
      destination,
      'apps/main/android/app/src/main/kotlin/com/example/mobile/MainActivity.kt',
    );
    expect(mainActivity, contains('package com.example.mobile'));
    expect(
      File(
        path.join(
          destination,
          path.join(
            'apps/main/android/app/src/main/kotlin',
            _oldPackagePath,
            'MainActivity.kt',
          ),
        ),
      ).existsSync(),
      isFalse,
    );

    final manifest = await _read(destination, 'apps/main/web/manifest.json');
    expect(manifest, contains('"name": "Example Mobile"'));
    expect(manifest, contains('"short_name": "Example Mobile"'));

    final localizations = await _read(
      destination,
      'apps/main/lib/l10n/localizations.csv',
    );
    expect(localizations, contains('Powered by Example Mobile'));
    expect(localizations, contains('Được cung cấp bởi Example Mobile'));

    final fastfile = await _read(destination, 'apps/main/fastlane/Fastfile');
    expect(fastfile, contains('package_name: "com.example.mobile"'));

    final distConfig = await _read(destination, 'apps/main/dist_config.sh');
    expect(distConfig, contains('ios/signing_res/example_mobile/development'));
    expect(
      Directory(
        path.join(destination, 'apps/main/ios/signing_res/example_mobile'),
      ).existsSync(),
      isTrue,
    );
  });

  test('dry run does not create destination', () async {
    final destination = path.join(outputBaseDir.path, 'dry_run_app');

    final result = await CreateProjectGenerator().run(
      CreateProjectOptions(
        templateRoot: templateDir.path,
        destination: destination,
        identity: ProjectIdentity(
          displayName: 'Dry Run App',
          slug: 'dry_run_app',
          basePackage: 'com.example.dryrun',
        ),
        dryRun: true,
        runPostGeneration: false,
      ),
    );

    expect(result.dryRun, isTrue);
    expect(result.changedFiles, contains('apps/main/app_identifier.yaml'));
    expect(Directory(destination).existsSync(), isFalse);
  });
}

Future<void> _createTemplateFixture(Directory root) async {
  await _write(root, 'AGENTS.md', '''
# AGENTS
Current template identity: $_oldDisplayName
Base package ID: $_oldBasePackage
''');
  await _write(root, 'README.md', '''
# $_oldDisplayName
Signing path: apps/main/ios/signing_res/$_oldSigningDir/
''');
  await _write(root, '.git/HEAD', 'ref: refs/heads/master');
  await _write(root, '.claude/settings.json', '{}');
  await _write(
    root,
    'tools/module_generator/pubspec.yaml',
    'name: module_generator',
  );
  await _write(root, 'apps/main/app_identifier.yaml', '''
android:
  dev:
    package: $_oldBasePackage.dev
    name: $_oldDisplayName DEV
  staging:
    package: $_oldBasePackage.staging
    name: $_oldDisplayName STAGING
  sandbox:
    package: $_oldBasePackage.sandbox
    name: $_oldDisplayName SANDBOX
  prod:
    package: $_oldBasePackage
    name: $_oldDisplayName
ios:
  dev:
    package: $_oldBasePackage.dev
    name: $_oldDisplayName DEV
  staging:
    package: $_oldBasePackage.staging
    name: $_oldDisplayName STAGING
  sandbox:
    package: $_oldBasePackage.sandbox
    name: $_oldDisplayName SANDBOX
  prod:
    package: $_oldBasePackage
    name: $_oldDisplayName
''');
  await _write(root, 'apps/main/pubspec.yaml', '''
name: $_oldSlug
description: $_oldDisplayName
''');
  await _write(root, 'apps/main/android/app/build.gradle', '''
android {
    namespace '$_oldBasePackage'
}
''');
  await _write(
    root,
    path.join(
      'apps/main/android/app/src/main/kotlin',
      _oldPackagePath,
      'MainActivity.kt',
    ),
    '''
package $_oldBasePackage

class MainActivity
''',
  );
  await _write(root, 'apps/main/web/index.html', '''
<meta name="description" content="A new Flutter project.">
<meta name="apple-mobile-web-app-title" content="$_oldSlug">
<title>$_oldSlug</title>
''');
  await _write(root, 'apps/main/web/manifest.json', '''
{
    "name": "$_oldSlug",
    "short_name": "$_oldSlug",
    "description": "A new Flutter project."
}
''');
  await _write(root, 'apps/main/lib/l10n/localizations.csv', '''
key,en,vi
poweredByApp,Powered by $_oldDisplayName,Được cung cấp bởi $_oldDisplayName
''');
  await _write(root, 'apps/main/dist_config.sh', '''
dev_development_exportOptionsPlist="ios/signing_res/$_oldSigningDir/development/ExportOptions.plist"
''');
  await _write(root, 'apps/main/fastlane/Fastfile', '''
upload_to_play_store(
  package_name: "$_oldBasePackage"
)
''');
  await _write(
    root,
    'apps/main/release_notes_dev.txt',
    'The app with $_oldDisplayName',
  );
  await _write(root, 'apps/main/ios/QUICK_START.md', '$_oldBasePackage.dev');
  await _write(
    root,
    'apps/main/ios/signing_res/$_oldSigningDir/development/ExportOptions.plist',
    '<plist />',
  );
}

Future<String> _read(String root, String relativePath) {
  return File(path.join(root, relativePath)).readAsString();
}

Future<void> _write(Directory root, String relativePath, String content) async {
  final file = File(path.join(root.path, relativePath));
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;

import '../generate_app_localizations.dart' as app_localizations;
import 'generate_app_identifier.dart' as app_identifier;

const _oldDisplayName = 'My Flutter Base';
const _oldSlug = 'my_flutter_base';
const _oldBasePackage = 'com.pbh.myflutterbase';
const _oldPackagePath = 'com/pbh/myflutterbase';
const _oldSigningPath = 'ios/signing_res/my_flutter_base';

final _excludedCopySegments = {
  '.dart_tool',
  '.git',
  '.claude',
  '.idea',
  '.playwright-mcp',
  '.run',
  'build',
  'coverage',
};

final _textExtensions = {
  '.arb',
  '.config',
  '.dart',
  '.dockerignore',
  '.env',
  '.example',
  '.gradle',
  '.gitignore',
  '.html',
  '.json',
  '.kt',
  '.kts',
  '.lock',
  '.md',
  '.plist',
  '.properties',
  '.rb',
  '.sh',
  '.swift',
  '.txt',
  '.xcconfig',
  '.xml',
  '.yaml',
  '.yml',
};

final _textBasenames = {
  'Dockerfile',
  'Fastfile',
  'Gemfile',
  'LICENSE',
  'Makefile',
  'makefile',
};

class CreateProjectException implements Exception {
  CreateProjectException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProjectIdentity {
  ProjectIdentity({
    required this.displayName,
    required this.slug,
    required this.basePackage,
    String? iosSigningDirName,
  }) : iosSigningDirName =
           iosSigningDirName == null || iosSigningDirName.isEmpty
           ? slug
           : iosSigningDirName;

  final String displayName;
  final String slug;
  final String basePackage;
  final String iosSigningDirName;

  String get devPackage => '$basePackage.dev';

  String get stagingPackage => '$basePackage.staging';

  String get sandboxPackage => '$basePackage.sandbox';

  String get prodPackage => basePackage;

  String get devDisplayName => '$displayName DEV';

  String get stagingDisplayName => '$displayName STAGING';

  String get sandboxDisplayName => '$displayName SANDBOX';

  String get prodDisplayName => displayName;

  String get packagePath => basePackage.replaceAll('.', '/');

  List<String> get packageSegments => basePackage.split('.');
}

class CreateProjectOptions {
  CreateProjectOptions({
    required this.destination,
    required this.identity,
    this.templateRoot,
    this.workingDirectory,
    this.dryRun = false,
    this.force = false,
    this.runPostGeneration = true,
  });

  final String destination;
  final ProjectIdentity identity;
  final String? templateRoot;
  final String? workingDirectory;
  final bool dryRun;
  final bool force;
  final bool runPostGeneration;
}

class MovedPath {
  MovedPath(this.from, this.to);

  final String from;
  final String to;
}

class CreateProjectResult {
  CreateProjectResult({
    required this.destination,
    required this.changedFiles,
    required this.movedPaths,
    required this.warnings,
    required this.remainingIdentityFiles,
    required this.dryRun,
  });

  final String destination;
  final List<String> changedFiles;
  final List<MovedPath> movedPaths;
  final List<String> warnings;
  final List<String> remainingIdentityFiles;
  final bool dryRun;
}

class CreateProjectGenerator {
  static String findTemplateRoot({String? startDirectory}) {
    var current = Directory(
      path.normalize(path.absolute(startDirectory ?? Directory.current.path)),
    );

    while (true) {
      final hasMainApp = File(
        path.join(current.path, 'apps', 'main', 'app_identifier.yaml'),
      ).existsSync();
      final hasGenerator = Directory(
        path.join(current.path, 'tools', 'module_generator'),
      ).existsSync();

      if (hasMainApp && hasGenerator) {
        return current.path;
      }

      final parent = current.parent;
      if (path.equals(parent.path, current.path)) {
        throw CreateProjectException(
          'Could not find the template root from ${current.path}.',
        );
      }
      current = parent;
    }
  }

  Future<CreateProjectResult> run(CreateProjectOptions options) async {
    final templateRoot = path.normalize(
      path.absolute(options.templateRoot ?? findTemplateRoot()),
    );
    final workingDirectory = path.normalize(
      path.absolute(options.workingDirectory ?? templateRoot),
    );
    final destination = _resolveDestination(
      options.destination,
      workingDirectory,
    );
    final changedFiles = <String>[];
    final movedPaths = <MovedPath>[];
    final warnings = <String>[];

    await _validateOptions(
      templateRoot: templateRoot,
      destination: destination,
      identity: options.identity,
      force: options.force,
    );

    if (options.dryRun) {
      return CreateProjectResult(
        destination: destination,
        changedFiles: _plannedFiles(),
        movedPaths: [
          MovedPath(
            'apps/main/android/app/src/main/kotlin/$_oldPackagePath/MainActivity.kt',
            'apps/main/android/app/src/main/kotlin/${options.identity.packagePath}/MainActivity.kt',
          ),
          MovedPath(
            'apps/main/$_oldSigningPath',
            'apps/main/ios/signing_res/${options.identity.iosSigningDirName}',
          ),
        ],
        warnings: warnings,
        remainingIdentityFiles: const [],
        dryRun: true,
      );
    }

    await _prepareDestination(destination, force: options.force);
    await _copyTemplate(templateRoot, destination);

    await _rewriteAppIdentifier(destination, options.identity, changedFiles);
    await _rewritePubspec(destination, options.identity, changedFiles);
    await _rewriteWebMetadata(destination, options.identity, changedFiles);
    await _rewriteLocalizationCsv(destination, options.identity, changedFiles);
    await _updateAndroidPackage(
      destination,
      options.identity,
      changedFiles,
      movedPaths,
    );
    await _renameSigningDirectory(destination, options.identity, movedPaths);
    await _runIdentitySweep(destination, options.identity, changedFiles);

    if (options.runPostGeneration) {
      await _regenerateDerivedOutputs(
        destination,
        options.identity,
        changedFiles,
        warnings,
      );
      await _runIdentitySweep(destination, options.identity, changedFiles);
    }

    final remainingIdentityFiles = await scanRemainingIdentity(destination);

    return CreateProjectResult(
      destination: destination,
      changedFiles: changedFiles.toSet().toList()..sort(),
      movedPaths: movedPaths,
      warnings: warnings,
      remainingIdentityFiles: remainingIdentityFiles,
      dryRun: false,
    );
  }

  Future<List<String>> scanRemainingIdentity(String projectRoot) async {
    final matches = <String>[];
    final root = Directory(projectRoot);

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !_shouldScanTextFile(entity.path)) {
        continue;
      }
      final relativePath = path.relative(entity.path, from: projectRoot);
      if (_containsExcludedSegment(relativePath)) {
        continue;
      }

      try {
        final content = await entity.readAsString();
        if (content.contains(_oldDisplayName) ||
            content.contains(_oldSlug) ||
            content.contains(_oldBasePackage) ||
            content.contains(_oldPackagePath) ||
            content.contains(_oldSigningPath)) {
          matches.add(relativePath);
        }
      } on FormatException {
        continue;
      }
    }

    matches.sort();
    return matches;
  }

  String _resolveDestination(String destination, String workingDirectory) {
    if (destination.trim().isEmpty) {
      throw CreateProjectException('Destination is required.');
    }

    final resolved = path.isAbsolute(destination)
        ? destination
        : path.join(workingDirectory, destination);
    return path.normalize(path.absolute(resolved));
  }

  Future<void> _validateOptions({
    required String templateRoot,
    required String destination,
    required ProjectIdentity identity,
    required bool force,
  }) async {
    final templateMarker = File(
      path.join(templateRoot, 'apps', 'main', 'app_identifier.yaml'),
    );
    if (!await templateMarker.exists()) {
      throw CreateProjectException(
        'Template root does not contain apps/main/app_identifier.yaml: $templateRoot',
      );
    }

    if (!_isValidDartPackageName(identity.slug)) {
      throw CreateProjectException(
        'Slug must be a valid Dart package name, for example my_new_app.',
      );
    }

    if (!_isValidBasePackage(identity.basePackage)) {
      throw CreateProjectException(
        'Base package must be a lowercase reverse-DNS identifier, for example com.example.app.',
      );
    }

    if (!_isValidSigningDirName(identity.iosSigningDirName)) {
      throw CreateProjectException(
        'iOS signing directory name can only contain letters, digits, underscores, and dashes.',
      );
    }

    if (path.equals(templateRoot, destination) ||
        path.isWithin(templateRoot, destination)) {
      throw CreateProjectException(
        'Destination must be outside the template checkout: $destination',
      );
    }

    final destinationDir = Directory(destination);
    if (await destinationDir.exists() &&
        !await _isDirectoryEmpty(destinationDir) &&
        !force) {
      throw CreateProjectException(
        'Destination already exists and is not empty. Use --force to replace it.',
      );
    }
  }

  bool _isValidDartPackageName(String value) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value) &&
        !value.contains('__');
  }

  bool _isValidBasePackage(String value) {
    return RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch(value);
  }

  bool _isValidSigningDirName(String value) {
    return RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value);
  }

  Future<bool> _isDirectoryEmpty(Directory directory) async {
    await for (final _ in directory.list(followLinks: false)) {
      return false;
    }
    return true;
  }

  Future<void> _prepareDestination(
    String destination, {
    required bool force,
  }) async {
    final destinationDir = Directory(destination);
    if (await destinationDir.exists()) {
      if (!await _isDirectoryEmpty(destinationDir)) {
        if (!force) {
          throw CreateProjectException(
            'Destination already exists and is not empty: $destination',
          );
        }
        await destinationDir.delete(recursive: true);
      }
    }
    await destinationDir.create(recursive: true);
  }

  Future<void> _copyTemplate(String templateRoot, String destination) async {
    await _copyDirectory(
      source: Directory(templateRoot),
      target: Directory(destination),
      templateRoot: templateRoot,
    );
  }

  Future<void> _copyDirectory({
    required Directory source,
    required Directory target,
    required String templateRoot,
  }) async {
    await target.create(recursive: true);

    await for (final entity in source.list(followLinks: false)) {
      final relativePath = path.relative(entity.path, from: templateRoot);
      if (_containsExcludedSegment(relativePath)) {
        continue;
      }

      final targetPath = path.join(target.path, path.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(
          source: entity,
          target: Directory(targetPath),
          templateRoot: templateRoot,
        );
      } else if (entity is File) {
        await File(targetPath).parent.create(recursive: true);
        await entity.copy(targetPath);
        await _preserveExecutableBit(entity, File(targetPath));
      }
    }
  }

  Future<void> _preserveExecutableBit(File source, File target) async {
    if (Platform.isWindows) {
      return;
    }

    final stat = await source.stat();
    final isExecutable = (stat.mode & 0x49) != 0;
    if (isExecutable) {
      await Process.run('chmod', ['+x', target.path]);
    }
  }

  Future<void> _rewriteAppIdentifier(
    String projectRoot,
    ProjectIdentity identity,
    List<String> changedFiles,
  ) async {
    final file = File(
      path.join(projectRoot, 'apps', 'main', 'app_identifier.yaml'),
    );
    await file.writeAsString(_appIdentifierYaml(identity));
    changedFiles.add(path.relative(file.path, from: projectRoot));
  }

  String _appIdentifierYaml(ProjectIdentity identity) {
    return '''# dart run module_generator:generate_app_identifier

android:
  dev:
    package: ${_yamlString(identity.devPackage)}
    name: ${_yamlString(identity.devDisplayName)}
  staging:
    package: ${_yamlString(identity.stagingPackage)}
    name: ${_yamlString(identity.stagingDisplayName)}
  sandbox:
    package: ${_yamlString(identity.sandboxPackage)}
    name: ${_yamlString(identity.sandboxDisplayName)}
  prod:
    package: ${_yamlString(identity.prodPackage)}
    name: ${_yamlString(identity.prodDisplayName)}
ios:
  dev:
    package: ${_yamlString(identity.devPackage)}
    name: ${_yamlString(identity.devDisplayName)}
  staging:
    package: ${_yamlString(identity.stagingPackage)}
    name: ${_yamlString(identity.stagingDisplayName)}
  sandbox:
    package: ${_yamlString(identity.sandboxPackage)}
    name: ${_yamlString(identity.sandboxDisplayName)}
  prod:
    package: ${_yamlString(identity.prodPackage)}
    name: ${_yamlString(identity.prodDisplayName)}
''';
  }

  String _yamlString(String value) {
    final escaped = value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    return '"$escaped"';
  }

  Future<void> _rewritePubspec(
    String projectRoot,
    ProjectIdentity identity,
    List<String> changedFiles,
  ) async {
    final file = File(path.join(projectRoot, 'apps', 'main', 'pubspec.yaml'));
    if (!await file.exists()) {
      return;
    }

    var content = await file.readAsString();
    content = content.replaceFirst(
      RegExp(r'^name:\s*.*$', multiLine: true),
      'name: ${identity.slug}',
    );
    content = content.replaceFirst(
      RegExp(r'^description:\s*.*$', multiLine: true),
      'description: ${_yamlString(identity.displayName)}',
    );
    await file.writeAsString(content);
    changedFiles.add(path.relative(file.path, from: projectRoot));
  }

  Future<void> _rewriteWebMetadata(
    String projectRoot,
    ProjectIdentity identity,
    List<String> changedFiles,
  ) async {
    final appDir = path.join(projectRoot, 'apps', 'main');
    final indexFile = File(path.join(appDir, 'web', 'index.html'));
    if (await indexFile.exists()) {
      final escapedName = const HtmlEscape().convert(identity.displayName);
      var content = await indexFile.readAsString();
      content = content.replaceFirst(
        RegExp(r'<meta name="description" content="[^"]*">'),
        '<meta name="description" content="$escapedName">',
      );
      content = content.replaceFirst(
        RegExp(r'<meta name="apple-mobile-web-app-title" content="[^"]*">'),
        '<meta name="apple-mobile-web-app-title" content="$escapedName">',
      );
      content = content.replaceFirst(
        RegExp(r'<title>.*</title>'),
        '<title>$escapedName</title>',
      );
      await indexFile.writeAsString(content);
      changedFiles.add(path.relative(indexFile.path, from: projectRoot));
    }

    final manifestFile = File(path.join(appDir, 'web', 'manifest.json'));
    if (await manifestFile.exists()) {
      final raw = await manifestFile.readAsString();
      final manifest = jsonDecode(raw) as Map<String, dynamic>;
      manifest['name'] = identity.displayName;
      manifest['short_name'] = identity.displayName;
      manifest['description'] = identity.displayName;
      await manifestFile.writeAsString(
        '${const JsonEncoder.withIndent('    ').convert(manifest)}\n',
      );
      changedFiles.add(path.relative(manifestFile.path, from: projectRoot));
    }
  }

  Future<void> _rewriteLocalizationCsv(
    String projectRoot,
    ProjectIdentity identity,
    List<String> changedFiles,
  ) async {
    final file = File(
      path.join(
        projectRoot,
        'apps',
        'main',
        'lib',
        'l10n',
        'localizations.csv',
      ),
    );
    if (!await file.exists()) {
      return;
    }

    final rows = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(
          CsvToListConverter(eol: Platform.isMacOS ? '\n' : defaultEol),
        )
        .toList();

    for (final row in rows) {
      if (row.isNotEmpty && row.first == 'poweredByApp') {
        if (row.length > 1) {
          row[1] = 'Powered by ${identity.displayName}';
        }
        if (row.length > 2) {
          row[2] = 'Được cung cấp bởi ${identity.displayName}';
        }
      }
    }

    await file.writeAsString('${const ListToCsvConverter().convert(rows)}\n');
    changedFiles.add(path.relative(file.path, from: projectRoot));
  }

  Future<void> _updateAndroidPackage(
    String projectRoot,
    ProjectIdentity identity,
    List<String> changedFiles,
    List<MovedPath> movedPaths,
  ) async {
    final appDir = path.join(projectRoot, 'apps', 'main');
    final buildGradle = File(
      path.join(appDir, 'android', 'app', 'build.gradle'),
    );
    if (await buildGradle.exists()) {
      var content = await buildGradle.readAsString();
      content = content.replaceFirst(
        RegExp("namespace\\s+['\"][^'\"]+['\"]"),
        "namespace '${identity.basePackage}'",
      );
      await buildGradle.writeAsString(content);
      changedFiles.add(path.relative(buildGradle.path, from: projectRoot));
    }

    await _moveMainActivity(
      appDir,
      projectRoot,
      identity,
      changedFiles,
      movedPaths,
    );
  }

  Future<void> _moveMainActivity(
    String appDir,
    String projectRoot,
    ProjectIdentity identity,
    List<String> changedFiles,
    List<MovedPath> movedPaths,
  ) async {
    final kotlinRoot = Directory(
      path.join(appDir, 'android', 'app', 'src', 'main', 'kotlin'),
    );
    final oldFile = File(
      path.joinAll([
        kotlinRoot.path,
        ..._oldPackagePath.split('/'),
        'MainActivity.kt',
      ]),
    );
    final newFile = File(
      path.joinAll([
        kotlinRoot.path,
        ...identity.packageSegments,
        'MainActivity.kt',
      ]),
    );
    final sourceFile = await oldFile.exists()
        ? oldFile
        : await _findMainActivity(kotlinRoot);

    if (sourceFile == null) {
      return;
    }

    var content = await sourceFile.readAsString();
    content = content.replaceFirst(
      RegExp(r'^package\s+[^\n]+', multiLine: true),
      'package ${identity.basePackage}',
    );

    await newFile.parent.create(recursive: true);
    await newFile.writeAsString(content);
    changedFiles.add(path.relative(newFile.path, from: projectRoot));

    if (!path.equals(sourceFile.path, newFile.path)) {
      await sourceFile.delete();
      movedPaths.add(
        MovedPath(
          path.relative(sourceFile.path, from: projectRoot),
          path.relative(newFile.path, from: projectRoot),
        ),
      );
      await _deleteEmptyParents(sourceFile.parent, kotlinRoot);
    }
  }

  Future<File?> _findMainActivity(Directory kotlinRoot) async {
    if (!await kotlinRoot.exists()) {
      return null;
    }

    await for (final entity in kotlinRoot.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File && path.basename(entity.path) == 'MainActivity.kt') {
        return entity;
      }
    }
    return null;
  }

  Future<void> _deleteEmptyParents(
    Directory directory,
    Directory stopAt,
  ) async {
    var current = directory;
    while (!path.equals(current.path, stopAt.path) &&
        path.isWithin(stopAt.path, current.path)) {
      if (!await _isDirectoryEmpty(current)) {
        return;
      }
      await current.delete();
      current = current.parent;
    }
  }

  Future<void> _renameSigningDirectory(
    String projectRoot,
    ProjectIdentity identity,
    List<MovedPath> movedPaths,
  ) async {
    final oldDirectory = Directory(
      path.join(projectRoot, 'apps', 'main', 'ios', 'signing_res', _oldSlug),
    );
    final newDirectory = Directory(
      path.join(
        projectRoot,
        'apps',
        'main',
        'ios',
        'signing_res',
        identity.iosSigningDirName,
      ),
    );

    if (!await oldDirectory.exists() ||
        path.equals(oldDirectory.path, newDirectory.path)) {
      return;
    }

    await newDirectory.parent.create(recursive: true);
    if (await newDirectory.exists()) {
      return;
    }

    await oldDirectory.rename(newDirectory.path);
    movedPaths.add(
      MovedPath(
        path.relative(oldDirectory.path, from: projectRoot),
        path.relative(newDirectory.path, from: projectRoot),
      ),
    );
  }

  Future<void> _runIdentitySweep(
    String projectRoot,
    ProjectIdentity identity,
    List<String> changedFiles,
  ) async {
    final replacements = _replacementRules(identity);
    final root = Directory(projectRoot);

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !_shouldScanTextFile(entity.path)) {
        continue;
      }
      final relativePath = path.relative(entity.path, from: projectRoot);
      if (_containsExcludedSegment(relativePath)) {
        continue;
      }

      try {
        var content = await entity.readAsString();
        final original = content;
        for (final replacement in replacements.entries) {
          content = content.replaceAll(replacement.key, replacement.value);
        }
        if (content != original) {
          await entity.writeAsString(content);
          changedFiles.add(relativePath);
        }
      } on FormatException {
        continue;
      }
    }
  }

  Map<String, String> _replacementRules(ProjectIdentity identity) {
    return {
      _oldSigningPath: 'ios/signing_res/${identity.iosSigningDirName}',
      '$_oldBasePackage.dev': identity.devPackage,
      '$_oldBasePackage.staging': identity.stagingPackage,
      '$_oldBasePackage.sandbox': identity.sandboxPackage,
      _oldBasePackage: identity.prodPackage,
      _oldPackagePath: identity.packagePath,
      '$_oldDisplayName DEV': identity.devDisplayName,
      '$_oldDisplayName STAGING': identity.stagingDisplayName,
      '$_oldDisplayName SANDBOX': identity.sandboxDisplayName,
      _oldDisplayName: identity.displayName,
      _oldSlug: identity.slug,
    };
  }

  Future<void> _regenerateDerivedOutputs(
    String projectRoot,
    ProjectIdentity identity,
    List<String> changedFiles,
    List<String> warnings,
  ) async {
    final appDir = path.join(projectRoot, 'apps', 'main');
    final previousDirectory = Directory.current.path;

    try {
      Directory.current = appDir;
      await app_identifier.generateAppIdentifier(
        project: _appIdentifierProject(identity),
      );
      changedFiles.add('apps/main/android/app_specific.properties');
      changedFiles.add('apps/main/ios/Flutter/AppSpecific.xcconfig');

      await app_localizations.generateAppLocalizations();
      changedFiles.add('apps/main/lib/l10n/intl_en.arb');
      changedFiles.add('apps/main/lib/l10n/intl_vi.arb');
    } finally {
      Directory.current = previousDirectory;
    }

    final flutterWarning = await _runFlutterGenL10n(appDir);
    if (flutterWarning != null) {
      warnings.add(flutterWarning);
    } else {
      changedFiles.add('apps/main/lib/l10n/generated');
    }
  }

  app_identifier.ProjectConfigDocument _appIdentifierProject(
    ProjectIdentity identity,
  ) {
    app_identifier.AppConfig config(String package, String name) {
      return app_identifier.AppConfig(package, name, null);
    }

    final configs = {
      'dev': config(identity.devPackage, identity.devDisplayName),
      'staging': config(identity.stagingPackage, identity.stagingDisplayName),
      'sandbox': config(identity.sandboxPackage, identity.sandboxDisplayName),
      'prod': config(identity.prodPackage, identity.prodDisplayName),
    };

    return app_identifier.ProjectConfigDocument([
      app_identifier.PlatformConfigDocument<
        app_identifier.AndroidConfigDocument
      >(
        configFilePath: 'android/app_specific.properties',
        document: app_identifier.AndroidConfigDocument(configs),
      ),
      app_identifier.PlatformConfigDocument<app_identifier.IOSConfigDocument>(
        configFilePath: 'ios/Flutter/AppSpecific.xcconfig',
        document: app_identifier.IOSConfigDocument(configs),
      ),
    ]);
  }

  Future<String?> _runFlutterGenL10n(String appDir) async {
    final fvmResult = await _tryRunProcess('fvm', [
      'flutter',
      'gen-l10n',
      '--format',
    ], workingDirectory: appDir);
    if (fvmResult != null) {
      if (fvmResult.exitCode == 0) {
        return null;
      }
      return 'Flutter localization generation failed with fvm: ${_processOutput(fvmResult)}';
    }

    final flutterResult = await _tryRunProcess('flutter', [
      'gen-l10n',
      '--format',
    ], workingDirectory: appDir);
    if (flutterResult == null) {
      return 'Skipped Flutter gen-l10n because neither fvm nor flutter was available.';
    }
    if (flutterResult.exitCode != 0) {
      return 'Flutter localization generation failed: ${_processOutput(flutterResult)}';
    }
    return null;
  }

  Future<ProcessResult?> _tryRunProcess(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
  }) async {
    try {
      return await Process.run(
        executable,
        arguments,
        workingDirectory: workingDirectory,
      );
    } on ProcessException {
      return null;
    }
  }

  String _processOutput(ProcessResult result) {
    final output = [
      result.stdout,
      result.stderr,
    ].where((entry) => entry.toString().trim().isNotEmpty).join('\n').trim();
    return output.isEmpty ? 'exit code ${result.exitCode}' : output;
  }

  bool _containsExcludedSegment(String relativePath) {
    final segments = path.split(path.normalize(relativePath));
    return segments.any(_excludedCopySegments.contains);
  }

  bool _shouldScanTextFile(String filePath) {
    final basename = path.basename(filePath);
    if (_textBasenames.contains(basename)) {
      return true;
    }
    return _textExtensions.contains(path.extension(filePath).toLowerCase());
  }

  List<String> _plannedFiles() {
    return [
      'apps/main/app_identifier.yaml',
      'apps/main/pubspec.yaml',
      'apps/main/android/app/build.gradle',
      'apps/main/android/app/src/main/kotlin/$_oldPackagePath/MainActivity.kt',
      'apps/main/web/index.html',
      'apps/main/web/manifest.json',
      'apps/main/lib/l10n/localizations.csv',
      'apps/main/dist_config.sh',
      'apps/main/fastlane/Fastfile',
      'README.md',
      'AGENTS.md',
      'apps/main/README.md',
      'apps/main/CICD_SECRETS_SETUP.md',
      'apps/main/ios/QUICK_START.md',
      'apps/main/ios/PROVISIONING_PROFILE_SETUP.md',
      'apps/main/ios/CICD_PROVISIONING_GUIDE.md',
      'apps/main/ios/check_provisioning_profiles.sh',
    ];
  }
}

import 'dart:io';

import 'package:args/args.dart';

import 'common/input_helper.dart';
import 'generator/create_project.dart';

Future<int> runCreateProjectCommand(List<String> arguments) async {
  final parser = _buildParser();

  late ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (error) {
    print('Error parsing arguments: $error\n');
    _printUsage(parser);
    return 64;
  }

  if (results['help'] as bool) {
    _printUsage(parser);
    return 0;
  }

  try {
    final nonInteractive = results['non-interactive'] as bool;
    final dryRun = results['dry-run'] as bool;
    final force = results['force'] as bool;

    var displayName = _optionalString(results, 'display-name');
    var slug = _optionalString(results, 'slug');
    var basePackage = _optionalString(results, 'base-package');
    var destination = _optionalString(results, 'destination');
    var iosSigningDirName = _optionalString(results, 'ios-signing-dir-name');

    if (nonInteractive) {
      _requireOption(displayName, 'display-name');
      _requireOption(slug, 'slug');
      _requireOption(basePackage, 'base-package');
      _requireOption(destination, 'destination');
    } else {
      displayName ??= await InputHelper.enterRequired(
        message: 'Display name (eg. Acme Mobile)*: ',
      );
      slug ??= await InputHelper.enterRequired(
        message: 'Slug / Dart package name (eg. acme_mobile)*: ',
      );
      basePackage ??= await InputHelper.enterRequired(
        message: 'Base package / bundle ID (eg. com.acme.mobile)*: ',
      );
      destination ??= await _enterWithDefault(
        message: 'Destination path',
        defaultValue: '../$slug',
      );
      iosSigningDirName ??= await _enterWithDefault(
        message: 'iOS signing resource directory name',
        defaultValue: slug,
      );
    }

    final identity = ProjectIdentity(
      displayName: displayName!,
      slug: slug!,
      basePackage: basePackage!,
      iosSigningDirName: iosSigningDirName,
    );

    final templateRoot = _optionalString(results, 'template-root');
    final workingDirectory = _optionalString(results, 'working-directory');

    _printSummary(
      destination: destination!,
      identity: identity,
      dryRun: dryRun,
      force: force,
    );

    if (!nonInteractive && !dryRun) {
      final answer = await InputHelper.enterText('Proceed? [y/N]: ');
      if ((answer ?? '').trim().toLowerCase() != 'y') {
        print('Cancelled.');
        return 0;
      }
    }

    final result = await CreateProjectGenerator().run(
      CreateProjectOptions(
        destination: destination,
        identity: identity,
        templateRoot: templateRoot,
        workingDirectory: workingDirectory,
        dryRun: dryRun,
        force: force,
      ),
    );

    _printResult(result);
    return 0;
  } on CreateProjectException catch (error) {
    print('Error: ${error.message}');
    return 1;
  } catch (error, stackTrace) {
    print('Unexpected error: $error');
    print(stackTrace);
    return 1;
  }
}

ArgParser _buildParser() {
  return ArgParser()
    ..addOption(
      'destination',
      abbr: 'd',
      help: 'Destination directory for the generated project.',
    )
    ..addOption(
      'display-name',
      help: 'Human-readable app display name, for example "Acme Mobile".',
    )
    ..addOption(
      'slug',
      help: 'Dart package name / project slug, for example acme_mobile.',
    )
    ..addOption(
      'base-package',
      help: 'Base Android/iOS package ID, for example com.acme.mobile.',
    )
    ..addOption(
      'ios-signing-dir-name',
      help: 'iOS signing resource directory name. Defaults to the slug.',
    )
    ..addOption(
      'template-root',
      help: 'Template checkout root. Defaults to auto-detection.',
    )
    ..addOption(
      'working-directory',
      help: 'Base directory used to resolve relative destination paths.',
    )
    ..addFlag(
      'dry-run',
      help: 'Print planned changes without copying or writing files.',
      negatable: false,
    )
    ..addFlag(
      'force',
      help: 'Replace an existing non-empty destination directory.',
      negatable: false,
    )
    ..addFlag(
      'non-interactive',
      help: 'Fail instead of prompting for missing options or confirmation.',
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show usage information.',
      negatable: false,
    );
}

String? _optionalString(ArgResults results, String name) {
  final value = results[name] as String?;
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

void _requireOption(String? value, String name) {
  if (value == null || value.trim().isEmpty) {
    throw CreateProjectException('Missing required option --$name.');
  }
}

Future<String> _enterWithDefault({
  required String message,
  required String defaultValue,
}) async {
  final input = await InputHelper.enterText(
    '$message (default: $defaultValue): ',
  );
  final trimmed = (input ?? '').trim();
  return trimmed.isEmpty ? defaultValue : trimmed;
}

void _printSummary({
  required String destination,
  required ProjectIdentity identity,
  required bool dryRun,
  required bool force,
}) {
  print('''
Create project${dryRun ? ' (dry run)' : ''}
Destination: $destination
Display name: ${identity.displayName}
Slug: ${identity.slug}
Base package: ${identity.basePackage}
Flavor packages:
  dev: ${identity.devPackage}
  staging: ${identity.stagingPackage}
  sandbox: ${identity.sandboxPackage}
  prod: ${identity.prodPackage}
iOS signing directory: ${identity.iosSigningDirName}
${force ? 'Existing destination will be replaced if needed.\n' : ''}''');
}

void _printResult(CreateProjectResult result) {
  if (result.dryRun) {
    print('Planned file updates:');
  } else {
    print('Created project at: ${result.destination}\n');
    print('Updated files:');
  }

  for (final file in result.changedFiles) {
    print('- $file');
  }

  if (result.movedPaths.isNotEmpty) {
    print('\nMoved paths:');
    for (final move in result.movedPaths) {
      print('- ${move.from} -> ${move.to}');
    }
  }

  if (result.warnings.isNotEmpty) {
    stderr.writeln('\nWarnings:');
    for (final warning in result.warnings) {
      stderr.writeln('- $warning');
    }
  }

  if (result.remainingIdentityFiles.isNotEmpty) {
    print('\nRemaining old template identity references:');
    for (final file in result.remainingIdentityFiles) {
      print('- $file');
    }
  }

  if (!result.dryRun) {
    print('''
Next steps:
1. cd ${result.destination}
2. cp apps/main/.env.example apps/main/.env
3. cp apps/main/android/keystores/keystore.properties.example apps/main/android/keystores/keystore.properties
4. Update signing, Firebase, App Store, and environment values.
5. Run make pub_get, then make setup if needed.
''');
  }
}

void _printUsage(ArgParser parser) {
  print('Create a new Flutter project from this base template.\n');
  print('Usage: dart run module_generator:create_project [options]\n');
  print('Options:');
  print(parser.usage);
  print('\nExample:');
  print('''  dart run module_generator:create_project \\
    --destination ../acme_mobile \\
    --display-name "Acme Mobile" \\
    --slug acme_mobile \\
    --base-package com.acme.mobile''');
}

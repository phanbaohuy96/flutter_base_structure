import 'dart:io';

import 'package:args/args.dart';

import 'common/common_function.dart';
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
    }

    final identity = ProjectIdentity(
      displayName: displayName!,
      slug: slug!,
      basePackage: basePackage!,
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
  final trimmed = (results[name] as String?)?.trim();
  return trimmed.isNullOrEmpty ? null : trimmed;
}

void _requireOption(String? value, String name) {
  if (value?.trim().isNullOrEmpty ?? true) {
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
  final trimmed = input?.trim();
  return trimmed.isNullOrEmpty ? defaultValue : trimmed!;
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
4. Run make pub_get

Essential customisation:
5.  Update apps/main/lib/l10n/localizations.csv — replace Vietnamese (vi)
    column with your target languages, then run make lang
6.  Replace app icon assets in apps/main/{android,ios}/ — see
    apps/main/README.md or the scripts/ directory for icon generation
7.  Review and update AGENTS.md to match your project name, package ID,
    and locale setup (update stack versions too if needed)
8.  Review .agents/skills/ — update skill references to match your
    project (e.g. fl-localization skill: update language pair, locale codes)

Platform & distribution:
9.  Update signing certs, Firebase configs, and keystore values:
    - apps/main/android/keystores/keystore.properties
    - apps/main/android/app/google-services.json (one per flavor)
    - apps/main/ios/Flutter/AppSpecific.xcconfig
    - apps/main/ios/signing_res/ (provisioning profiles per flavor)
    - apps/main/fastlane/Fastfile
10. Read apps/main/CICD_SECRETS_SETUP.md and configure CI secrets
11. Read apps/main/ios/QUICK_START.md and apps/main/ios/PROVISIONING_PROFILE_SETUP.md

Verification:
12. Run make setup (pub_get + lang + asset + gen_all)
13. Run make analyze or fvm flutter analyze to check for issues
14. Update README.md with your project description and badges
15. Run the app on each flavor to verify: flutter run -t lib/main.dart
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

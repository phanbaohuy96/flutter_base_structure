import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:yaml/yaml.dart';

import 'generator/generate_app_localizations.dart'
    as generate_app_localizations;

Future<void> generateAppLocalizations() async {
  var filePath = 'l10n.yaml';
  if (!File(filePath).existsSync()) {
    _showYamlError();

    return;
  }

  final yamlMap = loadYaml(File(filePath).readAsStringSync()) as Map;

  final csvPath = yamlMap['resource-file']?.toString() ?? '';
  final outputPath =
      (yamlMap['arb-dir'] is String) ? yamlMap['arb-dir'] : 'assets/languages';

  if (!File(csvPath).existsSync()) {
    print('''Localizations csv file is not exist!''');

    return;
  }

  final input = File(csvPath).openRead();

  final fields = await input
      .transform(utf8.decoder)
      .transform(
        CsvToListConverter(
          eol: Platform.isMacOS ? '\n' : defaultEol,
        ),
      )
      .toList();

  final filename = yamlMap['template-arb-file']?.toString() ?? '';
  final fileExtension = filename.split('.').last;
  final filenameTemplate = filename.replaceFirst(filename.split('_').last, '');

  await generate_app_localizations.generateAppLocalizations(
    localizations: fields,
    outputPath: outputPath as String,
    filenameTemplate: filenameTemplate,
    fileExtension: fileExtension,
  );
}

Future<void> generateAppLocalizationsCSVFile() async {
  var filePath = 'l10n.yaml';
  if (!File(filePath).existsSync()) {
    _showYamlError();

    return;
  }

  final yamlMap = loadYaml(File(filePath).readAsStringSync()) as Map;

  final csvPath = yamlMap['resource-file']?.toString() ?? '';
  final filesPath =
      (yamlMap['arb-dir'] is String) ? yamlMap['arb-dir'] : 'assets/languages';

  await generate_app_localizations.generateAppLocalizationsCSVfile(
    filesPath: filesPath as String,
    outputPath: csvPath,
  );
}

Future<void> checkUnusedL10n() async {
  var filePath = 'l10n.yaml';
  if (!File(filePath).existsSync()) {
    _showYamlError();

    return;
  }

  final yamlMap = loadYaml(File(filePath).readAsStringSync()) as Map;

  final arbPath =
      (yamlMap['arb-dir'] is String) ? yamlMap['arb-dir'] : 'assets/languages';

  await generate_app_localizations.checkUnusedL10n(
    arbPath: arbPath,
    dartPath: 'lib',
  );
}

void _showYamlError() {
  print('''Please setting up an internation­alization for your app first''');
  print('''##########################################
##### Reference #####''');
  print('''
  https://docs.flutter.dev/development/accessibility-and-localization/internationalization''');
  print('##########################################');
}

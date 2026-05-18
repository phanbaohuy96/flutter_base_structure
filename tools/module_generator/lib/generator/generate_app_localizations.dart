import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;

import '../common/common_function.dart';
import '../common/file_helper.dart';

Future<void> generateAppLocalizations({
  required List<List<dynamic>> localizations,
  required String outputPath,
  required String filenameTemplate,
  String? fileExtension,
}) async {
  final header = localizations.first.cast<String>();
  final columnsCount = localizations.first.length;

  if (columnsCount < 2) {
    print('''Localizations CVS file must have at least 2 columns!''');

    return;
  }

  final keys = [];
  for (final line in localizations.skip(1)) {
    if (keys.contains(line.first)) {
      print('''Duplicated key: ${line.join(', ')}!''');
    }
    keys.add(line.first);
  }

  await FilesHelper.createFolder(outputPath);

  final res = <String, Map<String, String>>{};
  for (var i = 1; i < header.length; i++) {
    final r = <String, String>{};
    for (var localization in localizations.sublist(1, localizations.length)) {
      r.addAll({localization[0].toString(): localization[i].toString()});
    }
    res[header[i]] = r;
  }
  for (final e in res.entries) {
    await FilesHelper.writeFile(
      pathFile:
          '$outputPath/$filenameTemplate${e.key}.${fileExtension ?? 'arb'}',
      content: prettyJsonStr(e.value).replaceAll(r'\r\n', r'\n'),
    );
  }
}

Future<void> generateAppLocalizationsCSVfile({
  required String filesPath,
  required String outputPath,
  String? defaultLanguage,
}) async {
  final translationList = <String, Map<String, dynamic>>{};

  final validExtension = ['arb'];

  final dir = Directory(filesPath);

  final entities = await dir.list().toList();

  if (entities.isEmpty) {
    print('''Dont have any l10n file!''');

    return;
  }

  for (final f in entities.whereType<File>()) {
    var isValidExtension = validExtension
        .any((extension) => path.extension(f.path).contains(extension));

    if (isValidExtension) {
      final fileName = f.path.split('/').last.split('.').first;

      final languageCode = fileName.split('_').last;
      final value = jsonDecode(f.readAsStringSync());

      translationList.addAll({languageCode: value as Map<String, dynamic>});
    }
  }

  final header = ['key'];

  final languages = translationList.keys.toList();

  header.addAll(languages);

  final listRows = <List<String?>>[header];

  final standardLanguage = defaultLanguage == null
      ? translationList[translationList.keys.first]
      : translationList[defaultLanguage];

  for (var i = 0; i < (standardLanguage?.length ?? 0); i++) {
    final key = standardLanguage?.keys.toList()[i];
    final row = [key];
    for (var translation in translationList.values) {
      row.add(translation[key] as String? ?? '');
    }
    listRows.add(row);
  }

  var csv = ListToCsvConverter(
    eol: Platform.isMacOS ? '\n' : defaultEol,
  ).convert(listRows);

  await FilesHelper.writeFile(
    pathFile: outputPath,
    content: csv,
  );
}

Future<void> checkUnusedL10n({
  required String arbPath,
  required String dartPath,
}) async {
  final arbDir = Directory(arbPath);
  final dartDir = Directory(dartPath);

  final allArbKeys = <String>{};
  final usedKeys = <String>{};

  // Read all .arb files and collect keys
  final arbFiles = arbDir.listSync().where((f) => f.path.endsWith('.arb'));
  for (final file in arbFiles) {
    final content = File(file.path).readAsStringSync();
    final map = jsonDecode(content) as Map<String, dynamic>;
    for (final key in map.keys) {
      // Skip metadata keys like "@key"
      if (!key.startsWith('@')) {
        allArbKeys.add(key);
      }
    }
  }

  // Search Dart files for usage of localization keys
  final dartFiles =
      dartDir.listSync(recursive: true).where((f) => f.path.endsWith('.dart'));

  final keyPattern = RegExp(
    r'''(?:S\.of\(.*?\)|AppLocalizations\.of\(.*?\)|trans|translate\(.*?\)|l10n)\.(\w+)''',
  );

  for (final file in dartFiles) {
    final content = File(file.path).readAsStringSync();
    for (final match in keyPattern.allMatches(content)) {
      final key = match.group(1);
      if (key != null) {
        usedKeys.add(key);
      }
    }
  }

  // Compare and print unused keys
  final unusedKeys = allArbKeys.difference(usedKeys);

  if (unusedKeys.isEmpty) {
    print('✅ No unused localization keys found.');
  } else {
    print('⚠️ Unused localization keys:');
    for (final key in unusedKeys) {
      print('  - $key');
    }
    exitCode = 1; // optional: fail build
  }
}

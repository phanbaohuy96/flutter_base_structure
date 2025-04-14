import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'generator/generate_export.dart' as generate_export;

Future<void> generateExport({required List<String> args}) async {
  var filePath = 'generate_export.yaml';
  if (!File(filePath).existsSync()) {
    _showGenerateExportError();
  } else {
    try {
      final yamlMap = loadYaml(File(filePath).readAsStringSync()) as YamlList;
      await generate_export.generateExport(
        config: [...yamlMap.nodes.map((e) => e.value as YamlMap)],
      );
    } catch (e_) {
      print(e_);
      _showGenerateExportError();
    }
  }
}

void _showGenerateExportError() {
  print('''Please provide generate_export.yaml file''');
  print('''##########################################
##### Example content of assets.yaml #####''');
  print('''---
- folder: folder1
  file_name: filename1
- folder: folder2
  file_name: filename2''');
  print('##########################################');
}

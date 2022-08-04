import 'dart:convert';

import 'dart:io';

class InputHelper {
  static Future<String?> enterText(String message) async {
    stdout.write('\n$message');
    var text = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!);
    return text;
  }

  static Future<String> enterModuleName() async {
    var inputModuleName = '';
    while (inputModuleName.isEmpty) {
      inputModuleName = await enterText(
        'Module name (eg. test_module)*: ',
      ).then((value) => value ?? '');
    }
    return inputModuleName;
  }

  static Future<String> enterModuleDir({
    String defaultDir = 'lib/presentation/modules',
  }) async {
    var inputModuleDir = await InputHelper.enterText(
      'Module directory (default: $defaultDir): ',
    ).then(
      (value) {
        return value?.replaceAll("'", '') ?? '';
      },
    );
    return inputModuleDir.isEmpty ? defaultDir : inputModuleDir;
  }
}

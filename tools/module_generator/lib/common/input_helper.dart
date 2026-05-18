import 'dart:convert';
import 'dart:io';

class InputHelper {
  static Future<String?> enterText(String message) async {
    stdout.write('\n$message');
    var text = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!);
    return text;
  }

  static Future<String> enterRequired({
    required String message,
  }) async {
    var text = '';
    while (text.isEmpty) {
      text = await enterText(message).then((value) => value ?? '');
    }
    return text;
  }

  static Future<String> enterName({
    String message = 'Module name (eg. test_module)*: ',
  }) async {
    return enterRequired(message: message);
  }

  static Future<String> enterDir({
    String defaultDir = 'lib/presentation/modules',
    String message = 'Module directory',
  }) async {
    var inputModuleDir = await InputHelper.enterText(
      '$message (default: $defaultDir): ',
    ).then(
      (value) {
        return value?.replaceAll("'", '') ?? '';
      },
    );
    return inputModuleDir.isEmpty ? defaultDir : inputModuleDir;
  }
}

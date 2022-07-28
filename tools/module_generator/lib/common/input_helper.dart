import 'dart:convert';

import 'dart:io';

class InputHelper {
  static Future<String?> enterText(String message) async {
    stdout.write('\n$message');
    var text = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!);
    return text;
  }
}

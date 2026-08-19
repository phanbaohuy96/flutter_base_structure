import 'dart:convert';
import 'dart:io';

class InputHelper {
  static Future<String?> enterText(String message) async {
    stdout.write('\n$message');
    var text = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!);
    return text;
  }

  static Future<String> enterRequired({required String message}) async {
    var text = '';
    while (text.isEmpty) {
      text = await enterText(message).then((value) => value?.trim() ?? '');
    }
    return text;
  }

  /// Prompts once and falls back to [fallback] when the answer is blank.
  static Future<String> enterOptional(
    String message, {
    required String fallback,
  }) async {
    final text = await enterText(message).then((value) => value?.trim() ?? '');
    return text.isEmpty ? fallback : text;
  }

  /// Prompts for a yes/no answer, defaulting to yes on a blank line.
  static Future<bool> confirm(
    String message, {
    bool defaultValue = true,
  }) async {
    final suffix = defaultValue ? '[Y/n]' : '[y/N]';
    final text = await enterText('$message $suffix: ').then(
      (value) => value?.trim().toLowerCase() ?? '',
    );
    if (text.isEmpty) {
      return defaultValue;
    }
    return text == 'y' || text == 'yes';
  }

  /// Prompts until the answer parses as one of [allowed].
  ///
  /// Replaces a bare `int.parse` on raw stdin, which threw an uncaught
  /// `FormatException` on any non-numeric keystroke instead of reprompting.
  static Future<int> enterChoice(
    String message, {
    required Set<int> allowed,
  }) async {
    while (true) {
      final raw = await enterText(message).then((value) => value?.trim() ?? '');
      final selection = int.tryParse(raw);
      if (selection != null && allowed.contains(selection)) {
        return selection;
      }
      print('Invalid option: "$raw"');
    }
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
    var inputModuleDir =
        await InputHelper.enterText('$message (default: $defaultDir): ').then((
          value,
        ) {
          return value?.replaceAll("'", '').trim() ?? '';
        });
    return inputModuleDir.isEmpty ? defaultDir : inputModuleDir;
  }
}

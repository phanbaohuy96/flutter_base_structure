import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';
import 'package:module_generator/generator/generate_export.dart';

void main() {
  test('test common function', () async {
    expect(formatClassName('inputName'), 'InputName');
    expect(formatClassName('input_Name'), 'InputName');
    expect(formatClassName('input_name'), 'InputName');
    expect(formatClassName('input_name4'), 'InputName4');

    expect(formatModuleName('inputName'), 'input_name');
    expect(formatModuleName('input_Name'), 'input_name');
    expect(formatModuleName('input_name'), 'input_name');
    expect(formatModuleName('inputName'), 'input_name');
    expect(formatModuleName('inputName4'), 'input_name4');

    expect(camelCase('inputName'), 'inputName');
    expect(camelCase('input_name'), 'inputName');
    expect(camelCase('Input_Name'), 'inputName');
    expect(camelCase('Input Name'), 'inputName');
    expect(camelCase('Input name'), 'inputName');
    expect(camelCase('Input NAME'), 'inputNAME');
    expect(camelCase('Input NAME '), 'inputNAME');
    expect(camelCase('Input NAME 4'), 'inputNAME4');
  });

  group('ExportFile ignore functionality', () {
    test('should ignore files matching glob patterns', () {
      final exportFile = ExportFile(
        fileName: 'test.dart',
        folder: 'lib/',
        ignore: ['**/universal/platform', '**/*.test.dart', 'temp/*'],
      );

      // Test **/ pattern matching - should match paths containing the pattern
      expect(
        exportFile.shouldIgnore('lib/common/universal/platform/platform.dart'),
        isTrue,
      );
      expect(
        exportFile.shouldIgnore('lib/data/universal/platform/web.dart'),
        isTrue,
      );
      expect(
        exportFile.shouldIgnore(
          'lib/presentation/universal/platform/mobile.dart',
        ),
        isTrue,
      );
      expect(exportFile.shouldIgnore('lib/common/universal/platform'), isTrue);

      // Test **/*.ext pattern matching
      expect(exportFile.shouldIgnore('lib/test/widget.test.dart'), isTrue);
      expect(exportFile.shouldIgnore('lib/models/user.test.dart'), isTrue);

      // Test single * pattern - should only match files directly in directory
      expect(exportFile.shouldIgnore('temp/file.dart'), isTrue);
      expect(
        exportFile.shouldIgnore('temp/subfolder/file.dart'),
        isFalse,
      ); // Should not match subdirectories

      // Test files that should not be ignored
      expect(
        exportFile.shouldIgnore('lib/common/universal/other/file.dart'),
        isFalse,
      );
      expect(exportFile.shouldIgnore('lib/models/user.dart'), isFalse);
      expect(exportFile.shouldIgnore('lib/widgets/button.dart'), isFalse);
      expect(
        exportFile.shouldIgnore('universal/platform'),
        isFalse,
      ); // No prefix, so ** doesn't match
    });

    test('should not ignore anything when ignore list is empty', () {
      final exportFile = ExportFile(
        fileName: 'test.dart',
        folder: 'lib/',
        ignore: [],
      );

      expect(
        exportFile.shouldIgnore('lib/common/universal/platform/platform.dart'),
        isFalse,
      );
      expect(exportFile.shouldIgnore('any/path/file.dart'), isFalse);
    });

    test('should handle complex glob patterns', () {
      final exportFile = ExportFile(
        fileName: 'test.dart',
        folder: 'lib/',
        ignore: ['**/*_generated.dart', '**/test/**', 'build/*'],
      );

      // Test **/*pattern matching
      expect(exportFile.shouldIgnore('lib/models/user_generated.dart'), isTrue);
      expect(exportFile.shouldIgnore('src/data/api_generated.dart'), isTrue);

      // Test **/directory/** matching
      expect(exportFile.shouldIgnore('lib/test/widget_test.dart'), isTrue);
      expect(
        exportFile.shouldIgnore('src/test/integration/api_test.dart'),
        isTrue,
      );

      // Test directory/* matching (only direct children)
      expect(exportFile.shouldIgnore('build/output.dart'), isTrue);
      expect(
        exportFile.shouldIgnore('build/subdir/file.dart'),
        isFalse,
      ); // Should not match subdirectories

      // Files that should not be ignored
      expect(exportFile.shouldIgnore('lib/models/user.dart'), isFalse);
      expect(exportFile.shouldIgnore('lib/widgets/button.dart'), isFalse);
      expect(exportFile.shouldIgnore('src/utils/helper.dart'), isFalse);
    });
  });
}

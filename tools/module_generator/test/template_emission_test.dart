import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';
import 'package:module_generator/res/templates/common_module/source.dart';
import 'package:module_generator/res/templates/detail_module/source.dart';
import 'package:module_generator/res/templates/listing_module/source.dart';

/// Walks a template source map and yields every leaf template string keyed by
/// its dotted path (e.g. `bloc.state`).
Map<String, String> _flatten(
  Map<dynamic, dynamic> source, [
  String prefix = '',
]) {
  final result = <String, String>{};
  source.forEach((key, value) {
    final path = prefix.isEmpty ? '$key' : '$prefix.$key';
    if (value is Map) {
      result.addAll(_flatten(value, path));
    } else if (value is String) {
      result[path] = value;
    }
  });
  return result;
}

String _emit(String template) => template.replaceContent(
  className: 'SampleFeature',
  moduleName: 'sample_feature',
  modelName: 'SampleModel',
  partCount: 4,
);

void main() {
  final modules = {
    'common_module': commonModuleRes,
    'listing_module': listingModuleRes,
    'detail_module': detailModuleRes,
  };

  group('module templates emit valid Dart', () {
    modules.forEach((moduleName, source) {
      _flatten(source).forEach((path, template) {
        final emitted = _emit(template);

        test('$moduleName/$path leaves no unresolved placeholder', () {
          expect(
            RegExp(r'%%[A-Z_]+%%').firstMatch(emitted),
            isNull,
            reason:
                'an unsubstituted template key survived in $moduleName/$path',
          );
        });

        test('$moduleName/$path parses as Dart', () {
          final result = parseString(
            content: emitted,
            throwIfDiagnostics: false,
          );
          expect(
            result.errors,
            isEmpty,
            reason:
                'emitted $moduleName/$path has syntax errors:\n'
                '${result.errors.join('\n')}',
          );
        });
      });
    });
  });

  group('coordinator presence follows the Simple/Compound rule', () {
    // A Simple module (one screen) gets no coordinator; a Compound module does.
    test('common_module (Simple) emits no coordinator', () {
      expect(commonModuleRes.containsKey('coordinator'), isFalse);
    });

    test('listing_module (Simple) emits no coordinator', () {
      expect(listingModuleRes.containsKey('coordinator'), isFalse);
    });

    test('detail_module (Compound) emits a coordinator', () {
      expect(detailModuleRes.containsKey('coordinator'), isTrue);
    });
  });
}

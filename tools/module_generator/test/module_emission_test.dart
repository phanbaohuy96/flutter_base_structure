import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';
import 'package:module_generator/generator/detail_module_generator.dart';
import 'package:module_generator/generator/entity_generator.dart';
import 'package:module_generator/generator/module_generator_ext.dart';
import 'package:module_generator/res/templates/common_module/source.dart';
import 'package:module_generator/res/templates/detail_module/source.dart';
import 'package:module_generator/res/templates/listing_module/source.dart';
import 'package:module_generator/res/templates/usecase/source.dart';
import 'package:path/path.dart' as p;

/// Files a generated module imports but does not create — the seams every app
/// package built from this template already has.
const _anchorFiles = [
  'lib/di/di.dart',
  'lib/l10n/localization_ext.dart',
  'lib/presentation/base/base.dart',
  'lib/presentation/extentions/extention.dart',
];

/// Suffixes produced by build_runner rather than by the generator.
const _buildRunnerSuffixes = ['.freezed.dart', '.g.dart'];

late Directory _sandbox;
late Directory _previousCwd;

void main() {
  setUp(() {
    _previousCwd = Directory.current;
    _sandbox = Directory.systemTemp.createTempSync('module_generator_test');
    Directory.current = _sandbox;
    for (final anchor in _anchorFiles) {
      File(p.join(_sandbox.path, anchor))
        ..createSync(recursive: true)
        ..writeAsStringSync('// anchor\n');
    }
  });

  tearDown(() {
    Directory.current = _previousCwd;
    _sandbox.deleteSync(recursive: true);
  });

  group('emitted modules are self-consistent', () {
    for (final scenario in _scenarios) {
      test('${scenario.label}: every relative import resolves', () async {
        final emitted = await scenario.generate();
        expect(emitted, isNotEmpty);

        final unresolved = <String>[];
        for (final path in emitted) {
          for (final target in _referencedPaths(File(path))) {
            if (_buildRunnerSuffixes.any(target.endsWith)) {
              continue;
            }
            final resolved = p.normalize(p.join(p.dirname(path), target));
            if (!File(resolved).existsSync()) {
              unresolved.add('$path -> $target (resolved: $resolved)');
            }
          }
        }

        expect(
          unresolved,
          isEmpty,
          reason:
              'these directives point at files that were never written:\n'
              '${unresolved.join('\n')}',
        );
      });

      test('${scenario.label}: bloc and usecase agree on names', () async {
        final emitted = await scenario.generate();
        final bloc = _read(emitted, '_bloc.dart');
        final usecase = _read(emitted, '_usecase.dart');
        final usecaseImpl = _read(emitted, '_usecase.impl.dart');

        // The bloc declares `final <X>Usecase _usecase;`, so the usecase file
        // must declare exactly that class. A `_detail` suffix applied to the
        // module but not the usecase used to break precisely here.
        final declared = RegExp(
          r'final (\w+Usecase) _usecase;',
        ).firstMatch(bloc)?.group(1);
        expect(declared, isNotNull, reason: 'bloc declares no usecase field');
        expect(
          usecase,
          contains('abstract class $declared {'),
          reason: '$declared is not declared by the generated usecase',
        );

        // Every `_usecase.<method>(` call in the bloc must exist on the
        // abstract usecase, and be implemented.
        final calls = RegExp(
          r'_usecase\.(\w+)',
        ).allMatches(bloc).map((m) => m.group(1)!).toSet();
        expect(calls, isNotEmpty);
        for (final call in calls) {
          expect(
            usecase,
            contains(call),
            reason: '$call is called by the bloc but not declared',
          );
          expect(
            usecaseImpl,
            contains(call),
            reason: '$call is declared but not implemented',
          );
        }
      });

      test('${scenario.label}: route, screen and barrel agree', () async {
        final emitted = await scenario.generate();
        final route = _read(emitted, '_route.dart');
        final screen = _read(emitted, '_screen.dart');
        final barrel = emitted.firstWhere(
          (path) => RegExp(r'/\w+\.dart$').hasMatch(path) && _isBarrel(path),
        );

        final screenClass = RegExp(
          r'class (\w+Screen) extends StatefulWidget',
        ).firstMatch(screen)!.group(1)!;
        expect(route, contains('$screenClass.routeName'));
        expect(screen, contains('static const String routeName'));

        // A barrel that exports a file the generator did not write is a
        // broken import for every consumer of the module.
        for (final target in _referencedPaths(File(barrel))) {
          final resolved = p.normalize(p.join(p.dirname(barrel), target));
          expect(
            File(resolved).existsSync(),
            isTrue,
            reason: 'barrel exports missing file: $target',
          );
        }

        // `directives_ordering` sorts by URI, and whether `<module>_route`
        // lands before or after `bloc/` depends on the module's first letter,
        // so the barrel is sorted at emission rather than in the template.
        final exports = File(barrel)
            .readAsLinesSync()
            .where((line) => line.startsWith('export '))
            .toList();
        expect(exports, isNotEmpty);
        expect(
          exports,
          orderedEquals([...exports]..sort()),
          reason: 'barrel exports are not sorted: $barrel',
        );
      });
    }
  });

  test('detail module suffixes the usecase alongside the module', () async {
    final emitted = await _detailScenario.generate();
    expect(
      emitted,
      contains(
        'lib/domain/usecases/product_detail/product_detail_usecase.dart',
      ),
    );
    expect(
      emitted,
      contains(
        'lib/presentation/modules/product_detail/product_detail_route.dart',
      ),
    );
  });

  test('detail module name is not double-suffixed', () {
    expect(detailModuleNameFor('product'), 'product_detail');
    expect(detailModuleNameFor('product_detail'), 'product_detail');
    expect(detailModuleNameFor('productDetail'), 'product_detail');
  });

  test('import anchors follow the emitting file depth', () {
    // Route and coordinator files sit one level above bloc/ and views/. A
    // single shared `'../' * n` prefix could not be right for both, which is
    // what produced `'../../..//../../di/di.dart'`.
    expect(
      resolveImportAnchors('lib/presentation/modules/feature/bloc'),
      containsPair(r'%%IMPORT_LIB%%', '../../../../'),
    );
    expect(
      resolveImportAnchors('lib/presentation/modules/feature'),
      containsPair(r'%%IMPORT_LIB%%', '../../../'),
    );
    expect(
      resolveImportAnchors('lib/presentation/modules/feature'),
      containsPair(r'%%IMPORT_PRESENTATION%%', '../../'),
    );
  });

  test('normalizeDir strips quotes, ./ prefixes and trailing slashes', () {
    expect(
      normalizeDir("'lib/presentation/modules/'"),
      'lib/presentation/modules',
    );
    expect(
      normalizeDir('./lib/presentation/modules'),
      'lib/presentation/modules',
    );
    expect(
      normalizeDir('lib/presentation/modules//'),
      'lib/presentation/modules',
    );
  });
}

bool _isBarrel(String path) {
  final name = p.basenameWithoutExtension(path);
  return !name.endsWith('_route') &&
      !name.endsWith('_coordinator') &&
      !path.contains('/bloc/') &&
      !path.contains('/views/') &&
      !path.contains('/domain/');
}

String _read(List<String> emitted, String suffix) {
  final path = emitted.firstWhere(
    (path) => path.endsWith(suffix),
    orElse: () => fail('no emitted file ends with $suffix'),
  );
  return File(path).readAsStringSync();
}

/// Relative targets of every `import`/`export`/`part` directive in [file].
Iterable<String> _referencedPaths(File file) sync* {
  final pattern = RegExp(
    r'''^\s*(?:import|export|part)\s+'([^']+)'\s*;''',
    multiLine: true,
  );
  for (final match in pattern.allMatches(file.readAsStringSync())) {
    final target = match.group(1)!;
    if (target.startsWith('package:') || target.startsWith('dart:')) {
      continue;
    }
    yield target;
  }
}

class _Scenario {
  const _Scenario({
    required this.label,
    required this.moduleName,
    required this.source,
    required this.usecaseSource,
    this.includeFilter = false,
  });

  final String label;
  final String moduleName;
  final Map<String, dynamic> source;
  final Map<String, dynamic> usecaseSource;
  final bool includeFilter;

  Future<List<String>> generate() async {
    const entity = 'Product';
    final modelPath = entityPathFor(entity);
    return [
      ...await generateEntity(modelName: entity, includeFilter: includeFilter),
      ...await generateModuleWithTemplateSource(
        source: source,
        inputModuleName: moduleName,
        inputModuleDir: 'lib/presentation/modules',
        modelName: entity,
        modelPath: modelPath,
      ),
      ...await generateUsecaseWithTemplateSource(
        source: usecaseSource,
        inputModuleName: moduleName,
        inputModuleDir: 'lib/domain/usecases',
        modelName: entity,
        modelPath: modelPath,
      ),
    ];
  }
}

_Scenario get _detailScenario =>
    _scenarios.firstWhere((scenario) => scenario.label == 'detail');

final _scenarios = <_Scenario>[
  _Scenario(
    label: 'common',
    moduleName: 'product_overview',
    source: commonModuleRes,
    usecaseSource: usecaseRes['common']!,
  ),
  _Scenario(
    label: 'listing',
    moduleName: 'product_list',
    source: listingModuleRes,
    usecaseSource: usecaseRes['listing']!,
    includeFilter: true,
  ),
  _Scenario(
    label: 'detail',
    moduleName: 'product_detail',
    source: detailModuleRes,
    usecaseSource: usecaseRes['detail']!,
  ),
];

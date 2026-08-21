import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';
import 'package:module_generator/common/generator_options.dart';
import 'package:module_generator/generator/detail_module_generator.dart';
import 'package:module_generator/generator/di_binder.dart';
import 'package:module_generator/generator/entity_generator.dart';
import 'package:module_generator/generator/model_generator.dart';
import 'package:module_generator/generator/module_generator_ext.dart';
import 'package:module_generator/generator/repository_generator.dart';
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

  group('emitted repositories are self-consistent', () {
    const repositoryDir = 'lib/data/data_source/remote/repository';

    for (final transport in RepositoryTransport.values) {
      test('${transport.name}: every directive resolves', () async {
        final emitted = await generateRepositoryWithTemplateSource(
          transport: transport,
          inputRepoName: 'product',
          inputRepoDir: repositoryDir,
        );
        expect(emitted, isNotEmpty);

        final unresolved = <String>[];
        for (final path in emitted) {
          for (final target in _referencedPaths(File(path))) {
            // `.g.dart` is retrofit's output, written by build_runner.
            if (_buildRunnerSuffixes.any(target.endsWith)) {
              continue;
            }
            final resolved = p.normalize(p.join(p.dirname(path), target));
            if (!File(resolved).existsSync()) {
              unresolved.add('$path -> $target');
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

      // Retrofit only generates an implementation when the abstract class
      // carries `@RestApi()` and redirects its factory at the private class it
      // will write. Miss either and the library never compiles.
      test('${transport.name}: the client can be constructed', () async {
        final emitted = await generateRepositoryWithTemplateSource(
          transport: transport,
          inputRepoName: 'product',
          inputRepoDir: repositoryDir,
        );
        final repository = _read(emitted, '_repository.dart');

        expect(repository, contains('@RestApi()'));
        expect(repository, contains("part 'product_repository.g.dart';"));

        // Collapsed because the formatter is free to wrap a long redirect.
        final collapsed = repository.replaceAll(RegExp(r'\s+'), ' ');
        final client = RegExp(
          r'abstract class (\w+) \{',
        ).firstMatch(repository)?.group(1);
        expect(client, isNotNull);
        expect(collapsed, contains('factory $client('));
        expect(collapsed, contains('= _$client;'));
      });

      // The DI provider names a type the emitted file actually declares —
      // a binding for a class that was never written is a build failure the
      // operator sees minutes later, in build_runner output.
      test('${transport.name}: the DI binding matches the emission', () async {
        final emitted = await generateRepositoryWithTemplateSource(
          transport: transport,
          inputRepoName: 'product',
          inputRepoDir: repositoryDir,
        );
        final binding = repositoryDiBinding(
          transport: transport,
          inputRepoName: 'product',
          inputRepoDir: repositoryDir,
        );

        expect(emitted, contains(binding.importPath));
        expect(
          _read(emitted, '_repository.dart'),
          contains('abstract class ${binding.type} {'),
        );
      });
    }

    test('graphql emits the fragment the client posts', () async {
      final emitted = await generateRepositoryWithTemplateSource(
        transport: RepositoryTransport.graphql,
        inputRepoName: 'product',
        inputRepoDir: repositoryDir,
      );
      expect(
        emitted,
        contains('$repositoryDir/product/product_fragment.dart'),
      );
      expect(
        _read(emitted, '_repository.dart'),
        contains('ProductFragment.request('),
      );
    });

    test('rest emits no fragment', () async {
      final emitted = await generateRepositoryWithTemplateSource(
        transport: RepositoryTransport.rest,
        inputRepoName: 'product',
        inputRepoDir: repositoryDir,
      );
      expect(emitted.where((path) => path.endsWith('_fragment.dart')), isEmpty);
    });
  });

  // A client typed against `Map<String, dynamic>` left the operator to go
  // create the model in a second run and wire the import by hand. The model
  // now comes out of the same run, and the import between them has to resolve
  // on disk — not merely look plausible in the template.
  group('a repository is generated with the model it returns', () {
    const repositoryDir = 'lib/src/data/data_source/repository';
    const modelDir = 'lib/src/data/models';
    const model = RepositoryModel(
      className: 'ProductModel',
      path: '$modelDir/product.dart',
      kind: ModelKind.freezed,
    );

    for (final transport in RepositoryTransport.values) {
      test('${transport.name}: the model import resolves', () async {
        final modelPath = await generateModelFile(
          className: model.className,
          dir: modelDir,
          kind: model.kind,
        );
        // The suffix is on the class, the file is named for the repository.
        expect(modelPath, model.path);
        expect(
          File(modelPath).readAsStringSync(),
          contains('class ${model.className}'),
        );

        final emitted = await generateRepositoryWithTemplateSource(
          transport: transport,
          inputRepoName: 'product',
          inputRepoDir: repositoryDir,
          model: model,
        );
        final repositoryPath = emitted.firstWhere(
          (path) => path.endsWith('_repository.dart'),
        );
        final resolved = _referencedPaths(File(repositoryPath))
            .where((target) => !_buildRunnerSuffixes.any(target.endsWith))
            .map(
              (target) =>
                  p.normalize(p.join(p.dirname(repositoryPath), target)),
            )
            .toList();

        expect(resolved, contains(modelPath));
        for (final path in resolved) {
          expect(
            File(path).existsSync(),
            isTrue,
            reason: '$repositoryPath imports $path, which was never written',
          );
        }
        // The client has to be typed against the model, or the import it just
        // gained is an `unused_import` info — which fails `make check`.
        expect(
          File(repositoryPath).readAsStringSync(),
          contains(model.className),
        );
      });
    }

    // Two repositories can legitimately share a model, so a second run must
    // leave the fields someone already filled in alone rather than resetting
    // them to the template's `id`.
    test('an existing model is left as its author edited it', () async {
      await generateModelFile(
        className: model.className,
        dir: modelDir,
        kind: model.kind,
      );
      File(model.path).writeAsStringSync('// hand-edited\n');

      await generateModelFile(
        className: model.className,
        dir: modelDir,
        kind: model.kind,
      );
      expect(File(model.path).readAsStringSync(), '// hand-edited\n');
    });
  });

  group('the overwrite guard checks files, not directories', () {
    // Point of the guard: an existing directory is not a conflict. Refusing on
    // the directory left `--force` — the one option that destroys work — as
    // the only way forward.
    test(
      'an unrelated file in the target directory is not a conflict',
      () async {
        final paths = moduleFilePaths(
          source: commonModuleRes,
          inputModuleName: 'product_overview',
          inputModuleDir: 'lib/presentation/modules',
        );
        File('lib/presentation/modules/product_overview/README.md')
          ..createSync(recursive: true)
          ..writeAsStringSync('notes\n');

        await expectLater(assertTargetWritable(paths, force: false), completes);
      },
    );

    test('a file the run would replace is a conflict', () async {
      final paths = moduleFilePaths(
        source: commonModuleRes,
        inputModuleName: 'product_overview',
        inputModuleDir: 'lib/presentation/modules',
      );
      File(paths.first)
        ..createSync(recursive: true)
        ..writeAsStringSync('// hand written\n');

      await expectLater(
        assertTargetWritable(paths, force: false),
        throwsA(isA<GeneratorInputException>()),
      );
      // --force is what says "replace them", so it must not throw.
      await expectLater(assertTargetWritable(paths, force: true), completes);
    });

    test('planned module paths are the paths the writer emits', () async {
      final planned = moduleFilePaths(
        source: commonModuleRes,
        inputModuleName: 'product_overview',
        inputModuleDir: 'lib/presentation/modules',
      );
      final emitted = await generateModuleWithTemplateSource(
        source: commonModuleRes,
        inputModuleName: 'product_overview',
        inputModuleDir: 'lib/presentation/modules',
        modelName: 'Product',
        modelPath: entityPathFor('Product'),
      );
      expect(planned, orderedEquals(emitted));
    });
  });

  group('the DI binder edits the module in place', () {
    // The binder writes into a hand-written file, so the bar is higher than
    // "it compiles": it has to leave everything it did not add untouched.
    const modulePath = 'lib/src/di/data_source_micro.dart';
    const moduleSource = '''
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../data/data_source/rest_api_repository.dart';

export 'data_source_micro.module.dart';

@InjectableInit.microPackage(externalPackageModulesBefore: [])
void initDataSourceMicroPackage() {}

@module
abstract class DataSourceOverrideModule {
  @injectable
  DataSourceRestApiRepository restApiRepo(Dio dio) =>
      DataSourceRestApiRepository(dio);
}
''';

    void writeModule([String content = moduleSource]) {
      File(modulePath)
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
    }

    test('finds the module and appends the provider', () async {
      writeModule();
      final result = await registerDiBinding(
        repositoryDiBinding(
          transport: RepositoryTransport.rest,
          inputRepoName: 'product',
          inputRepoDir: 'lib/src/data/data_source/repository',
        ),
      );

      expect(result.bound, isTrue);
      expect(result.modulePath, modulePath);

      final updated = File(modulePath).readAsStringSync();
      expect(updated, contains('ProductRepository productRepository(Dio dio)'));
      // The existing provider survives, in place.
      expect(updated, contains('DataSourceRestApiRepository restApiRepo'));
      // The provider lands inside the @module class, not after it.
      final classEnd = updated.lastIndexOf('}');
      expect(updated.indexOf('productRepository'), lessThan(classEnd));
    });

    test('adds the import for the file it just bound', () async {
      writeModule();
      await registerDiBinding(
        repositoryDiBinding(
          transport: RepositoryTransport.rest,
          inputRepoName: 'product',
          inputRepoDir: 'lib/src/data/data_source/repository',
        ),
      );

      final updated = File(modulePath).readAsStringSync();
      expect(
        updated,
        contains(
          "import '../data/data_source/repository/product/"
          "product_repository.dart';",
        ),
      );

      // `directives_ordering` is an analyzer info, and an info fails
      // `make check` as hard as an error, so the block has to stay sorted.
      final imports = updated
          .split('\n')
          .where((line) => line.startsWith('import '))
          .toList();
      final packageImports = imports
          .where((line) => line.contains("'package:"))
          .toList();
      final relativeImports = imports
          .where((line) => !line.contains("'package:"))
          .toList();
      expect(packageImports, orderedEquals([...packageImports]..sort()));
      expect(relativeImports, orderedEquals([...relativeImports]..sort()));
      // package: imports come before relative ones.
      expect(
        imports.indexOf(packageImports.last),
        lessThan(imports.indexOf(relativeImports.first)),
      );
    });

    test('re-running does not register the same type twice', () async {
      writeModule();
      final binding = repositoryDiBinding(
        transport: RepositoryTransport.rest,
        inputRepoName: 'product',
        inputRepoDir: 'lib/src/data/data_source/repository',
      );
      await registerDiBinding(binding);
      final afterFirst = File(modulePath).readAsStringSync();

      final second = await registerDiBinding(binding);
      expect(second.message, contains('already registers'));
      expect(File(modulePath).readAsStringSync(), afterFirst);
    });

    test('reports rather than throws when there is no module', () async {
      final result = await registerDiBinding(
        repositoryDiBinding(
          transport: RepositoryTransport.rest,
          inputRepoName: 'product',
          inputRepoDir: 'lib/src/data/data_source/repository',
        ),
      );
      expect(result.bound, isFalse);
      expect(result.message, contains('no @module'));
    });

    // Build output is rewritten on every run, so a binding written there would
    // vanish at the next `make gen_*` with nothing to say it ever existed.
    test('never writes into generated module files', () async {
      File('lib/src/di/data_source_micro.module.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('@module\nabstract class Generated {}\n');
      expect(await findInjectableModule(), isNull);
    });
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

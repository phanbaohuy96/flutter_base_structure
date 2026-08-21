import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';
import 'package:module_generator/common/console.dart';
import 'package:module_generator/common/definitions.dart';
import 'package:module_generator/common/generator_options.dart';
import 'package:module_generator/common/package_scanner.dart';
import 'package:module_generator/generator/generate_export.dart';
import 'package:module_generator/generator/model_generator.dart';
import 'package:module_generator/generator/package_picker.dart';
import 'package:module_generator/generator/repository_generator.dart';
import 'package:module_generator/res/templates/common_module/module.dart';
import 'package:module_generator/res/templates/common_module/source.dart';
import 'package:module_generator/res/templates/detail_module/module.dart';
import 'package:module_generator/res/templates/detail_module/source.dart';
import 'package:module_generator/res/templates/listing_module/module.dart';
import 'package:module_generator/res/templates/listing_module/source.dart';

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

  group('module template coordinator contract', () {
    test('every module template includes a coordinator', () {
      expect(commonModuleRes, contains('coordinator'));
      expect(listingModuleRes, contains('coordinator'));
      expect(detailModuleRes, contains('coordinator'));
    });

    test('barrel exports match coordinator templates', () {
      final coordinatorExport = "export '${moduleNameKey}_coordinator.dart';";

      expect(commonModule, contains(coordinatorExport));
      expect(listingModule, contains(coordinatorExport));
      expect(detailModule, contains(coordinatorExport));
    });
  });

  group('repository transport selection', () {
    test('parses the flag values the CLI advertises', () {
      expect(RepositoryTransport.parse('rest'), RepositoryTransport.rest);
      expect(RepositoryTransport.parse('graphql'), RepositoryTransport.graphql);
      expect(RepositoryTransport.parse('soap'), isNull);
      expect(RepositoryTransport.parse(null), isNull);
    });

    test('every transport has a picker label and description', () {
      for (final transport in RepositoryTransport.values) {
        expect(transport.label, isNotEmpty);
        expect(transport.description, isNotEmpty);
      }
    });

    test('every transport maps to a template set', () {
      for (final transport in RepositoryTransport.values) {
        expect(repositoryTemplatesFor(transport), isNotEmpty);
        expect(repositoryTemplatesFor(transport), contains('repository'));
        // Retrofit writes the implementation into the `.g.dart` part, so no
        // transport has a hand-written impl to emit.
        expect(
          repositoryTemplatesFor(transport),
          isNot(contains('repository.impl')),
        );
      }
    });

    test('planned paths match the templates for the transport', () {
      final rest = repositoryFilePaths(
        transport: RepositoryTransport.rest,
        inputRepoName: 'sample_feature',
        inputRepoDir: 'lib/src/data/data_source/repository',
      );
      expect(rest, [
        'lib/src/data/data_source/repository/sample_feature/'
            'sample_feature_repository.dart',
      ]);

      final graphql = repositoryFilePaths(
        transport: RepositoryTransport.graphql,
        inputRepoName: 'sample_feature',
        inputRepoDir: 'lib/src/data/data_source/repository',
      );
      expect(graphql, hasLength(2));
      expect(
        graphql,
        contains(
          'lib/src/data/data_source/repository/sample_feature/'
          'sample_feature_fragment.dart',
        ),
      );
    });

    // A retrofit client's implementation is a private class, so `@Injectable`
    // cannot be applied to it — a `@module` provider is the only way to bind
    // one, and the generator has to write that provider itself.
    test('each transport binds the type that needs a provider', () {
      final rest = repositoryDiBinding(
        transport: RepositoryTransport.rest,
        inputRepoName: 'sample_feature',
        inputRepoDir: 'lib/src/data/data_source/repository',
      );
      expect(rest.type, 'SampleFeatureRepository');
      expect(rest.source, contains('@injectable'));
      expect(rest.source, contains('SampleFeatureRepository(dio)'));
      expect(rest.extraImports, contains('package:dio/dio.dart'));

      // For GraphQL the repository is an ordinary class injectable can build;
      // only the client underneath it needs the provider.
      final graphql = repositoryDiBinding(
        transport: RepositoryTransport.graphql,
        inputRepoName: 'sample_feature',
        inputRepoDir: 'lib/src/data/data_source/repository',
      );
      expect(graphql.type, 'SampleFeatureGraphqlApi');
      expect(graphql.source, contains('baseGraphQLUrl'));
      expect(graphql.extraImports, contains('package:core/core.dart'));
    });

    test('a package without retrofit cannot host a repository', () {
      const withRetrofit = WorkspacePackage(
        name: 'data_source',
        path: '/tmp/data_source',
        relativePath: 'modules/data_source',
        dependencies: {'core', 'dio', 'retrofit'},
      );
      expect(missingRepositoryDependencies(withRetrofit), isEmpty);

      // apps/main's shape: retrofit_generator is a dev dependency, so the
      // client would build and then fail `depend_on_referenced_packages`.
      const appPackage = WorkspacePackage(
        name: 'my_flutter_base',
        path: '/tmp/main',
        relativePath: 'apps/main',
        dependencies: {'core', 'dio'},
      );
      expect(missingRepositoryDependencies(appPackage), ['retrofit']);
      expect(appPackage.supportsRetrofit, isFalse);
    });
  });

  group('the payload model a repository is typed against', () {
    test('the flag values round-trip', () {
      expect(ModelKind.parse('freezed'), ModelKind.freezed);
      expect(ModelKind.parse('json_serializable'), ModelKind.jsonSerializable);
      expect(ModelKind.parse('none'), ModelKind.none);
      expect(ModelKind.parse('protobuf'), isNull);
      expect(ModelKind.parse(null), isNull);
      // Only `none` opts out of writing a file; everything else is a template.
      expect(
        ModelKind.values.where((kind) => kind.writesFile),
        [ModelKind.freezed, ModelKind.jsonSerializable],
      );
    });

    // The suffix lives on the class and not on the file: `UserModel` is
    // declared in `user.dart` here, and `FarmCycle` in `farm_cycle.dart` in
    // the projects built from this template.
    test('the default name suffixes the class, not the file', () {
      expect(defaultModelClassName('news'), 'NewsModel');
      expect(defaultModelClassName('farm_cycle'), 'FarmCycleModel');
      // An override that already carries the suffix must not be doubled.
      expect(defaultModelClassName('NewsModel'), 'NewsModel');

      expect(modelFileNameFor('NewsModel'), 'news.dart');
      expect(modelFileNameFor('FarmCycleModel'), 'farm_cycle.dart');
      // An operator who names the class without the suffix keeps that name.
      expect(modelFileNameFor('Article'), 'article.dart');
      // `Model` alone is a class name, not a suffix to strip into nothing.
      expect(modelFileNameFor('Model'), 'model.dart');
    });

    test('the import line and the decode expression vanish together', () {
      const targetDir = 'lib/src/data/data_source/repository/news';
      const model = RepositoryModel(
        className: 'NewsModel',
        path: 'lib/src/data/models/news.dart',
        kind: ModelKind.freezed,
      );

      final withModel = repositoryModelTokens(
        targetDir: targetDir,
        model: model,
      );
      expect(
        withModel[modelImportBlockKey],
        "import '../../../models/news.dart';",
      );
      expect(withModel[modelDecodeKey], 'NewsModel.fromJson(node)');
      expect(repositoryModelType(model), 'NewsModel');

      // `--model none`: an `import '';` would not even parse, and
      // `Map<String, dynamic>.fromJson` does not exist.
      final withoutModel = repositoryModelTokens(targetDir: targetDir);
      expect(withoutModel[modelImportBlockKey], isEmpty);
      expect(withoutModel[modelDecodeKey], 'node');
      expect(repositoryModelType(null), 'Map<String, dynamic>');
    });

    // The model is written with `overrideFile: false`, so pointing a second
    // repository at an existing model skips it rather than clobbering the
    // fields someone already filled in. Listing it in the guard would refuse
    // the run instead.
    test('the overwrite guard does not cover the model', () {
      final paths = repositoryFilePaths(
        transport: RepositoryTransport.rest,
        inputRepoName: 'news',
        inputRepoDir: 'lib/src/data/data_source/repository',
      );
      expect(paths.any((path) => path.contains('/models/')), isFalse);
    });
  });

  group('package scanning', () {
    test('reads only the dependencies block', () {
      const pubspec = '''
name: sample
dependencies:
  core:
    path: ../core
  dio: ^5.4.0
  retrofit: ^4.9.2

dev_dependencies:
  retrofit_generator: 10.2.3
  build_runner: ^2.0.4
''';
      final dependencies = pubspecDependencies(pubspec);
      expect(dependencies, containsAll(['core', 'dio', 'retrofit']));
      // The trap this exists to avoid: a dev dependency is not importable
      // from `lib/` without tripping `depend_on_referenced_packages`.
      expect(dependencies, isNot(contains('retrofit_generator')));
      expect(dependencies, isNot(contains('build_runner')));
      // Nested keys belong to the dependency, not to the block.
      expect(dependencies, isNot(contains('path')));
    });

    test('resolves a package by path or by name', () {
      const packages = [
        WorkspacePackage(
          name: 'data_source',
          path: '/repo/modules/data_source',
          relativePath: 'modules/data_source',
          dependencies: {},
        ),
      ];
      expect(resolvePackage(packages, 'modules/data_source'), isNotNull);
      expect(resolvePackage(packages, 'modules/data_source/'), isNotNull);
      expect(resolvePackage(packages, 'data_source'), isNotNull);
      expect(resolvePackage(packages, 'apps/main'), isNull);
    });
  });

  group('console rendering', () {
    setUp(() => Console.forceStyle = false);
    tearDown(() => Console.forceStyle = null);

    test('menu aligns descriptions across sections', () {
      final rendered = Console.menu(
        title: 'Title',
        sections: const [
          MenuSection(
            title: 'first',
            entries: [
              MenuEntry(value: 1, label: 'short', description: 'a'),
            ],
          ),
          MenuSection(
            title: 'second',
            entries: [
              MenuEntry(value: 2, label: 'much longer label', description: 'b'),
            ],
          ),
        ],
      );

      // The label column is sized across every section, so a long label in one
      // group cannot push its neighbour's description out of line.
      final columns = rendered
          .split('\n')
          .where((line) => line.contains('  a') || line.contains('  b'))
          .map((line) => line.indexOf(RegExp('[ab]\$')))
          .toSet();
      expect(columns, hasLength(1));
      expect(rendered, contains('FIRST'));
      expect(rendered, contains('SECOND'));
    });

    test('drops escape codes when the terminal cannot render them', () {
      expect(Console.bold('plain'), 'plain');
      expect(Console.step('go'), isNot(contains('\x1B')));
    });
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

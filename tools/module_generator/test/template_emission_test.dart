import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';
import 'package:module_generator/common/generator_options.dart';
import 'package:module_generator/generator/repository_generator.dart';
import 'package:module_generator/res/templates/common_module/source.dart';
import 'package:module_generator/res/templates/detail_module/source.dart';
import 'package:module_generator/res/templates/entity/source.dart';
import 'package:module_generator/res/templates/listing_module/source.dart';
import 'package:module_generator/res/templates/repository/source.dart';
import 'package:module_generator/res/templates/usecase/source.dart';

/// Walks a template source map and yields every leaf template string keyed by
/// its dotted path (e.g. `bloc.state`). Recurses into nested maps and lists so
/// no template fragment is silently skipped; any other leaf type fails loudly
/// rather than dropping out of coverage unnoticed.
Map<String, String> _flatten(dynamic node, [String prefix = '']) {
  final result = <String, String>{};
  void visit(String path, dynamic value) {
    if (value is String) {
      result[path] = value;
    } else if (value is Map) {
      value.forEach((key, child) {
        visit(path.isEmpty ? '$key' : '$path.$key', child);
      });
    } else if (value is List) {
      for (var i = 0; i < value.length; i++) {
        visit('$path[$i]', value[i]);
      }
    } else {
      fail('unexpected template leaf type at "$path": ${value.runtimeType}');
    }
  }

  visit(prefix, node);
  return result;
}

/// The payload model a generated repository is typed against.
///
/// Data models live beside the client, not in `domain/entities` — those are
/// what the *module* templates are written against, which is why the two
/// paths below differ.
const _sampleModel = RepositoryModel(
  className: 'SampleModel',
  path: 'lib/src/data/models/sample_model.dart',
  kind: ModelKind.freezed,
);

String _emit(
  String template, {
  String fileDir = _blocDir,
  RepositoryModel? model = _sampleModel,
}) => template.replaceContent(
  className: 'SampleFeature',
  moduleName: 'sample_feature',
  modelName: model == null ? repositoryModelType(null) : 'SampleModel',
  modelPath: 'lib/domain/entities/sample_model/sample_model.entity.dart',
  fileDir: fileDir,
  extra: repositoryModelTokens(targetDir: _repositoryDir, model: model),
);

/// Where `_sampleModel` lands relative to a repository in [_repositoryDir].
const _sampleModelImport = '../../../models/sample_model.dart';

const _blocDir = 'lib/presentation/modules/sample_feature/bloc';
const _moduleDir = 'lib/presentation/modules/sample_feature';

/// Collapses runs of whitespace so an assertion about a declaration is not a
/// hostage to where the formatter chose to wrap it.
String _collapsed(String source) => source.replaceAll(RegExp(r'\s+'), ' ');

const _repositoryDir = 'lib/src/data/data_source/repository/sample_feature';

void main() {
  final modules = {
    'common_module': commonModuleRes,
    'listing_module': listingModuleRes,
    'detail_module': detailModuleRes,
  };
  final transports = {
    'rest_repository': restRepositoryRes,
    'graphql_repository': graphqlRepositoryRes,
  };
  final allTemplates = {
    ...modules,
    ...transports,
    'usecase': usecaseRes,
    'entity': entityRes,
  };

  group('templates emit valid Dart', () {
    allTemplates.forEach((moduleName, source) {
      _flatten(source).forEach((path, template) {
        final emitted = _emit(template);

        // Module generation only substitutes the keys `replaceContent` knows
        // (class/module/model/import-anchor/route names), so ANY `%%...%%`
        // token left in an emitted template is a real defect, not just a key
        // this test forgot to feed.
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

        // `lines_longer_than_80_chars` is enabled in apps/main and analyzer
        // infos fail `make check`, so an over-long emitted line is a broken
        // generator, not a style nit. The generator runs `dart format` over
        // its output; anything the formatter cannot split has to be wrapped
        // in the template itself.
        //
        // Directives are exempt, matching the lint itself: it does not report
        // a line whose overflow is one unbreakable token, which is what a long
        // import URI is (verified against apps/main's analysis_options).
        test('$moduleName/$path stays inside 80 columns', () {
          final directive = RegExp(r'^\s*(import|export|part)\s');
          final overLong = emitted
              .split('\n')
              .where((line) => line.length > 80)
              .where((line) => !directive.hasMatch(line))
              .toList();
          expect(
            overLong,
            isEmpty,
            reason:
                'these emitted lines exceed 80 chars in $moduleName/$path:\n'
                '${overLong.join('\n')}',
          );
        });

        // The repo lints `flutter_style_todos`; a bare `// TODO:` is an
        // analyzer info, which fails the `make check` gate. So is a TODO
        // inside a `///` doc comment — the lint only accepts `// TODO(x):`.
        test('$moduleName/$path uses flutter-style TODOs', () {
          final badTodos = emitted
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.contains('TODO'))
              .where(
                (line) => !RegExp(r'^// TODO\([^)]+\):').hasMatch(line),
              )
              .toList();
          expect(
            badTodos,
            isEmpty,
            reason:
                'TODOs in $moduleName/$path must read `// TODO(template): …` '
                '(plain comment, never `///`):\n${badTodos.join('\n')}',
          );
        });
      });
    });
  });

  group('module screen templates use the standard screen shell', () {
    modules.forEach((moduleName, source) {
      final views = source['views']! as Map<String, String>;
      final emitted = _emit(
        views['screen']!,
        fileDir: 'lib/presentation/modules/sample_feature/views',
      );

      test('$moduleName emits ScreenForm without a cached ThemeData', () {
        expect(emitted, contains('return ScreenForm('));
        expect(emitted, isNot(contains('late ThemeData')));
        expect(emitted, isNot(contains('_themeData = context.theme')));
      });

      // Every override of a `@mustCallSuper` lifecycle hook needs the
      // annotation, or `annotate_overrides` fails the gate.
      test('$moduleName annotates every lifecycle override', () {
        for (final hook in ['void dispose()', 'void initState()']) {
          if (!emitted.contains(hook)) {
            continue;
          }
          expect(
            emitted,
            contains('@override\n  $hook'),
            reason: '$hook in $moduleName is missing @override',
          );
        }
      });

      test('$moduleName declares routeName as a const', () {
        expect(emitted, contains('static const String routeName'));
      });
    });
  });

  group('state templates match the repo bloc shape', () {
    modules.forEach((moduleName, source) {
      final bloc = source['bloc']! as Map<String, String>;
      final emitted = _emit(bloc['state']!);

      // freezed 3 emits factory parameters the analyzer reports as unused on a
      // private class; `signin_state.dart` carries both codes for the same
      // reason.
      test('$moduleName ignores freezed private-class noise', () {
        expect(
          emitted,
          startsWith(
            '// ignore_for_file: unused_element, unused_element_parameter',
          ),
        );
      });

      test('$moduleName declares _StateData as abstract, not sealed', () {
        expect(emitted, contains('abstract class _StateData with '));
        expect(emitted, isNot(contains('sealed class _StateData')));
      });

      // resolveState throws a descriptive StateError for any state missing
      // from _factories, so every emitted state class must be registered.
      test('$moduleName registers every state class in _factories', () {
        final declared = RegExp(
          r'class (\w+) extends SampleFeatureState',
        ).allMatches(emitted).map((m) => m.group(1)!).toSet();
        expect(declared, isNotEmpty);
        for (final state in declared) {
          expect(
            emitted,
            contains('$state: (data) => $state(data: data)'),
            reason: '$state is not registered in _factories',
          );
        }
      });
    });
  });

  group('blocs follow fl-bloc-pattern', () {
    modules.forEach((moduleName, source) {
      final emitted = _emit((source['bloc']! as Map<String, String>)['bloc']!);

      // AGENTS.md: bloc exports come through package:core, and `bloc` is not a
      // declared dependency of apps/main at all.
      test('$moduleName imports bloc through package:core', () {
        expect(emitted, contains("import 'package:core/core.dart';"));
        expect(emitted, isNot(contains('package:bloc/bloc.dart')));
        expect(emitted, isNot(contains('package:flutter_bloc/flutter_bloc')));
      });

      test('$moduleName does not hide the stale Order symbol', () {
        expect(emitted, isNot(contains('hide Order')));
      });

      // Registering a handler for the abstract base event makes every future
      // concrete event double-handled.
      test('$moduleName never registers a handler on the base event', () {
        expect(emitted, isNot(contains('on<SampleFeatureEvent>')));
      });
    });
  });

  group('repository templates emit real retrofit clients', () {
    // The complaint the new templates answer: the old ones told you to go add
    // an endpoint to `RestApiRepository` — a class in `core`, a package a
    // feature cannot edit — and emitted a `Future.value()` stub in the
    // meantime. A repository here is the retrofit client, the shape every real
    // one in this repo already has.
    transports.forEach((label, source) {
      final repository = _emit(
        source['repository']!,
        fileDir: _repositoryDir,
      );

      test('$label declares a @RestApi client with a factory redirect', () {
        expect(repository, contains('@RestApi()'));
        // `_X` is what retrofit_generator writes into the part; without the
        // redirect there is no way to construct the client at all. Matched on
        // whitespace-collapsed source because the formatter is free to wrap a
        // long redirect onto the next line.
        expect(_collapsed(repository), contains('= _SampleFeature'));
        expect(
          repository,
          contains("import 'package:retrofit/retrofit.dart';"),
        );
        expect(repository, contains("import 'package:dio/dio.dart';"));
      });

      test('$label parts in the retrofit output', () {
        expect(
          repository,
          contains("part 'sample_feature_repository.g.dart';"),
        );
      });

      // The old templates split every repository into an abstract contract
      // and a `part` impl that did nothing but forward. Retrofit already
      // generates the implementation, so that layer had nothing in it.
      test('$label emits no hand-written impl', () {
        expect(source.keys, isNot(contains('repository.impl')));
        expect(repository, isNot(contains('RepositoryImpl')));
        expect(repository, isNot(contains('with DataRepository')));
      });

      // `dart:core` re-exports `Future`, so importing `dart:async` for it is
      // an `unnecessary_import` info — which fails `make check`.
      test('$label does not import dart:async for Future', () {
        expect(repository, isNot(contains("import 'dart:async';")));
      });

      // Every file the library imports or parts in has to be one the
      // generator actually writes for this transport, or build_runner output.
      test('$label references only files it emits', () {
        final emitted = source.keys
            .map((key) => 'sample_feature${repositoryFileSuffixes[key]!}')
            .toSet();
        final referenced = RegExp(
          r"""^\s*(?:import|part)\s+'([^':]+)'\s*;""",
          multiLine: true,
        ).allMatches(repository).map((match) => match.group(1)!);
        expect(referenced, isNotEmpty);
        for (final target in referenced) {
          if (target.endsWith('.g.dart')) {
            continue;
          }
          // The payload model is written by the same run, just into the
          // package's model folder rather than beside the client.
          if (target == _sampleModelImport) {
            continue;
          }
          expect(
            emitted,
            contains(target),
            reason: '$label imports $target but never writes it',
          );
        }
      });
    });

    // The template used to emit a five-verb CRUD set against paths no real
    // API has, so the first thing anyone did was delete four methods. One
    // worked endpoint teaches the same shape with nothing to clean up.
    test('rest emits exactly one endpoint', () {
      final repository = _emit(
        restRepositoryRes['repository']!,
        fileDir: _repositoryDir,
      );
      expect(
        RegExp(r'@(GET|POST|PUT|DELETE|PATCH)\(').allMatches(repository),
        hasLength(1),
      );
      // `@GET` with a path template is the case people get wrong, so it is
      // the one worth demonstrating.
      expect(repository, contains("@GET('/sample-feature/{id}')"));
      expect(repository, contains("@Path('id')"));
      // Paths are relative to the Dio base URL; a host here would pin every
      // environment to whichever one the template was written against.
      expect(repository, isNot(contains('http')));
      // The envelope every endpoint in this template answers with.
      expect(repository, contains('ApiResponse<'));
      expect(repository, contains("import 'package:core/core.dart';"));
    });

    // A repository with nothing to return is not much of a repository, so the
    // generator scaffolds the model in the same run and types the endpoint
    // against it.
    test('rest returns the scaffolded model', () {
      final repository = _emit(
        restRepositoryRes['repository']!,
        fileDir: _repositoryDir,
      );
      expect(repository, contains('Future<ApiResponse<SampleModel>>'));
      expect(repository, contains("import '$_sampleModelImport';"));
    });

    test('graphql decodes the scaffolded model', () {
      final repository = _emit(
        graphqlRepositoryRes['repository']!,
        fileDir: _repositoryDir,
      );
      expect(repository, contains('Future<SampleModel?> getDetail'));
      expect(repository, contains('SampleModel.fromJson(node)'));
      expect(repository, contains("import '$_sampleModelImport';"));
    });

    // `--model none` still has to produce something that compiles: an empty
    // import line would not parse, and `Map<String, dynamic>.fromJson` does
    // not exist.
    test('both transports fall back to a map when no model is scaffolded', () {
      for (final source in transports.values) {
        final repository = _emit(
          source['repository']!,
          fileDir: _repositoryDir,
          model: null,
        );
        expect(repository, contains('Map<String, dynamic>'));
        expect(repository, isNot(contains('SampleModel')));
        expect(repository, isNot(contains(_sampleModelImport)));
        expect(repository, isNot(contains('.fromJson(node)')));
        expect(parseString(content: repository).errors, isEmpty);
      }
    });

    test('rest emits no fragment file', () {
      expect(restRepositoryRes.keys, isNot(contains('fragment')));
    });

    test('graphql routes every operation through one endpoint', () {
      final repository = _emit(
        graphqlRepositoryRes['repository']!,
        fileDir: _repositoryDir,
      );
      // GraphQL routes by document, not by path, so there is exactly one
      // annotated method and the repository above it does the composing.
      expect(
        RegExp(r'@(GET|POST|PUT|DELETE)\(').allMatches(repository),
        hasLength(1),
      );
      expect(repository, contains("@POST('')"));
      expect(repository, contains('@injectable'));
      expect(repository, contains('class SampleFeatureRepository'));
      expect(repository, contains('SampleFeatureGraphqlApi'));
    });

    test('graphql keeps the fragment beside the operations that spread it', () {
      final fragment = _emit(
        graphqlRepositoryRes['fragment']!,
        fileDir: _repositoryDir,
      );
      // A document only resolves `...XFields` when the fragment is appended,
      // which is the whole reason `request` exists.
      expect(fragment, contains('...SampleFeatureFields'));
      expect(fragment, contains(r"'$operation\n$fields'"));
      // Raw strings keep GraphQL's own `$variable` syntax literal; a plain
      // Dart string would interpolate it away at compile time.
      expect(fragment, contains("static const String query = r'''"));
      expect(fragment, contains(r'query GetSampleFeature($id: ID!)'));
      // One document, to match the one method on the repository.
      expect(fragment, isNot(contains('mutation ')));
    });

    test('graphql checks errors before reading data', () {
      final repository = _emit(
        graphqlRepositoryRes['repository']!,
        fileDir: _repositoryDir,
      );
      expect(
        repository.indexOf("response['errors']"),
        lessThan(repository.indexOf("response['data']")),
        reason: 'a 200 with an errors array would read as a success',
      );
    });

    test('every template key has a file-name suffix', () {
      for (final source in transports.values) {
        for (final key in source.keys) {
          expect(repositoryFileSuffixes, contains(key));
        }
      }
    });
  });

  group('every module template ships a coordinator', () {
    // Every module now gets a coordinator so navigation into it has exactly
    // one owner. What differs is how much it owns: templates with route
    // arguments translate them, argument-free ones hold the entry-guard seam.
    modules.forEach((moduleName, source) {
      test('$moduleName emits a coordinator', () {
        expect(source.containsKey('coordinator'), isTrue);
      });

      test('$moduleName barrel exports the coordinator', () {
        final emitted = _emit(
          source['module']! as String,
          fileDir: _moduleDir,
        );
        expect(emitted, contains("export 'sample_feature_coordinator.dart';"));
      });

      test('$moduleName coordinator extends BuildContext', () {
        final emitted = _emit(
          source['coordinator']! as String,
          fileDir: _moduleDir,
        );
        expect(
          emitted,
          contains('extension SampleFeatureCoordinator on BuildContext'),
        );
        // Route paths belong to the screen, never spelled out in a caller.
        expect(emitted, contains('SampleFeatureScreen.routeName'));
        expect(emitted, isNot(contains("push(this, '/")));
      });

      test('$moduleName coordinator takes a PushBehavior', () {
        final emitted = _emit(
          source['coordinator']! as String,
          fileDir: _moduleDir,
        );
        expect(
          emitted,
          contains('PushBehavior pushBehavior = const PushNamedBehavior()'),
        );
      });
    });

    // fl-route-config: the canonical getter is `adaptiveArguments`, never
    // `adaptive`. Only modules that actually carry route arguments build one.
    for (final moduleName in ['listing_module', 'detail_module']) {
      test('$moduleName coordinator passes adaptiveArguments', () {
        final emitted = _emit(
          modules[moduleName]!['coordinator']! as String,
          fileDir: _moduleDir,
        );
        expect(emitted, contains('SampleFeatureArgs('));
        expect(emitted, contains('.adaptiveArguments'));
        expect(emitted, isNot(contains('.adaptive,')));
      });
    }

    // An argument-free coordinator is the one shape that risks being a bare
    // forwarder, so it must say out loud when to delete it.
    test('common_module coordinator documents its own escape hatch', () {
      final emitted = _emit(
        commonModuleRes['coordinator']! as String,
        fileDir: _moduleDir,
      );
      expect(emitted, contains('TODO(template)'));
      expect(emitted, contains('delete this file'));
    });
  });
}

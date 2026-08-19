import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';
import 'package:module_generator/res/templates/common_module/source.dart';
import 'package:module_generator/res/templates/detail_module/source.dart';
import 'package:module_generator/res/templates/entity/source.dart';
import 'package:module_generator/res/templates/listing_module/source.dart';
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

String _emit(String template, {String fileDir = _blocDir}) =>
    template.replaceContent(
      className: 'SampleFeature',
      moduleName: 'sample_feature',
      modelName: 'SampleModel',
      modelPath: 'lib/domain/entities/sample_model/sample_model.entity.dart',
      fileDir: fileDir,
    );

const _blocDir = 'lib/presentation/modules/sample_feature/bloc';
const _moduleDir = 'lib/presentation/modules/sample_feature';

void main() {
  final modules = {
    'common_module': commonModuleRes,
    'listing_module': listingModuleRes,
    'detail_module': detailModuleRes,
  };
  final allTemplates = {
    ...modules,
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

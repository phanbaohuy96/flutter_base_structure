import 'dart:io';

import 'package:fl_navigation/src/route_provider_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('buildRouteProvidersContent', () {
    test('generates relative imports for current-package providers', () async {
      final workspace = await Directory.systemTemp.createTemp(
        'route_provider_generator_test_',
      );
      addTearDown(() => workspace.delete(recursive: true));
      final appPackage = await _createPackage(workspace, 'app');

      final content = await buildRouteProvidersContent(
        packageDir: appPackage,
        outputPath: 'presentation/route/route_providers.config.dart',
        functionName: 'buildAppRouteProviders',
        registryClassName: 'AppRouteProviders',
        includePathDependencies: false,
        extraScanPaths: const [],
        currentPackageAssets: const [
          RouteProviderSource(
            path: 'lib/presentation/modules/auth/authentication_route.dart',
            content: '''
import 'package:fl_navigation/fl_navigation.dart';

@FlRouteProvider()
class AuthenticationRoute extends IRoute {}
''',
          ),
        ],
      );

      expect(
        content,
        contains(
          "import '../modules/auth/authentication_route.dart' as route_provider_0;",
        ),
      );
      expect(
        content,
        contains(
          'IRoute get authenticationRoute => '
          'route_provider_0.AuthenticationRoute();',
        ),
      );
      expect(content, contains('List<IRoute> buildAppRouteProviders()'));
    });

    test('includes only root route providers from path dependencies', () async {
      final workspace = await Directory.systemTemp.createTemp(
        'route_provider_generator_test_',
      );
      addTearDown(() => workspace.delete(recursive: true));
      final corePackage = await _createPackage(workspace, 'core');
      await _writeFile(
        corePackage,
        'lib/presentation/route/core_route.dart',
        '''
import 'package:fl_navigation/fl_navigation.dart' as navigation;

@navigation.FlRouteProvider(isRoot: true)
class CoreRoute extends navigation.IRoute {}
''',
      );
      await _writeFile(
        corePackage,
        'lib/presentation/modules/internal_route.dart',
        '''
import 'package:fl_navigation/fl_navigation.dart';

@FlRouteProvider()
class InternalRoute extends IRoute {}
''',
      );
      final appPackage = await _createPackage(
        workspace,
        'app',
        pubspecBody: '''
dependencies:
  core:
    path: ../core
''',
      );

      final content = await buildRouteProvidersContent(
        packageDir: appPackage,
        outputPath: 'presentation/route/route_providers.config.dart',
        functionName: 'buildAppRouteProviders',
        registryClassName: 'AppRouteProviders',
        includePathDependencies: true,
        extraScanPaths: const [],
        currentPackageAssets: const [
          RouteProviderSource(
            path: 'lib/presentation/modules/auth/authentication_route.dart',
            content: '''
import 'package:fl_navigation/fl_navigation.dart';

@FlRouteProvider()
class AuthenticationRoute extends IRoute {}
''',
          ),
        ],
      );

      expect(
        content,
        contains(
          "import 'package:core/presentation/route/core_route.dart' "
          'as route_provider_0;',
        ),
      );
      expect(
        content,
        contains('IRoute get coreRoute => route_provider_0.CoreRoute();'),
      );
      expect(content, isNot(contains('InternalRoute')));
      expect(
        content.indexOf('coreRoute'),
        lessThan(content.indexOf('authenticationRoute')),
      );
    });

    test(
      'detects aliased annotations, metadata, modifiers, and implements IRoute',
      () async {
        final workspace = await Directory.systemTemp.createTemp(
          'route_provider_generator_test_',
        );
        addTearDown(() => workspace.delete(recursive: true));
        final appPackage = await _createPackage(workspace, 'app');

        final content = await buildRouteProvidersContent(
          packageDir: appPackage,
          outputPath: 'presentation/route/route_providers.config.dart',
          functionName: 'buildAppRouteProviders',
          registryClassName: 'AppRouteProviders',
          includePathDependencies: false,
          extraScanPaths: const [],
          currentPackageAssets: const [
            RouteProviderSource(
              path: 'lib/presentation/modules/feature/feature_route.dart',
              content: '''
import 'package:fl_navigation/fl_navigation.dart' as navigation;

@navigation.FlRouteProvider()
@Deprecated('kept')
final class FeatureRoute implements navigation.IRoute {}
''',
            ),
          ],
        );

        expect(content, contains('IRoute get featureRoute =>'));
        expect(content, contains('route_provider_0.FeatureRoute();'));
      },
    );

    test(
      'deduplicates accessor names for matching provider class names',
      () async {
        final workspace = await Directory.systemTemp.createTemp(
          'route_provider_generator_test_',
        );
        addTearDown(() => workspace.delete(recursive: true));
        final appPackage = await _createPackage(workspace, 'app');

        final content = await buildRouteProvidersContent(
          packageDir: appPackage,
          outputPath: 'presentation/route/route_providers.config.dart',
          functionName: 'buildAppRouteProviders',
          registryClassName: 'AppRouteProviders',
          includePathDependencies: false,
          extraScanPaths: const [],
          currentPackageAssets: const [
            RouteProviderSource(
              path: 'lib/presentation/modules/first/feature_route.dart',
              content: '''
import 'package:fl_navigation/fl_navigation.dart';

@FlRouteProvider()
class FeatureRoute extends IRoute {}
''',
            ),
            RouteProviderSource(
              path: 'lib/presentation/modules/second/feature_route.dart',
              content: '''
import 'package:fl_navigation/fl_navigation.dart';

@FlRouteProvider()
class FeatureRoute extends IRoute {}
''',
            ),
          ],
        );

        expect(content, contains('IRoute get featureRoute =>'));
        expect(content, contains('IRoute get featureRoute2 =>'));
        expect(content, contains('      featureRoute,'));
        expect(content, contains('      featureRoute2,'));
      },
    );
  });

  group('hasRouteProviderAnnotation', () {
    test('matches prefixed and unprefixed route provider annotations', () {
      expect(hasRouteProviderAnnotation('@FlRouteProvider()'), isTrue);
      expect(
        hasRouteProviderAnnotation('@navigation.FlRouteProvider()'),
        isTrue,
      );
      expect(hasRouteProviderAnnotation('@OtherAnnotation()'), isFalse);
    });
  });

  group('shouldScanRouteProviderPath', () {
    test('ignores generated Dart outputs', () {
      expect(shouldScanRouteProviderPath('lib/auth_route.dart'), isTrue);
      expect(shouldScanRouteProviderPath('lib/auth_route.g.dart'), isFalse);
      expect(
        shouldScanRouteProviderPath('lib/auth_route.freezed.dart'),
        isFalse,
      );
      expect(
        shouldScanRouteProviderPath('lib/auth_route.config.dart'),
        isFalse,
      );
    });
  });
}

Future<Directory> _createPackage(
  Directory workspace,
  String name, {
  String pubspecBody = '',
}) async {
  final packageDir = Directory(path.join(workspace.path, name));
  await packageDir.create(recursive: true);
  await Directory(path.join(packageDir.path, 'lib')).create();
  await File(path.join(packageDir.path, 'pubspec.yaml')).writeAsString('''
name: $name
$pubspecBody
''');
  return packageDir;
}

Future<void> _writeFile(
  Directory packageDir,
  String relativePath,
  String content,
) async {
  final file = File(path.join(packageDir.path, relativePath));
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
}

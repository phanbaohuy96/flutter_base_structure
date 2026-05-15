import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:glob/glob.dart';

import '../src/route_provider_generator.dart';

Builder routeProviderBuilder(BuilderOptions options) {
  return RouteProviderBuilder(options);
}

class RouteProviderBuilder implements Builder {
  const RouteProviderBuilder(this.options);

  static const outputPath = 'presentation/route/route_providers.config.dart';
  static const defaultFunctionName = 'buildAppRouteProviders';
  static const defaultRegistryClassName = 'AppRouteProviders';

  final BuilderOptions options;

  String get functionName =>
      options.config['function_name'] as String? ?? defaultFunctionName;

  String get registryClassName =>
      options.config['registry_class_name'] as String? ??
      defaultRegistryClassName;

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'$lib$': [outputPath],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final packageDir = Directory.current;
    final content = await buildRouteProvidersContent(
      packageDir: packageDir,
      outputPath: outputPath,
      functionName: functionName,
      registryClassName: registryClassName,
      includePathDependencies: true,
      extraScanPaths: const [],
      currentPackageAssets: _readCurrentPackageAssets(buildStep),
    );

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/$outputPath'),
      content,
    );
  }

  Future<List<RouteProviderSource>> _readCurrentPackageAssets(
    BuildStep buildStep,
  ) async {
    final sources = <RouteProviderSource>[];
    await for (final assetId in buildStep.findAssets(Glob('lib/**.dart'))) {
      final path = assetId.path;
      if (!shouldScanRouteProviderPath(path)) {
        continue;
      }
      final content = await buildStep.readAsString(assetId);
      if (!content.contains('@FlRouteProvider')) {
        continue;
      }
      sources.add(RouteProviderSource(path: path, content: content));
    }
    return sources;
  }
}

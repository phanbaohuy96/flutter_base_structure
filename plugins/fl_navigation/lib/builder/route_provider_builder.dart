import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

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

  bool get includePathDependencies =>
      options.config['include_path_dependencies'] as bool? ?? true;

  List<Directory> get extraScanPaths {
    final value = options.config['extra_scan_paths'];
    if (value == null) {
      return const [];
    }
    if (value is String) {
      return [_resolveScanPath(value)];
    }
    if (value is Iterable) {
      return value.map((item) => _resolveScanPath(item.toString())).toList();
    }
    throw ArgumentError.value(
      value,
      'extra_scan_paths',
      'Expected a string or list of strings.',
    );
  }

  Directory _resolveScanPath(String value) {
    return Directory(path.normalize(path.absolute(value)));
  }

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
      includePathDependencies: includePathDependencies,
      extraScanPaths: extraScanPaths,
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
      if (!hasRouteProviderAnnotation(content)) {
        continue;
      }
      sources.add(RouteProviderSource(path: path, content: content));
    }
    return sources;
  }
}

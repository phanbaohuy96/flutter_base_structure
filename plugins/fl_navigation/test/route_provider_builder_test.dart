import 'dart:io';

import 'package:build/build.dart';
import 'package:fl_navigation/builder/route_provider_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('RouteProviderBuilder', () {
    test('uses default scan options', () {
      const builder = RouteProviderBuilder(BuilderOptions({}));

      expect(builder.includePathDependencies, isTrue);
      expect(builder.extraScanPaths, isEmpty);
    });

    test('reads scan options from builder config', () {
      final absolutePath = path.join(Directory.systemTemp.path, 'routes');
      const relativePath = '../core';
      final builder = RouteProviderBuilder(
        BuilderOptions({
          'include_path_dependencies': false,
          'extra_scan_paths': [relativePath, absolutePath],
        }),
      );

      expect(builder.includePathDependencies, isFalse);
      expect(builder.extraScanPaths.map((directory) => directory.path), [
        path.normalize(path.join(Directory.current.path, relativePath)),
        path.normalize(absolutePath),
      ]);
    });

    test('accepts a single extra scan path', () {
      const relativePath = '../shared_routes';
      const builder = RouteProviderBuilder(
        BuilderOptions({'extra_scan_paths': relativePath}),
      );

      expect(
        builder.extraScanPaths.single.path,
        path.normalize(path.join(Directory.current.path, relativePath)),
      );
    });
  });
}

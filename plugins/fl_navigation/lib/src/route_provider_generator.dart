import 'dart:async';
import 'dart:io';

import 'package:fl_utils/fl_utils.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class RouteProviderSource {
  const RouteProviderSource({required this.path, required this.content});

  final String path;
  final String content;
}

class _ScanTarget {
  const _ScanTarget({
    required this.packageDir,
    required this.packageName,
    required this.isCurrentPackage,
  });

  final Directory packageDir;
  final String packageName;
  final bool isCurrentPackage;

  Directory get libDir => Directory(path.join(packageDir.path, 'lib'));
}

class _RouteProviderDeclaration {
  const _RouteProviderDeclaration({
    required this.className,
    required this.importUri,
    required this.isRoot,
  });

  final String className;
  final String importUri;
  final bool isRoot;
}

Future<String> buildRouteProvidersContent({
  required Directory packageDir,
  required String outputPath,
  required String functionName,
  required String registryClassName,
  required bool includePathDependencies,
  required Iterable<Directory> extraScanPaths,
  FutureOr<List<RouteProviderSource>>? currentPackageAssets,
}) async {
  final targets = await _buildScanTargets(
    packageDir: packageDir,
    includePathDependencies: includePathDependencies,
    extraScanPaths: extraScanPaths,
  );
  final currentAssets = await currentPackageAssets;
  final scannedProviders = await Future.wait(
    targets.map((target) {
      return _scanTarget(
        target,
        outputPath: outputPath,
        currentPackageAssets: target.isCurrentPackage ? currentAssets : null,
      );
    }),
  );
  final providers = scannedProviders.expand((items) => items).toList()
    ..sort(_compareRouteProviders);

  return _buildFileContent(
    providers,
    functionName: functionName,
    registryClassName: registryClassName,
  );
}

bool shouldScanRouteProviderPath(String filePath) {
  final basename = path.basename(filePath);
  return basename.endsWith('.dart') &&
      !basename.endsWith('.g.dart') &&
      !basename.endsWith('.freezed.dart') &&
      !basename.endsWith('.config.dart');
}

final _routeProviderAnnotationPattern = RegExp(
  r'@(?:[A-Za-z_]\w*\.)?FlRouteProvider\b\s*(?:\(([\s\S]*?)\))?',
  multiLine: true,
);

bool hasRouteProviderAnnotation(String content) {
  return _routeProviderAnnotationPattern.hasMatch(content);
}

Future<List<_ScanTarget>> _buildScanTargets({
  required Directory packageDir,
  required bool includePathDependencies,
  required Iterable<Directory> extraScanPaths,
}) async {
  final currentPackageName = _readPackageName(packageDir);
  final targets = <String, _ScanTarget>{
    _normalize(packageDir.path): _ScanTarget(
      packageDir: packageDir,
      packageName: currentPackageName,
      isCurrentPackage: true,
    ),
  };

  if (includePathDependencies) {
    for (final dependencyDir in _readPathDependencyDirs(packageDir)) {
      final packageName = _tryReadPackageName(dependencyDir);
      if (packageName == null) {
        continue;
      }
      targets.putIfAbsent(
        _normalize(dependencyDir.path),
        () => _ScanTarget(
          packageDir: dependencyDir,
          packageName: packageName,
          isCurrentPackage: false,
        ),
      );
    }
  }

  for (final scanPath in extraScanPaths) {
    final packageName = _tryReadPackageName(scanPath);
    if (packageName == null) {
      continue;
    }
    targets.putIfAbsent(
      _normalize(scanPath.path),
      () => _ScanTarget(
        packageDir: scanPath,
        packageName: packageName,
        isCurrentPackage: false,
      ),
    );
  }

  return targets.values.toList();
}

Future<List<_RouteProviderDeclaration>> _scanTarget(
  _ScanTarget target, {
  required String outputPath,
  List<RouteProviderSource>? currentPackageAssets,
}) async {
  if (currentPackageAssets != null) {
    return _readRouteProvidersFromSources(
      sources: currentPackageAssets,
      outputPath: outputPath,
      target: target,
    );
  }

  final providers = <_RouteProviderDeclaration>[];
  final libDir = target.libDir;
  if (!await libDir.exists()) {
    return providers;
  }

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is! File || !shouldScanRouteProviderPath(entity.path)) {
      continue;
    }

    final content = await entity.readAsString();
    if (!hasRouteProviderAnnotation(content)) {
      continue;
    }
    final relativePath = _toPosix(
      path.relative(entity.path, from: libDir.path),
    );
    providers.addAll(
      _readRouteProviders(
        content: content,
        importUri: 'package:${target.packageName}/$relativePath',
        isCurrentPackage: target.isCurrentPackage,
      ),
    );
  }

  return providers;
}

List<_RouteProviderDeclaration> _readRouteProvidersFromSources({
  required List<RouteProviderSource> sources,
  required String outputPath,
  required _ScanTarget target,
}) {
  final providers = <_RouteProviderDeclaration>[];

  final outputParent = path.dirname(path.join('lib', outputPath));
  for (final source in sources) {
    providers.addAll(
      _readRouteProviders(
        content: source.content,
        importUri: _toPosix(path.relative(source.path, from: outputParent)),
        isCurrentPackage: target.isCurrentPackage,
      ),
    );
  }

  return providers;
}

List<_RouteProviderDeclaration> _readRouteProviders({
  required String content,
  required String importUri,
  required bool isCurrentPackage,
}) {
  final matches = _routeProviderAnnotationPattern.allMatches(content);
  final declarations = <_RouteProviderDeclaration>[];

  for (final match in matches) {
    final declaration = _readRouteProviderDeclaration(
      content: content,
      annotationEnd: match.end,
      annotationArgs: match.group(1) ?? '',
      importUri: importUri,
      isCurrentPackage: isCurrentPackage,
    );
    if (declaration != null) {
      declarations.add(declaration);
    }
  }

  return declarations;
}

_RouteProviderDeclaration? _readRouteProviderDeclaration({
  required String content,
  required int annotationEnd,
  required String annotationArgs,
  required String importUri,
  required bool isCurrentPackage,
}) {
  final classStart = _skipWhitespaceAndMetadata(content, annotationEnd);
  final classMatch = RegExp(
    r'(?:(?:abstract|base|final|interface|sealed)\s+)*class\s+'
    r'([A-Za-z_]\w*)\b([\s\S]*?)(?=\{)',
    multiLine: true,
  ).matchAsPrefix(content, classStart);
  if (classMatch == null || !_hasIRouteSupertype(classMatch.group(2)!)) {
    return null;
  }

  final isRoot = RegExp(r'\bisRoot\s*:\s*true\b').hasMatch(annotationArgs);
  if (!isCurrentPackage && !isRoot) {
    return null;
  }

  return _RouteProviderDeclaration(
    className: classMatch.group(1)!,
    importUri: importUri,
    isRoot: isRoot,
  );
}

bool _hasIRouteSupertype(String classHeader) {
  const iRouteType = r'(?:[A-Za-z_]\w*\.)?IRoute';
  return RegExp(r'\bextends\s+' + iRouteType + r'\b').hasMatch(classHeader) ||
      RegExp(
        r'\bimplements\b[\s\S]*?(?:^|[\s,<])' + iRouteType + r'\b',
      ).hasMatch(classHeader);
}

int _skipWhitespaceAndMetadata(String content, int index) {
  var cursor = index;
  while (true) {
    cursor = _skipWhitespace(content, cursor);
    if (cursor >= content.length || content.codeUnitAt(cursor) != 0x40) {
      return cursor;
    }

    final nextCursor = _skipAnnotation(content, cursor);
    if (nextCursor == cursor) {
      return cursor;
    }
    cursor = nextCursor;
  }
}

int _skipAnnotation(String content, int index) {
  var cursor = _skipQualifiedIdentifier(content, index + 1);
  if (cursor == index + 1) {
    return index;
  }

  cursor = _skipWhitespace(content, cursor);
  if (cursor < content.length && content.codeUnitAt(cursor) == 0x28) {
    return _skipBalancedParentheses(content, cursor);
  }
  return cursor;
}

int _skipQualifiedIdentifier(String content, int index) {
  var cursor = _skipIdentifier(content, index);
  while (cursor < content.length && content.codeUnitAt(cursor) == 0x2E) {
    final nextCursor = _skipIdentifier(content, cursor + 1);
    if (nextCursor == cursor + 1) {
      return cursor;
    }
    cursor = nextCursor;
  }
  return cursor;
}

int _skipIdentifier(String content, int index) {
  var cursor = index;
  while (cursor < content.length) {
    final codeUnit = content.codeUnitAt(cursor);
    if (!_isIdentifierCodeUnit(codeUnit)) {
      return cursor;
    }
    cursor++;
  }
  return cursor;
}

bool _isIdentifierCodeUnit(int codeUnit) {
  return codeUnit == 0x5F ||
      codeUnit >= 0x30 && codeUnit <= 0x39 ||
      codeUnit >= 0x41 && codeUnit <= 0x5A ||
      codeUnit >= 0x61 && codeUnit <= 0x7A;
}

int _skipWhitespace(String content, int index) {
  var cursor = index;
  while (cursor < content.length && _isWhitespace(content.codeUnitAt(cursor))) {
    cursor++;
  }
  return cursor;
}

bool _isWhitespace(int codeUnit) {
  return codeUnit == 0x09 ||
      codeUnit == 0x0A ||
      codeUnit == 0x0D ||
      codeUnit == 0x20;
}

int _skipBalancedParentheses(String content, int index) {
  var cursor = index;
  var depth = 0;
  while (cursor < content.length) {
    final codeUnit = content.codeUnitAt(cursor);
    if (codeUnit == 0x28) {
      depth++;
    } else if (codeUnit == 0x29) {
      depth--;
      if (depth == 0) {
        return cursor + 1;
      }
    }
    cursor++;
  }
  return cursor;
}

String _buildFileContent(
  List<_RouteProviderDeclaration> providers, {
  required String functionName,
  required String registryClassName,
}) {
  final importAliases = <String, String>{};
  for (final provider in providers) {
    importAliases.putIfAbsent(
      provider.importUri,
      () => 'route_provider_${importAliases.length}',
    );
  }
  final accessorNames = _buildAccessorNames(providers);

  final packageImports = <String>[
    "import 'package:fl_navigation/fl_navigation.dart';",
    for (final entry in importAliases.entries)
      if (entry.key.startsWith('package:'))
        "import '${entry.key}' as ${entry.value};",
  ]..sort();
  final relativeImports = <String>[
    for (final entry in importAliases.entries)
      if (!entry.key.startsWith('package:'))
        "import '${entry.key}' as ${entry.value};",
  ]..sort();

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln();
  for (final importDirective in packageImports) {
    buffer.writeln(importDirective);
  }
  if (relativeImports.isNotEmpty) {
    buffer.writeln();
    for (final importDirective in relativeImports) {
      buffer.writeln(importDirective);
    }
  }
  buffer
    ..writeln()
    ..writeln('class $registryClassName {')
    ..writeln('  const $registryClassName();')
    ..writeln();

  for (var i = 0; i < providers.length; i++) {
    final provider = providers[i];
    final alias = importAliases[provider.importUri]!;
    buffer.writeln(
      '  IRoute get ${accessorNames[i]} => $alias.${provider.className}();',
    );
  }

  buffer
    ..writeln()
    ..writeln('  List<IRoute> get all {')
    ..writeln('    return [');
  for (final accessorName in accessorNames) {
    buffer.writeln('      $accessorName,');
  }
  buffer
    ..writeln('    ];')
    ..writeln('  }')
    ..writeln('}')
    ..writeln()
    ..writeln('List<IRoute> $functionName() {')
    ..writeln('  return const $registryClassName().all;')
    ..writeln('}')
    ..writeln();

  return buffer.toString();
}

List<String> _buildAccessorNames(List<_RouteProviderDeclaration> providers) {
  final usedNames = <String, int>{};

  return providers.map((provider) {
    final baseName = provider.className.camelCase;
    final count = (usedNames[baseName] ?? 0) + 1;
    usedNames[baseName] = count;
    if (count == 1) {
      return baseName;
    }
    return '$baseName$count';
  }).toList();
}

int _compareRouteProviders(
  _RouteProviderDeclaration first,
  _RouteProviderDeclaration second,
) {
  if (first.isRoot != second.isRoot) {
    return first.isRoot ? -1 : 1;
  }
  final importCompare = first.importUri.compareTo(second.importUri);
  if (importCompare != 0) {
    return importCompare;
  }
  return first.className.compareTo(second.className);
}

Iterable<Directory> _readPathDependencyDirs(Directory packageDir) sync* {
  final pubspec = _readPubspec(packageDir);
  for (final sectionName in ['dependencies', 'dependency_overrides']) {
    final section = pubspec[sectionName];
    if (section is! YamlMap) {
      continue;
    }

    for (final entry in section.entries) {
      final dependency = entry.value;
      if (dependency is YamlMap && dependency['path'] != null) {
        yield Directory(
          path.normalize(
            path.join(packageDir.path, dependency['path'].toString()),
          ),
        );
      }
    }
  }
}

YamlMap _readPubspec(Directory packageDir) {
  final pubspecFile = File(path.join(packageDir.path, 'pubspec.yaml'));
  return loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
}

String _readPackageName(Directory packageDir) {
  final pubspec = _readPubspec(packageDir);
  return pubspec['name'] as String;
}

String? _tryReadPackageName(Directory packageDir) {
  final pubspecFile = File(path.join(packageDir.path, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    return null;
  }
  final pubspec = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
  return pubspec['name'] as String?;
}

String _normalize(String value) {
  return path.normalize(path.absolute(value));
}

String _toPosix(String value) {
  return path.posix.joinAll(path.split(value));
}

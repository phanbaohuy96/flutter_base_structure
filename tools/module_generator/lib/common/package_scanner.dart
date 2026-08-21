import 'dart:io';

import 'package:path/path.dart' as p;

/// One Dart/Flutter package found in the workspace.
///
/// Carries the declared dependency names because two generators need them:
/// the repository generator refuses to emit a retrofit client into a package
/// that does not depend on `retrofit`, and the picker shows the operator which
/// packages can host one before they choose.
class WorkspacePackage {
  const WorkspacePackage({
    required this.name,
    required this.path,
    required this.relativePath,
    required this.dependencies,
  });

  /// `name:` from the package's pubspec.
  final String name;

  /// Absolute path to the package root.
  final String path;

  /// Path relative to the workspace root, used for display and for the
  /// `run_module_generator.sh` argument.
  final String relativePath;

  /// Keys of the pubspec's `dependencies:` block.
  ///
  /// Runtime dependencies only — `dev_dependencies` are deliberately excluded
  /// because `depend_on_referenced_packages` fails analysis for anything under
  /// `lib/` that imports a package listed only as a dev dependency. That is
  /// exactly the trap `apps/main` sets: it has `retrofit_generator` but not
  /// `retrofit`, so a retrofit client generated there would build and then
  /// fail `make check`.
  final Set<String> dependencies;

  bool dependsOn(String package) => dependencies.contains(package);

  /// Whether a retrofit client can be generated into this package.
  bool get supportsRetrofit => dependsOn('retrofit') && dependsOn('dio');

  /// Short capability note shown next to the package in the picker.
  String get capabilities {
    final notes = <String>[
      if (supportsRetrofit) 'retrofit' else 'no retrofit',
    ];
    return notes.join(', ');
  }
}

/// Walks up from [start] looking for the workspace root.
///
/// The generator is launched from inside a package (`dart run
/// module_generator` needs the package to depend on it), so the root has to be
/// discovered rather than assumed. `makefile` plus `.git` is the marker: both
/// sit at the root of this template and neither appears in a package.
Directory? findWorkspaceRoot([Directory? start]) {
  var current = start ?? Directory.current;
  for (var depth = 0; depth < 8; depth++) {
    final hasMakefile = File(p.join(current.path, 'makefile')).existsSync();
    final hasGit = Directory(p.join(current.path, '.git')).existsSync();
    if (hasMakefile && hasGit) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }
    current = parent;
  }
  return null;
}

/// Directory names that never contain a package worth generating into.
const _skippedDirs = {
  '.dart_tool',
  '.fvm',
  '.git',
  'android',
  'build',
  'ios',
  'linux',
  'macos',
  'node_modules',
  'windows',
};

/// Every package under [root], nearest-first by path depth then name.
///
/// `example/` packages and the generator's own package are skipped: they are
/// scaffolding for the template itself, not places a downstream developer
/// generates a feature into.
List<WorkspacePackage> scanPackages(Directory root) {
  final packages = <WorkspacePackage>[];

  void visit(Directory dir, int depth) {
    if (depth > 3) {
      return;
    }
    final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      final package = _readPackage(root, dir, pubspec);
      if (package != null) {
        packages.add(package);
      }
      // A package can still contain nested packages (`plugins/x/example`),
      // but those are skipped below, so there is nothing to recurse into.
      return;
    }
    for (final entity in dir.listSync().whereType<Directory>()) {
      final name = p.basename(entity.path);
      if (name.startsWith('.') || _skippedDirs.contains(name)) {
        continue;
      }
      visit(entity, depth + 1);
    }
  }

  visit(root, 0);

  packages.sort((a, b) {
    final byDepth = p
        .split(a.relativePath)
        .length
        .compareTo(p.split(b.relativePath).length);
    return byDepth != 0 ? byDepth : a.relativePath.compareTo(b.relativePath);
  });
  return packages;
}

WorkspacePackage? _readPackage(Directory root, Directory dir, File pubspec) {
  final relative = p.relative(dir.path, from: root.path);
  final segments = p.split(relative);
  if (segments.contains('example') || relative == 'tools/module_generator') {
    return null;
  }

  final content = pubspec.readAsStringSync();
  final name = _pubspecName(content);
  if (name == null) {
    return null;
  }
  return WorkspacePackage(
    name: name,
    path: dir.path,
    relativePath: relative,
    dependencies: pubspecDependencies(content),
  );
}

String? _pubspecName(String content) {
  final match = RegExp(
    r'^name:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(content);
  return match?.group(1);
}

/// Keys of the `dependencies:` block in [pubspecContent].
///
/// Hand-parsed rather than run through `package:yaml` so the result is a plain
/// `Set<String>` of names: a dependency's value can be a version string, a
/// `path:`/`sdk:` map or null, and every one of those shapes is irrelevant
/// here — only whether the name is declared at all.
Set<String> pubspecDependencies(String pubspecContent) {
  final names = <String>{};
  var inBlock = false;
  for (final line in pubspecContent.split(RegExp(r'\r?\n'))) {
    if (line.trimRight().isEmpty || line.trimLeft().startsWith('#')) {
      continue;
    }
    // A non-indented line ends the block it follows.
    if (!line.startsWith(' ') && !line.startsWith('\t')) {
      inBlock = line.trimRight() == 'dependencies:';
      continue;
    }
    if (!inBlock) {
      continue;
    }
    // Only the block's own keys are dependencies; anything deeper is that
    // dependency's own configuration (`path:`, `sdk:`, `version:`).
    final match = RegExp(r'^  (\w[\w-]*):').firstMatch(line);
    if (match != null) {
      names.add(match.group(1)!);
    }
  }
  return names;
}

/// The package the generator is currently writing into.
///
/// Read from the working directory rather than from the workspace scan: the
/// generator is always launched inside a package, and `Directory.current` is
/// what every emitted path is relative to.
WorkspacePackage? currentPackage([Directory? from]) {
  final dir = from ?? Directory.current;
  final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return null;
  }
  final content = pubspec.readAsStringSync();
  final name = _pubspecName(content);
  if (name == null) {
    return null;
  }
  final root = findWorkspaceRoot(dir);
  return WorkspacePackage(
    name: name,
    path: dir.path,
    relativePath: root == null
        ? p.basename(dir.path)
        : p.relative(dir.path, from: root.path),
    dependencies: pubspecDependencies(content),
  );
}

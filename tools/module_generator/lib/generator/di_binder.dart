import 'dart:io';

import 'package:path/path.dart' as p;

/// A provider method to add to an injectable `@module`.
class DiBinding {
  const DiBinding({
    required this.type,
    required this.source,
    required this.importPath,
    this.extraImports = const [],
  });

  /// Class the binding provides, used to detect an existing registration.
  final String type;

  /// The provider method, already indented two spaces.
  final String source;

  /// Package-relative path of the file declaring [type].
  final String importPath;

  /// Package URIs the provider body needs (`package:dio/dio.dart`, …).
  final List<String> extraImports;
}

/// Outcome of trying to register a binding.
class DiBindingResult {
  const DiBindingResult({required this.modulePath, required this.message});

  /// Package-relative path of the module file, or `null` when none was found.
  final String? modulePath;

  /// What happened, phrased for the run summary.
  final String message;

  bool get bound => modulePath != null;
}

/// Registers [binding] in the nearest injectable `@module` under `lib/`.
///
/// Retrofit generates its implementation as a private class (`_XRepository`),
/// so `@Injectable` cannot be put on the client the way it can on a normal
/// class — every retrofit client in this repo is bound through a `@module`
/// provider instead. Emitting the client without that provider would leave the
/// operator with a file nothing can inject, so the generator adds the provider
/// itself.
///
/// Returns without writing when the type is already registered, so re-running
/// the generator over an existing repository is a no-op rather than a
/// duplicate binding.
Future<DiBindingResult> registerDiBinding(DiBinding binding) async {
  final modulePath = await findInjectableModule();
  if (modulePath == null) {
    return const DiBindingResult(
      modulePath: null,
      message: 'no @module class found — add the binding by hand',
    );
  }

  final file = File(modulePath);
  final content = await file.readAsString();
  if (RegExp('\\b${binding.type}\\b').hasMatch(content)) {
    return DiBindingResult(
      modulePath: modulePath,
      message: '$modulePath already registers ${binding.type}',
    );
  }

  final withImports = _ensureImports(content, binding, modulePath);
  final updated = _insertProvider(withImports, binding.source);
  if (updated == null) {
    return DiBindingResult(
      modulePath: null,
      message: 'could not parse the @module class in $modulePath',
    );
  }

  await file.writeAsString(updated);
  return DiBindingResult(
    modulePath: modulePath,
    message: 'registered ${binding.type} in $modulePath',
  );
}

/// The package-relative path of the file holding an injectable `@module`.
///
/// Prefers a file under a `di/` directory: a package can have several modules
/// (`service_module.dart`, `datasource_module.dart`), and the DI directory is
/// where the composition root lives in this template.
Future<String?> findInjectableModule({String root = 'lib'}) async {
  final dir = Directory(root);
  if (!dir.existsSync()) {
    return null;
  }

  final candidates = <String>[];
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    // `.module.dart` and `.config.dart` are build_runner output; writing into
    // them would be undone by the next generation run.
    if (entity.path.endsWith('.module.dart') ||
        entity.path.endsWith('.config.dart') ||
        entity.path.endsWith('.g.dart')) {
      continue;
    }
    final content = await entity.readAsString();
    if (_moduleClassPattern.hasMatch(content)) {
      candidates.add(p.normalize(entity.path));
    }
  }
  if (candidates.isEmpty) {
    return null;
  }

  candidates.sort((a, b) {
    final byDi = _diRank(a).compareTo(_diRank(b));
    return byDi != 0 ? byDi : a.compareTo(b);
  });
  return candidates.first;
}

int _diRank(String path) => p.split(path).contains('di') ? 0 : 1;

final _moduleClassPattern = RegExp(
  r'@module\s+abstract\s+class\s+(\w+)\s*\{',
  multiLine: true,
);

/// Inserts [provider] just before the closing brace of the `@module` class.
///
/// Brace-matched from the class body's opening brace rather than anchored to
/// the last `}` in the file: a module file can declare more than one class,
/// and appending to the wrong one silently produces a binding injectable never
/// reads.
String? _insertProvider(String content, String provider) {
  final match = _moduleClassPattern.firstMatch(content);
  if (match == null) {
    return null;
  }

  var depth = 0;
  for (var i = match.end - 1; i < content.length; i++) {
    final char = content[i];
    if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
      if (depth == 0) {
        final body = content.substring(match.end, i);
        final separator = body.trim().isEmpty ? '' : '\n';
        return '${content.substring(0, i)}$separator$provider'
            '${content.substring(i)}';
      }
    }
  }
  return null;
}

/// Adds any import [binding] needs that [content] does not already have.
///
/// Imports are re-sorted inside their own group afterwards because
/// `directives_ordering` is an analyzer info here, and an info fails
/// `make check` just as hard as an error.
String _ensureImports(String content, DiBinding binding, String modulePath) {
  final relative = p.posix.relative(
    p.posix.normalize(binding.importPath),
    from: p.posix.normalize(p.dirname(modulePath)),
  );

  final wanted = [...binding.extraImports, relative];
  final missing = wanted
      .where((uri) => !content.contains("'$uri'"))
      .map((uri) => "import '$uri';")
      .toList();
  if (missing.isEmpty) {
    return content;
  }

  final lines = content.split('\n');
  final imports = <String>[
    ...lines.where((line) => line.startsWith('import ')),
    ...missing,
  ];
  // `directives_ordering` sorts `dart:` first, then `package:`, then relative
  // paths, and alphabetically inside each group.
  imports.sort(
    (a, b) => _importRank(a).compareTo(_importRank(b)) != 0
        ? _importRank(a).compareTo(_importRank(b))
        : a.compareTo(b),
  );

  final block = _groupImports(imports);
  final firstImport = lines.indexWhere((line) => line.startsWith('import '));
  if (firstImport < 0) {
    return '${block.join('\n')}\n\n$content';
  }

  final rebuilt = <String>[];
  var written = false;
  for (final line in lines) {
    if (line.startsWith('import ')) {
      if (!written) {
        rebuilt.addAll(block);
        written = true;
      }
      continue;
    }
    rebuilt.add(line);
  }
  return rebuilt.join('\n');
}

/// Puts a blank line between the `dart:`, `package:` and relative groups.
///
/// Cosmetic — `directives_ordering` only cares about the order — but the file
/// being edited is hand-written, and a generator that reflows someone's
/// imports into one undifferentiated block reads as damage.
List<String> _groupImports(List<String> imports) {
  final grouped = <String>[];
  int? previous;
  for (final directive in imports) {
    final rank = _importRank(directive);
    if (previous != null && rank != previous) {
      grouped.add('');
    }
    grouped.add(directive);
    previous = rank;
  }
  return grouped;
}

int _importRank(String directive) {
  if (directive.contains("'dart:")) {
    return 0;
  }
  if (directive.contains("'package:")) {
    return 1;
  }
  return 2;
}

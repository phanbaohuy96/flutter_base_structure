import 'dart:io';

import 'common_function.dart';
import 'input_helper.dart';

/// What the generator was asked to produce.
enum GeneratorType {
  common,
  listing,
  detail,
  usecase,
  repository,
  model;

  static GeneratorType? parse(String? value) {
    if (value == null) {
      return null;
    }
    for (final type in GeneratorType.values) {
      if (type.name == value) {
        return type;
      }
    }
    return null;
  }
}

/// How a generated repository reaches the network.
///
/// Both transports emit a retrofit client — that is what a repository is in
/// this template. The choice decides how much of the work fits in annotations:
/// REST expresses an endpoint per method, while GraphQL routes every operation
/// through one endpoint and therefore needs documents and an error check
/// beside the client.
enum RepositoryTransport {
  /// A `@RestApi()` client whose annotated methods are the endpoints.
  rest,

  /// A one-method `@RestApi()` client plus the documents it posts, wrapped by
  /// a repository that composes operations and reads the `errors` array.
  graphql;

  static RepositoryTransport? parse(String? value) {
    if (value == null) {
      return null;
    }
    for (final transport in RepositoryTransport.values) {
      if (transport.name == value) {
        return transport;
      }
    }
    return null;
  }

  /// Human-readable name used by the interactive picker and the run summary.
  String get label => switch (this) {
    RepositoryTransport.rest => 'REST API (retrofit)',
    RepositoryTransport.graphql => 'GraphQL',
  };

  /// One-line description shown next to [label] in the picker.
  String get description => switch (this) {
    RepositoryTransport.rest => 'Annotated client, one endpoint per method',
    RepositoryTransport.graphql =>
      'Retrofit transport + documents, `errors`-aware',
  };
}

/// Which model template a repository run scaffolds for its payload type.
///
/// Folded into one choice rather than a yes/no followed by a style menu: the
/// answer to "do you want a model" is almost always yes, so the useful
/// question is which kind — with [ModelKind.none] as the opt-out that leaves
/// the client typed against `Map<String, dynamic>`.
enum ModelKind {
  freezed,
  jsonSerializable,
  none;

  static ModelKind? parse(String? value) {
    if (value == null) {
      return null;
    }
    for (final kind in ModelKind.values) {
      if (kind.flagName == value) {
        return kind;
      }
    }
    return null;
  }

  /// Value accepted on the command line (`--model json_serializable`).
  String get flagName => switch (this) {
    ModelKind.freezed => 'freezed',
    ModelKind.jsonSerializable => 'json_serializable',
    ModelKind.none => 'none',
  };

  /// Human-readable name used by the interactive picker.
  String get label => switch (this) {
    ModelKind.freezed => 'Freezed',
    ModelKind.jsonSerializable => 'Json Serializable',
    ModelKind.none => 'none',
  };

  /// One-line description shown next to [label] in the picker.
  String get description => switch (this) {
    ModelKind.freezed => 'Immutable class with copyWith and fromJson/toJson',
    ModelKind.jsonSerializable => 'Plain class with `@JsonKey` fields',
    ModelKind.none => 'Type the endpoint against `Map<String, dynamic>`',
  };

  bool get writesFile => this != ModelKind.none;
}

/// Flags collected from the command line.
///
/// Every field is optional: with no flags the generator falls back to the
/// interactive menu it has always had. Flags exist so the generator can be
/// driven by `verify_module_generator.sh` and by scripts, which is what makes
/// end-to-end verification possible at all.
class GeneratorOptions {
  const GeneratorOptions({
    this.type,
    this.package,
    this.name,
    this.dir,
    this.entity,
    this.transport,
    this.modelKind,
    this.modelName,
    this.modelDir,
    this.scaffoldEntity = true,
    this.force = false,
    this.nonInteractive = false,
  });

  final GeneratorType? type;

  /// Workspace-relative path (or package name) to generate into.
  ///
  /// Resolved before any prompt runs, because the target package decides both
  /// where files land and what may be generated at all — a repository is a
  /// retrofit client, and not every package can host one.
  final String? package;
  final String? name;
  final String? dir;
  final String? entity;

  /// Transport for `--type repository`; ignored by every other type.
  final RepositoryTransport? transport;

  /// Model template scaffolded alongside a generated repository.
  ///
  /// Null means "ask", which is why it is not defaulted here: a
  /// non-interactive run wants [ModelKind.freezed], but an interactive one
  /// wants the picker, and a default would rob it of the difference.
  final ModelKind? modelKind;

  /// Model class name; derived from the repository name when omitted.
  final String? modelName;

  /// Model output directory; derived from the package layout when omitted.
  final String? modelDir;
  final bool scaffoldEntity;
  final bool force;
  final bool nonInteractive;
}

/// A fully resolved request to scaffold one presentation module.
class ModuleRequest {
  const ModuleRequest({
    required this.name,
    required this.dir,
    required this.entity,
    required this.scaffoldEntity,
    required this.force,
  });

  final String name;
  final String dir;
  final String entity;
  final bool scaffoldEntity;
  final bool force;
}

/// Thrown when a required value is missing and prompting is not allowed.
class GeneratorInputException implements Exception {
  GeneratorInputException(this.message);

  final String message;

  @override
  String toString() => message;
}

const _dartReservedWords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

/// Returns an error message when [rawName] cannot become a Dart library and
/// class name, or `null` when it is usable.
String? validateModuleName(String rawName) {
  final normalized = formatModuleName(rawName);
  if (normalized.isEmpty) {
    return 'Module name must not be empty.';
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(normalized)) {
    return 'Module name "$rawName" normalises to "$normalized", which is not a '
        'valid Dart identifier. Use letters, digits and underscores, starting '
        'with a letter (eg. product_list).';
  }
  for (final segment in normalized.split('_')) {
    if (_dartReservedWords.contains(segment)) {
      return 'Module name "$rawName" contains the reserved word "$segment".';
    }
  }
  return null;
}

/// Fills the gaps in [options] from stdin, or fails loudly when prompting is
/// disabled.
Future<ModuleRequest> resolveModuleRequest(
  GeneratorOptions options, {
  String defaultDir = 'lib/presentation/modules',
}) async {
  final name = await _require(
    options.name,
    options,
    prompt: () => InputHelper.enterName(),
    missing: '--name is required in non-interactive mode.',
  );

  final nameError = validateModuleName(name);
  if (nameError != null) {
    throw GeneratorInputException(nameError);
  }

  final dir = normalizeDir(
    options.dir ??
        (options.nonInteractive
            ? defaultDir
            : await InputHelper.enterDir(defaultDir: defaultDir)),
  );

  // The entity is the type the module's state is written against. Default it
  // from the module name so the interactive flow stays one Enter away.
  final derivedEntity = formatClassName(
    formatModuleName(name).split('_').first,
  );
  final entity = options.scaffoldEntity
      ? await _require(
          options.entity,
          options,
          prompt: () => InputHelper.enterOptional(
            'Entity type (eg. Product) [default: $derivedEntity]: ',
            fallback: derivedEntity,
          ),
          missing: '',
          fallback: derivedEntity,
        )
      : formatClassName(options.entity ?? derivedEntity);

  final entityError = validateModuleName(entity);
  if (entityError != null) {
    throw GeneratorInputException(entityError.replaceAll('Module', 'Entity'));
  }

  return ModuleRequest(
    name: name,
    dir: dir,
    entity: formatClassName(entity),
    scaffoldEntity: options.scaffoldEntity,
    force: options.force,
  );
}

Future<String> _require(
  String? value,
  GeneratorOptions options, {
  required Future<String> Function() prompt,
  required String missing,
  String? fallback,
}) async {
  if (value != null && value.isNotEmpty) {
    return value;
  }
  if (options.nonInteractive) {
    if (fallback != null) {
      return fallback;
    }
    throw GeneratorInputException(missing);
  }
  return prompt();
}

/// Refuses to overwrite files the run would replace, unless the caller opted
/// in with `--force`.
///
/// Checks the files themselves rather than the directory that holds them. An
/// existing directory is not by itself a conflict: adding a `product_detail`
/// module beside a hand-written `product_detail/README.md`, or re-running the
/// generator after deleting one file, writes nothing that is already there.
/// Refusing on the directory turned those into a dead end whose only way
/// forward — `--force` — is the one option that *does* destroy work.
Future<void> assertTargetWritable(
  List<String> paths, {
  required bool force,
}) async {
  if (force) {
    return;
  }
  final conflicts = <String>[];
  for (final path in paths) {
    if (File(path).existsSync()) {
      conflicts.add(path);
    }
  }
  if (conflicts.isEmpty) {
    return;
  }
  throw GeneratorInputException(
    'Refusing to overwrite ${conflicts.length} existing file(s):\n'
    '${conflicts.map((path) => '  - $path').join('\n')}\n'
    '  Re-run with --force to replace them, or pick a different name.',
  );
}

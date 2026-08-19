import 'common_function.dart';
import 'file_helper.dart';
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

/// Flags collected from the command line.
///
/// Every field is optional: with no flags the generator falls back to the
/// interactive menu it has always had. Flags exist so the generator can be
/// driven by `verify_module_generator.sh` and by scripts, which is what makes
/// end-to-end verification possible at all.
class GeneratorOptions {
  const GeneratorOptions({
    this.type,
    this.name,
    this.dir,
    this.entity,
    this.scaffoldEntity = true,
    this.force = false,
    this.nonInteractive = false,
  });

  final GeneratorType? type;
  final String? name;
  final String? dir;
  final String? entity;
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

/// Refuses to overwrite an existing module unless the caller opted in.
///
/// Module files are written with `overrideFile: true`, so without this guard a
/// mistyped name silently replaced a real feature's bloc, screen and route.
Future<void> assertModuleTargetWritable(
  ModuleRequest request, {
  required String moduleDirName,
}) async {
  if (request.force) {
    return;
  }
  final target = '${request.dir}/$moduleDirName';
  if (!await FilesHelper.existsDir(target)) {
    return;
  }
  throw GeneratorInputException(
    '$target already exists. Re-run with --force to overwrite it, or pick a '
    'different module name.',
  );
}

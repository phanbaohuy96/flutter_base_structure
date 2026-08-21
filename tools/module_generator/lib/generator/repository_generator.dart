import 'dart:io';

import 'package:path/path.dart' as p;

import '../common/common_function.dart';
import '../common/console.dart';
import '../common/definitions.dart';
import '../common/file_helper.dart';
import '../common/formatter.dart';
import '../common/generator_options.dart';
import '../common/input_helper.dart';
import '../common/package_scanner.dart';
import '../res/templates/repository/source.dart';
import 'di_binder.dart';
import 'model_generator.dart';

/// Packages a retrofit client needs to compile in.
///
/// `dio` and `retrofit` are the client itself; `core` carries `ApiResponse`,
/// the envelope every endpoint in this template returns. All three are checked
/// against the pubspec's `dependencies:` block only — `apps/main` lists
/// `retrofit_generator` as a dev dependency but not `retrofit`, so a client
/// generated there would build and then fail `make check` on
/// `depend_on_referenced_packages`.
const repositoryRequiredPackages = ['core', 'dio', 'retrofit'];

/// The model a generated repository is typed against.
///
/// Null everywhere it appears means `--model none`: the client falls back to
/// `Map<String, dynamic>` and writes no model file.
class RepositoryModel {
  const RepositoryModel({
    required this.className,
    required this.path,
    required this.kind,
  });

  /// Class the endpoint's payload deserialises into (`NewsModel`).
  final String className;

  /// Package-relative path of the file declaring [className].
  final String path;

  /// Template the file is written from.
  final ModelKind kind;
}

/// Default output directory, matched to the package the generator is run in.
///
/// `modules/data_source` keeps its sources under `lib/src/`, while an app
/// package uses `lib/data/`. The old fixed default
/// (`lib/data/data_source/remote/repository`) matched neither, so generated
/// repositories landed outside the tree `generate_export` walks and were never
/// exported.
Future<String> defaultRepositoryDir() async {
  if (await FilesHelper.existsDir('lib/src/data/data_source')) {
    return 'lib/src/data/data_source/repository';
  }
  return 'lib/data/data_source/remote/repository';
}

/// Templates emitted for [transport].
Map<String, String> repositoryTemplatesFor(RepositoryTransport transport) =>
    switch (transport) {
      RepositoryTransport.rest => restRepositoryRes,
      RepositoryTransport.graphql => graphqlRepositoryRes,
    };

/// Dependencies [package] is missing before it can host a retrofit client.
List<String> missingRepositoryDependencies(WorkspacePackage? package) {
  if (package == null) {
    return const [];
  }
  return repositoryRequiredPackages
      .where((dependency) => !package.dependsOn(dependency))
      .toList();
}

/// The payload type the client's methods are written against.
String repositoryModelType(RepositoryModel? model) =>
    model?.className ?? 'Map<String, dynamic>';

/// Model-dependent token values for a repository emitted into [targetDir].
///
/// Both tokens have to vanish cleanly when there is no model: an `import '';`
/// would not parse, and `Map<String, dynamic>.fromJson` does not exist. Doing
/// it with values rather than a second copy of each template keeps the two
/// paths from drifting.
Map<String, String> repositoryModelTokens({
  required String targetDir,
  RepositoryModel? model,
}) {
  if (model == null) {
    return const {modelImportBlockKey: '', modelDecodeKey: 'node'};
  }
  final relative = p.posix.relative(
    normalizeDir(model.path),
    from: normalizeDir(targetDir),
  );
  return {
    modelImportBlockKey: "import '$relative';",
    modelDecodeKey: '${model.className}.fromJson(node)',
  };
}

Future<void> generateRepository({
  GeneratorOptions options = const GeneratorOptions(),
}) async {
  final package = currentPackage();
  final missing = missingRepositoryDependencies(package);
  if (missing.isNotEmpty) {
    throw GeneratorInputException(
      'A repository is a retrofit client, and ${package!.name} does not '
      'depend on ${missing.join(', ')}.\n'
      '  Generate it into a data-layer package instead (eg. '
      'modules/data_source), or add the missing dependencies to '
      '${package.relativePath}/pubspec.yaml.',
    );
  }

  final defaultDir = await defaultRepositoryDir();
  final inputRepoName =
      options.name ??
      await InputHelper.enterName(message: 'Repository name (eg. login)*: ');

  final nameError = validateModuleName(inputRepoName);
  if (nameError != null) {
    throw GeneratorInputException(nameError.replaceAll('Module', 'Repository'));
  }

  final inputRepoDir = normalizeDir(
    options.dir ??
        (options.nonInteractive
            ? defaultDir
            : await InputHelper.enterDir(
                defaultDir: defaultDir,
                message: 'Repository directory',
              )),
  );

  // Default to REST when nobody chose: it is what every repository generated
  // before the transport picker existed, so scripted callers keep their
  // output.
  final transport =
      options.transport ??
      (options.nonInteractive
          ? RepositoryTransport.rest
          : await _selectTransport());

  final model = await resolveRepositoryModel(options, inputRepoName);

  await assertTargetWritable(
    repositoryFilePaths(
      transport: transport,
      inputRepoName: inputRepoName,
      inputRepoDir: inputRepoDir,
    ),
    force: options.force,
  );

  stdout.writeln();
  stdout.writeln(
    Console.step(
      'Generating ${formatClassName(inputRepoName)} repository '
      '(${transport.label})',
    ),
  );

  // The model goes first so the client it is imported into is never the only
  // thing on disk: a run interrupted between the two would otherwise leave a
  // repository importing a file that does not exist.
  final modelPath = model == null
      ? null
      : await generateModelFile(
          className: model.className,
          dir: p.dirname(model.path),
          kind: model.kind,
        );

  final emitted = await generateRepositoryWithTemplateSource(
    transport: transport,
    inputRepoName: inputRepoName,
    inputRepoDir: inputRepoDir,
    model: model,
    overrideFile: true,
  );

  final binding = await registerDiBinding(
    repositoryDiBinding(
      transport: transport,
      inputRepoName: inputRepoName,
      inputRepoDir: inputRepoDir,
    ),
  );
  await formatGeneratedFiles([
    ...emitted,
    ?modelPath,
    if (binding.modulePath != null) binding.modulePath!,
  ]);

  printNextSteps([...emitted, ?modelPath]);
  stdout.writeln(
    binding.bound
        ? '  ${Console.dim('~')} ${binding.message}'
        : '  ${Console.yellow('!')} ${binding.message}',
  );
  if (!binding.bound) {
    stdout.writeln(
      Console.dim(
        '    ${repositoryDiBinding(
          transport: transport,
          inputRepoName: inputRepoName,
          inputRepoDir: inputRepoDir,
        ).source.trim()}',
      ),
    );
  }
  stdout.writeln();
}

/// Decides which model the run scaffolds, prompting when it may.
///
/// A repository with nothing to return is not much of a repository — every
/// real client here answers with `ApiResponse<SomeModel>` — so the model is
/// part of the same run rather than a second trip through the generator, and
/// the default is to write one.
Future<RepositoryModel?> resolveRepositoryModel(
  GeneratorOptions options,
  String inputRepoName,
) async {
  final kind =
      options.modelKind ??
      (options.nonInteractive ? ModelKind.freezed : await _selectModelKind());
  if (!kind.writesFile) {
    return null;
  }

  final fallbackName = defaultModelClassName(inputRepoName);
  final rawName =
      options.modelName ??
      (options.nonInteractive
          ? fallbackName
          : await InputHelper.enterOptional(
              'Model class name (default: $fallbackName): ',
              fallback: fallbackName,
            ));

  final className = formatClassName(rawName);
  final nameError = validateModuleName(className);
  if (nameError != null) {
    throw GeneratorInputException(nameError.replaceAll('Module', 'Model'));
  }

  final dir = normalizeDir(options.modelDir ?? await defaultModelDir());
  return RepositoryModel(
    className: className,
    path: '$dir/${modelFileNameFor(className)}',
    kind: kind,
  );
}

/// Every path [transport] writes for a repository, in emission order.
///
/// Shared with the overwrite guard so the two cannot drift: a guard that
/// checks a different set of files than the writer touches either blocks a
/// safe run or waves through a clobbering one. The model is deliberately not
/// in this list — it is written with `overrideFile: false`, so pointing a
/// second repository at an existing model skips it rather than clobbering it.
List<String> repositoryFilePaths({
  required RepositoryTransport transport,
  required String inputRepoName,
  required String inputRepoDir,
}) {
  final moduleName = formatModuleName(inputRepoName);
  final targetDir = '${normalizeDir(inputRepoDir)}/$moduleName';
  return [
    for (final key in repositoryTemplatesFor(transport).keys)
      '$targetDir/$moduleName${repositoryFileSuffixes[key]}',
  ];
}

/// The `@module` provider that binds the emitted client.
///
/// Retrofit writes its implementation as a private class, so `@Injectable` on
/// the client is impossible — a provider method is the only way to register
/// one. For GraphQL the client is bound instead of the repository, because the
/// repository is an ordinary class that injectable can construct once its
/// dependency is in the graph.
DiBinding repositoryDiBinding({
  required RepositoryTransport transport,
  required String inputRepoName,
  required String inputRepoDir,
}) {
  final className = formatClassName(inputRepoName);
  final moduleName = formatModuleName(inputRepoName);
  final camelName = camelCase(inputRepoName);
  final importPath =
      '${normalizeDir(inputRepoDir)}/$moduleName/${moduleName}_repository.dart';

  return switch (transport) {
    RepositoryTransport.rest => DiBinding(
      type: '${className}Repository',
      importPath: importPath,
      extraImports: const ['package:dio/dio.dart'],
      source:
          '\n  @injectable\n'
          '  ${className}Repository ${camelName}Repository(Dio dio) =>\n'
          '      ${className}Repository(dio);\n',
    ),
    RepositoryTransport.graphql => DiBinding(
      type: '${className}GraphqlApi',
      importPath: importPath,
      extraImports: const ['package:core/core.dart', 'package:dio/dio.dart'],
      source:
          '\n  @injectable\n'
          '  ${className}GraphqlApi ${camelName}GraphqlApi(Dio dio) =>\n'
          '      ${className}GraphqlApi(\n'
          '        dio,\n'
          '        baseUrl: Config.instance.appConfig.baseGraphQLUrl,\n'
          '      );\n',
    ),
  };
}

/// Writes the repository files for [transport] and returns their paths.
///
/// Split out of [generateRepository] so tests can emit into a sandbox without
/// prompting, formatting, or printing next steps — the same split the module
/// generators use.
Future<List<String>> generateRepositoryWithTemplateSource({
  required RepositoryTransport transport,
  required String inputRepoName,
  required String inputRepoDir,
  RepositoryModel? model,
  bool overrideFile = true,
}) async {
  final className = formatClassName(inputRepoName);
  final moduleName = formatModuleName(inputRepoName);
  final targetDir = '${normalizeDir(inputRepoDir)}/$moduleName';

  await FilesHelper.createFolder(targetDir);

  final emitted = <String>[];
  for (final entry in repositoryTemplatesFor(transport).entries) {
    final suffix = repositoryFileSuffixes[entry.key]!;
    final pathFile = '$targetDir/$moduleName$suffix';
    await FilesHelper.writeFile(
      pathFile: pathFile,
      content: entry.value.replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: repositoryModelType(model),
        fileDir: targetDir,
        extra: repositoryModelTokens(targetDir: targetDir, model: model),
      ),
      overrideFile: overrideFile,
    );
    emitted.add(pathFile);
  }
  return emitted;
}

/// Asks which transport the repository speaks.
Future<RepositoryTransport> _selectTransport() async {
  stdout.writeln();
  stdout.writeln(
    Console.menu(
      title: 'Repository transport',
      subtitle: 'Both emit a retrofit client; GraphQL adds the documents',
      sections: [
        MenuSection(
          title: 'transport',
          entries: [
            for (final (index, transport) in RepositoryTransport.values.indexed)
              MenuEntry(
                value: index + 1,
                label: transport.label,
                description: transport.description,
              ),
          ],
        ),
      ],
    ),
  );

  final selection = await InputHelper.enterChoice(
    'Select transport [1-${RepositoryTransport.values.length}]: ',
    allowed: {
      for (var i = 1; i <= RepositoryTransport.values.length; i++) i,
    },
  );
  return RepositoryTransport.values[selection - 1];
}

/// Asks which model to scaffold for the client's payload.
///
/// One prompt, not two: "do you want a model" is answered yes almost every
/// time, so the question that carries information is which template — with
/// `0` as the opt-out.
Future<ModelKind> _selectModelKind() async {
  final writable = ModelKind.values.where((kind) => kind.writesFile).toList();

  stdout.writeln();
  stdout.writeln(
    Console.menu(
      title: 'Payload model',
      subtitle: 'The type the endpoint deserialises into',
      sections: [
        MenuSection(
          title: 'model',
          entries: [
            for (final (index, kind) in writable.indexed)
              MenuEntry(
                value: index + 1,
                label: kind.label,
                description: kind.description,
              ),
          ],
        ),
        MenuSection(
          title: 'other',
          entries: [
            MenuEntry(
              value: 0,
              label: ModelKind.none.label,
              description: ModelKind.none.description,
            ),
          ],
        ),
      ],
    ),
  );

  final selection = await InputHelper.enterChoice(
    'Select model [0-${writable.length}] ${Console.dim('(default: 1)')}: ',
    allowed: {for (var i = 0; i <= writable.length; i++) i},
    defaultValue: 1,
  );
  return selection == 0 ? ModelKind.none : writable[selection - 1];
}

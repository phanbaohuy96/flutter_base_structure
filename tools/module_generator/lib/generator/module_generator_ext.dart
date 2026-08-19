import '../common/common_function.dart';
import '../common/file_helper.dart';

/// Writes one presentation module and returns every path it emitted.
///
/// [modelName] is the domain entity the module is built around (e.g. `Product`)
/// and is independent of [inputModuleName] — a `product_detail` module still
/// works over a `Product`. [modelPath] is the package-relative path to that
/// entity, so bloc and state files import it by a path that resolves from
/// their own depth.
Future<List<String>> generateModuleWithTemplateSource({
  required Map<String, dynamic> source,
  required String inputModuleName,
  required String inputModuleDir,
  required String modelName,
  required String modelPath,
  bool overrideFile = true,
}) async {
  if (inputModuleName.isEmpty) {
    return const [];
  }

  final className = formatClassName(inputModuleName);
  final moduleName = formatModuleName(inputModuleName);
  final moduleDir = '${normalizeDir(inputModuleDir)}/$moduleName';
  final blocDir = '$moduleDir/bloc';
  final viewsDir = '$moduleDir/views';

  final emitted = <String>[];

  Future<void> write({
    required String dir,
    required String fileName,
    required String template,
    String Function(String content)? postProcess,
  }) async {
    final pathFile = '$dir/$fileName';
    final content = template.replaceContent(
      className: className,
      moduleName: moduleName,
      modelName: modelName,
      modelPath: modelPath,
      fileDir: dir,
    );
    await FilesHelper.writeFile(
      pathFile: pathFile,
      content: postProcess?.call(content) ?? content,
      overrideFile: overrideFile,
    );
    emitted.add(pathFile);
  }

  // #BLOC
  await FilesHelper.createFolder('$blocDir/');
  await write(
    dir: blocDir,
    fileName: '${moduleName}_bloc.dart',
    template: source['bloc']['bloc'] as String,
  );
  await write(
    dir: blocDir,
    fileName: '${moduleName}_state.dart',
    template: source['bloc']['state'] as String,
  );
  await write(
    dir: blocDir,
    fileName: '${moduleName}_event.dart',
    template: source['bloc']['event'] as String,
  );

  // #VIEWS
  await FilesHelper.createFolder('$viewsDir/');
  await write(
    dir: viewsDir,
    fileName: '${moduleName}_screen.dart',
    template: source['views']['screen'] as String,
  );
  await write(
    dir: viewsDir,
    fileName: '$moduleName.action.dart',
    template: source['views']['action'] as String,
  );

  // #COORDINATOR (compound or arg-translating modules only — single-screen
  // generators omit the 'coordinator' key so no shallow `pushBehavior.push`
  // wrapper file is emitted; callers navigate via the route name directly.)
  if (source.containsKey('coordinator')) {
    await write(
      dir: moduleDir,
      fileName: '${moduleName}_coordinator.dart',
      template: source['coordinator'] as String,
    );
  }

  // #ROUTE
  await write(
    dir: moduleDir,
    fileName: '${moduleName}_route.dart',
    template: source['route'] as String,
  );

  // #EXPORT
  await write(
    dir: moduleDir,
    fileName: '$moduleName.dart',
    template: source['module'] as String,
    postProcess: sortDirectives,
  );

  return emitted;
}

/// Sorts the `export` lines of an emitted barrel alphabetically.
///
/// `directives_ordering` sorts by the quoted URI, so whether `<module>_route`
/// belongs before or after `bloc/` and `views/` depends on the module's first
/// letter. A fixed order in the template is right for some names and an
/// analyzer info for others, so the order is decided here, after
/// substitution, when the real names are known.
String sortDirectives(String content) {
  final lines = content.split('\n');
  final directives = lines.where((line) => line.startsWith('export ')).toList()
    ..sort();
  final rest = lines.where((line) => !line.startsWith('export '));
  return [...directives, ...rest].join('\n');
}

/// Writes the usecase pair for a module and returns every path it emitted.
///
/// Uses `overrideFile: false` throughout: a usecase is where hand-written
/// business logic accumulates, so re-running the generator must never clobber
/// it.
Future<List<String>> generateUsecaseWithTemplateSource({
  required Map<String, dynamic> source,
  required String inputModuleName,
  required String inputModuleDir,
  required String modelName,
  required String modelPath,
}) async {
  if (inputModuleName.isEmpty) {
    return const [];
  }

  final className = formatClassName(inputModuleName);
  final moduleName = formatModuleName(inputModuleName);
  final directory = '${normalizeDir(inputModuleDir)}/$moduleName';

  await FilesHelper.createFolder(directory);

  final emitted = <String>[];
  Future<void> write(String fileName, String template) async {
    final pathFile = '$directory/$fileName';
    await FilesHelper.writeFile(
      pathFile: pathFile,
      content: template.replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
        modelPath: modelPath,
        fileDir: directory,
      ),
      overrideFile: false,
    );
    emitted.add(pathFile);
  }

  await write('${moduleName}_usecase.dart', source['usecase'] as String);
  await write(
    '${moduleName}_usecase.impl.dart',
    source['usecase.impl'] as String,
  );

  return emitted;
}

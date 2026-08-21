import '../common/common_function.dart';
import '../common/file_helper.dart';

/// One file a module template emits.
class _ModuleFile {
  const _ModuleFile({
    required this.dir,
    required this.fileName,
    required this.template,
    this.postProcess,
  });

  final String dir;
  final String fileName;
  final String template;
  final String Function(String content)? postProcess;

  String get path => '$dir/$fileName';
}

/// The files [source] emits for a module, in emission order.
///
/// Derived once and read by both the writer and the overwrite guard, so the
/// guard can never check a different set of paths than the run touches.
List<_ModuleFile> _moduleFiles({
  required Map<String, dynamic> source,
  required String inputModuleName,
  required String inputModuleDir,
}) {
  final moduleName = formatModuleName(inputModuleName);
  final moduleDir = '${normalizeDir(inputModuleDir)}/$moduleName';
  final blocDir = '$moduleDir/bloc';
  final viewsDir = '$moduleDir/views';

  return [
    _ModuleFile(
      dir: blocDir,
      fileName: '${moduleName}_bloc.dart',
      template: source['bloc']['bloc'] as String,
    ),
    _ModuleFile(
      dir: blocDir,
      fileName: '${moduleName}_state.dart',
      template: source['bloc']['state'] as String,
    ),
    _ModuleFile(
      dir: blocDir,
      fileName: '${moduleName}_event.dart',
      template: source['bloc']['event'] as String,
    ),
    _ModuleFile(
      dir: viewsDir,
      fileName: '${moduleName}_screen.dart',
      template: source['views']['screen'] as String,
    ),
    _ModuleFile(
      dir: viewsDir,
      fileName: '$moduleName.action.dart',
      template: source['views']['action'] as String,
    ),
    // Compound or arg-translating modules only — single-screen generators omit
    // the 'coordinator' key so no shallow `pushBehavior.push` wrapper file is
    // emitted; callers navigate via the route name directly.
    if (source.containsKey('coordinator'))
      _ModuleFile(
        dir: moduleDir,
        fileName: '${moduleName}_coordinator.dart',
        template: source['coordinator'] as String,
      ),
    _ModuleFile(
      dir: moduleDir,
      fileName: '${moduleName}_route.dart',
      template: source['route'] as String,
    ),
    _ModuleFile(
      dir: moduleDir,
      fileName: '$moduleName.dart',
      template: source['module'] as String,
      postProcess: sortDirectives,
    ),
  ];
}

/// Package-relative paths a module run would write.
List<String> moduleFilePaths({
  required Map<String, dynamic> source,
  required String inputModuleName,
  required String inputModuleDir,
}) {
  if (inputModuleName.isEmpty) {
    return const [];
  }
  return _moduleFiles(
    source: source,
    inputModuleName: inputModuleName,
    inputModuleDir: inputModuleDir,
  ).map((file) => file.path).toList();
}

/// Package-relative paths a usecase run would write.
List<String> usecaseFilePaths({
  required String inputModuleName,
  required String inputModuleDir,
}) {
  if (inputModuleName.isEmpty) {
    return const [];
  }
  final moduleName = formatModuleName(inputModuleName);
  final directory = '${normalizeDir(inputModuleDir)}/$moduleName';
  return [
    '$directory/${moduleName}_usecase.dart',
    '$directory/${moduleName}_usecase.impl.dart',
  ];
}

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
  final files = _moduleFiles(
    source: source,
    inputModuleName: inputModuleName,
    inputModuleDir: inputModuleDir,
  );

  final emitted = <String>[];
  for (final file in files) {
    await FilesHelper.createFolder('${file.dir}/');
    final content = file.template.replaceContent(
      className: className,
      moduleName: moduleName,
      modelName: modelName,
      modelPath: modelPath,
      fileDir: file.dir,
    );
    await FilesHelper.writeFile(
      pathFile: file.path,
      content: file.postProcess?.call(content) ?? content,
      overrideFile: overrideFile,
    );
    emitted.add(file.path);
  }

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
/// Defaults to `overrideFile: false`: a usecase is where hand-written business
/// logic accumulates, so a module run that happens to reuse an existing
/// usecase name leaves it alone. Only `--type usecase --force`, which asked
/// for exactly that file, passes `true`.
Future<List<String>> generateUsecaseWithTemplateSource({
  required Map<String, dynamic> source,
  required String inputModuleName,
  required String inputModuleDir,
  required String modelName,
  required String modelPath,
  bool overrideFile = false,
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
      overrideFile: overrideFile,
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

import '../common/common_function.dart';
import '../common/file_helper.dart';
import '../common/formatter.dart';
import '../common/generator_options.dart';
import '../common/input_helper.dart';
import '../res/templates/repository/source.dart';

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

Future<void> generateRepository({
  GeneratorOptions options = const GeneratorOptions(),
}) async {
  final defaultDir = await defaultRepositoryDir();
  final inputRepoName =
      options.name ??
      await InputHelper.enterName(message: 'Repository name (eg. login)*: ');

  final nameError = validateModuleName(inputRepoName);
  if (nameError != null) {
    throw GeneratorInputException(nameError.replaceAll('Module', 'Repository'));
  }

  var inputRepoDir = normalizeDir(
    options.dir ??
        (options.nonInteractive
            ? defaultDir
            : await InputHelper.enterDir(
                defaultDir: defaultDir,
                message: 'Repository directory',
              )),
  );

  final className = formatClassName(inputRepoName);
  final moduleName = formatModuleName(inputRepoName);
  inputRepoDir += '/$moduleName';

  await FilesHelper.createFolder(inputRepoDir);

  final emitted = <String>[];
  final fragmentFileName = '${moduleName}_fragment.dart';
  final repositoryFileName = '${moduleName}_repository.dart';
  final repositoryImplFileName = '${moduleName}_repository.impl.dart';

  for (final entry in <String, String>{
    fragmentFileName: repositoryRes['fragment']!,
    repositoryFileName: repositoryRes['repository']!,
    repositoryImplFileName: repositoryRes['repository.impl']!,
  }.entries) {
    final pathFile = '$inputRepoDir/${entry.key}';
    await FilesHelper.writeFile(
      pathFile: pathFile,
      content: entry.value.replaceContent(
        className: className,
        moduleName: moduleName,
        fileDir: inputRepoDir,
      ),
      overrideFile: options.force,
    );
    emitted.add(pathFile);
  }

  await formatGeneratedFiles(emitted);
  printNextSteps(emitted);
}

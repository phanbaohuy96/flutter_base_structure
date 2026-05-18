import '../common/common_function.dart';
import '../common/file_helper.dart';
import '../common/input_helper.dart';
import '../res/templates/repository/source.dart';

Future<void> generateRepository() async {
  final inputRepoName = await InputHelper.enterName(
    message: 'Repository name (eg. login)*: ',
  );
  var inputRepoDir = await InputHelper.enterDir(
    defaultDir: 'lib/data/data_source/remote/repository',
    message: 'Repository directory',
  );

  final className = formatClassName(inputRepoName);
  final moduleName = formatModuleName(inputRepoName);
  inputRepoDir += '/$moduleName';

  await FilesHelper.createFolder(inputRepoDir);

  final fragmentFileName = '${moduleName}_fragment.dart';
  final repositoryFileName = '${moduleName}_repository.dart';
  final repositoryImplFileName = '${moduleName}_repository.impl.dart';

  await FilesHelper.writeFile(
    pathFile: '$inputRepoDir/$fragmentFileName',
    content: repositoryRes['fragment']!.replaceContent(
      className: className,
      moduleName: moduleName,
    ),
  );

  await FilesHelper.writeFile(
    pathFile: '$inputRepoDir/$repositoryFileName',
    content: repositoryRes['repository']!.replaceContent(
      className: className,
      moduleName: moduleName,
    ),
  );

  await FilesHelper.writeFile(
    pathFile: '$inputRepoDir/$repositoryImplFileName',
    content: repositoryRes['repository.impl']!.replaceContent(
      className: className,
      moduleName: moduleName,
    ),
  );
}

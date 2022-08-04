import '../common/common_function.dart';
import '../common/file_helper.dart';

Future<void> generateModuleWithTemplateSource({
  required Map<String, dynamic> source,
  required String inputModuleName,
  required String inputModuleDir,
}) async {
  if (inputModuleName.isNotEmpty) {
    final className = formatClassName(inputModuleName);
    final moduleName = formatModuleName(inputModuleName);
    inputModuleDir += '/$moduleName';

    // #BLOC
    await FilesHelper.createFolder('$inputModuleDir/bloc/');
    final blocFileName = '${moduleName}_bloc.dart';
    final eventFileName = '${moduleName}_event.dart';
    final stateFileName = '${moduleName}_state.dart';

    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/bloc/$blocFileName',
      content: (source['bloc']['bloc'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/bloc/$stateFileName',
      content: (source['bloc']['state'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/bloc/$eventFileName',
      content: (source['bloc']['event'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );

    // #INTERACTOR
    await FilesHelper.createFolder('$inputModuleDir/interactor/');
    final interactorFileName = '${moduleName}_interactor.dart';
    final interactorImplFileName = '${moduleName}_interactor.impl.dart';
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/interactor/$interactorFileName',
      content: (source['interactor']['interactor'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/interactor/$interactorImplFileName',
      content:
          (source['interactor']['interactor.impl'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );

    // #REPOSITORY
    final repositoryFileName = '${moduleName}_repository.dart';
    final repositoryImplFileName = '${moduleName}_repository.impl.dart';
    await FilesHelper.createFolder('$inputModuleDir/repository/');
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/repository/$repositoryFileName',
      content: (source['repository']['repository'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/repository/$repositoryImplFileName',
      content:
          (source['repository']['repository.impl'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );

    // #VIEWS
    final screenFileName = '${moduleName}_screen.dart';
    final actionImplFileName = '$moduleName.action.dart';
    await FilesHelper.createFolder('$inputModuleDir/views/');
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/views/$screenFileName',
      content: (source['views']['screen'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/views/$actionImplFileName',
      content: (source['views']['action'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );

    // #ROUTE
    final routeFileName = '${moduleName}_route.dart';
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/$routeFileName',
      content: (source['route'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );

    // #EXPORT
    final exportFileName = '$moduleName.dart';
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/$exportFileName',
      content: (source['module'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
      ),
    );
  }
}

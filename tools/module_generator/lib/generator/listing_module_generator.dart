import '../common/common_function.dart';
import '../common/file_helper.dart';
import '../common/input_helper.dart';

Future<void> generateListingModule() async {
  var inputModuleName = '';
  while (inputModuleName.isEmpty) {
    inputModuleName = await InputHelper.enterText(
      'Module name (eg. test_module)*: ',
    ).then((value) => value ?? '');
  }
  var inputModuleDir = await InputHelper.enterText(
    'Module directory (default: lib/presentation/modules): ',
  ).then(
    (value) {
      return value?.replaceAll("'", '') ?? '';
    },
  );

  if (inputModuleDir.isEmpty) {
    inputModuleDir = 'lib/presentation/modules';
  }
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
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate: 'listing_module/bloc/bloc.txt',
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/bloc/$stateFileName',
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate: 'listing_module/bloc/state.txt',
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/bloc/$eventFileName',
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate: 'listing_module/bloc/event.txt',
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
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate:
            'listing_module/interactor/interactor.txt',
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/interactor/$interactorImplFileName',
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate:
            'listing_module/interactor/interactor.impl.txt',
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
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate:
            'listing_module/repository/repository.txt',
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/repository/$repositoryImplFileName',
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate:
            'listing_module/repository/repository.impl.txt',
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
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate: 'listing_module/views/screen.txt',
        className: className,
        moduleName: moduleName,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/views/$actionImplFileName',
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate: 'listing_module/views/action.txt',
        className: className,
        moduleName: moduleName,
      ),
    );

    // #ROUTE
    final routeFileName = '${moduleName}_route.dart';
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/$routeFileName',
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate: 'listing_module/route.txt',
        className: className,
        moduleName: moduleName,
      ),
    );

    // #EXPORT
    final exportFileName = '$moduleName.dart';
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/$exportFileName',
      content: await openTemplateAndReplaceContent(
        relativeFilePathFromTemplate: 'listing_module/module.txt',
        className: className,
        moduleName: moduleName,
      ),
    );
  }
}

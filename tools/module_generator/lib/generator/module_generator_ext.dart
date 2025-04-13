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
    final partCount = '/'.allMatches(inputModuleDir).length;
    // #BLOC
    await FilesHelper.createFolder('$inputModuleDir/bloc/');
    final blocFileName = '${moduleName}_bloc.dart';
    final eventFileName = '${moduleName}_event.dart';
    final stateFileName = '${moduleName}_state.dart';
    final modelName = moduleName.split('_').first.capitalize();
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/bloc/$blocFileName',
      content: (source['bloc']['bloc'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
        partCount: partCount,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/bloc/$stateFileName',
      content: (source['bloc']['state'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
        partCount: partCount,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/bloc/$eventFileName',
      content: (source['bloc']['event'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
        partCount: partCount,
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
        modelName: modelName,
        partCount: partCount,
      ),
    );
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/views/$actionImplFileName',
      content: (source['views']['action'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
        partCount: partCount,
      ),
    );

    // #ROUTE
    final coordinatorFileName = '${moduleName}_coordinator.dart';
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/$coordinatorFileName',
      content: (source['coordinator'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
        partCount: partCount,
      ),
    );

    // #ROUTE
    final routeFileName = '${moduleName}_route.dart';
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/$routeFileName',
      content: (source['route'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
        partCount: partCount,
      ),
    );

    // #EXPORT
    final exportFileName = '$moduleName.dart';
    await FilesHelper.writeFile(
      pathFile: '$inputModuleDir/$exportFileName',
      content: (source['module'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
        partCount: partCount,
      ),
    );
  }
}

Future<void> generateUsecaseWithTemplateSource({
  required Map<String, dynamic> source,
  required String inputModuleName,
  required String inputModuleDir,
}) async {
  if (inputModuleName.isNotEmpty) {
    final className = formatClassName(inputModuleName);
    final moduleName = formatModuleName(inputModuleName);
    final modelName = moduleName.split('_').first.capitalize();
    // #USECASE
    final directory = '$inputModuleDir/$moduleName';
    await FilesHelper.createFolder(directory);
    final usecaseFileName = '${moduleName}_usecase.dart';
    final usecaseImplFileName = '${moduleName}_usecase.impl.dart';
    await FilesHelper.writeFile(
      pathFile: '$directory/$usecaseFileName',
      content: (source['usecase'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
      ),
      overrideFile: false,
    );
    await FilesHelper.writeFile(
      pathFile: '$directory/$usecaseImplFileName',
      content: (source['usecase.impl'] as String).replaceContent(
        className: className,
        moduleName: moduleName,
        modelName: modelName,
      ),
      overrideFile: false,
    );
  }
}

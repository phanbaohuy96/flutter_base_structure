import '../common/common_function.dart';
import '../common/formatter.dart';
import '../common/generator_options.dart';
import '../res/templates/detail_module/source.dart';
import '../res/templates/usecase/source.dart';
import 'entity_generator.dart';
import 'module_generator_ext.dart';

Future<void> generateDetailModule({
  GeneratorOptions options = const GeneratorOptions(),
  bool usecaseIncluded = true,
}) async {
  final request = await resolveModuleRequest(options);

  // The module carries a `_detail` suffix so `product` and `product_detail`
  // can coexist. The usecase MUST carry the same suffix: the bloc imports
  // `usecases/<module>/<module>_usecase.dart` and calls
  // `<Module>Usecase.get<Module>ById`, so a bare-named usecase left the
  // generated module referencing a file and a class that were never written.
  final moduleName = detailModuleNameFor(request.name);
  await assertTargetWritable(
    moduleFilePaths(
      source: detailModuleRes,
      inputModuleName: moduleName,
      inputModuleDir: request.dir,
    ),
    force: request.force,
  );

  final modelPath = entityPathFor(request.entity);
  final emitted = <String>[
    if (request.scaffoldEntity)
      ...await generateEntity(
        modelName: request.entity,
      ),
    ...await generateModuleWithTemplateSource(
      source: detailModuleRes,
      inputModuleName: moduleName,
      inputModuleDir: request.dir,
      modelName: request.entity,
      modelPath: modelPath,
    ),
    if (usecaseIncluded)
      ...await generateUsecaseWithTemplateSource(
        source: usecaseRes['detail']!,
        inputModuleName: moduleName,
        inputModuleDir: 'lib/domain/usecases',
        modelName: request.entity,
        modelPath: modelPath,
      ),
  ];

  await formatGeneratedFiles(emitted);
  printNextSteps(emitted);
}

/// Appends the `_detail` suffix unless the caller already typed it.
String detailModuleNameFor(String inputModuleName) {
  final normalized = formatModuleName(inputModuleName);
  return normalized.endsWith('_detail') ? normalized : '${normalized}_detail';
}

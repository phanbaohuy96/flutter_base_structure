import '../common/common_function.dart';
import '../common/formatter.dart';
import '../common/generator_options.dart';
import '../res/templates/common_module/source.dart';
import '../res/templates/usecase/source.dart';
import 'entity_generator.dart';
import 'module_generator_ext.dart';

Future<void> generateCommonModule({
  GeneratorOptions options = const GeneratorOptions(),
  bool usecaseIncluded = true,
}) async {
  final request = await resolveModuleRequest(options);
  await assertModuleTargetWritable(
    request,
    moduleDirName: formatModuleName(request.name),
  );

  final modelPath = entityPathFor(request.entity);
  final emitted = <String>[
    if (request.scaffoldEntity)
      ...await generateEntity(
        modelName: request.entity,
      ),
    ...await generateModuleWithTemplateSource(
      source: commonModuleRes,
      inputModuleName: request.name,
      inputModuleDir: request.dir,
      modelName: request.entity,
      modelPath: modelPath,
    ),
    if (usecaseIncluded)
      ...await generateUsecaseWithTemplateSource(
        source: usecaseRes['common']!,
        inputModuleName: request.name,
        inputModuleDir: 'lib/domain/usecases',
        modelName: request.entity,
        modelPath: modelPath,
      ),
  ];

  await formatGeneratedFiles(emitted);
  printNextSteps(emitted);
}

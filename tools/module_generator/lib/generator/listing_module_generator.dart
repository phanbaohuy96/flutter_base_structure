import '../common/common_function.dart';
import '../common/formatter.dart';
import '../common/generator_options.dart';
import '../res/templates/listing_module/source.dart';
import '../res/templates/usecase/source.dart';
import 'entity_generator.dart';
import 'module_generator_ext.dart';

Future<void> generateListingModule({
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
    // A listing needs the filter type too: the usecase signature defaults to
    // `const <Model>Filter()`, so the module does not compile without it.
    if (request.scaffoldEntity)
      ...await generateEntity(
        modelName: request.entity,
        includeFilter: true,
      ),
    ...await generateModuleWithTemplateSource(
      source: listingModuleRes,
      inputModuleName: request.name,
      inputModuleDir: request.dir,
      modelName: request.entity,
      modelPath: modelPath,
    ),
    if (usecaseIncluded)
      ...await generateUsecaseWithTemplateSource(
        source: usecaseRes['listing']!,
        inputModuleName: request.name,
        inputModuleDir: 'lib/domain/usecases',
        modelName: request.entity,
        modelPath: modelPath,
      ),
  ];

  await formatGeneratedFiles(emitted);
  printNextSteps(emitted);
}

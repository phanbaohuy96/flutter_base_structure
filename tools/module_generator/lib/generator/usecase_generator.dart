import '../common/formatter.dart';
import '../common/generator_options.dart';
import '../common/input_helper.dart';
import '../res/templates/usecase/source.dart';
import 'entity_generator.dart';
import 'module_generator_ext.dart';

const _usecaseKinds = {1: 'common', 2: 'detail', 3: 'listing'};

Future<bool> generateUsecase({
  GeneratorOptions options = const GeneratorOptions(),
}) async {
  final selection = await _inputUsecaseType();
  if (selection == 0) {
    return false;
  }

  final request = await resolveModuleRequest(
    options,
    defaultDir: 'lib/domain/usecases',
  );

  final modelPath = entityPathFor(request.entity);
  final emitted = <String>[
    if (request.scaffoldEntity)
      ...await generateEntity(
        modelName: request.entity,
        includeFilter: _usecaseKinds[selection] == 'listing',
      ),
    ...await generateUsecaseWithTemplateSource(
      source: usecaseRes[_usecaseKinds[selection]]!,
      inputModuleName: request.name,
      inputModuleDir: request.dir,
      modelName: request.entity,
      modelPath: modelPath,
    ),
  ];

  await formatGeneratedFiles(emitted);
  printNextSteps(emitted);
  return true;
}

Future<int> _inputUsecaseType() async {
  return InputHelper.enterChoice(
    '''Usecase type
1. Common
2. Detailing
3. Listing
0. Back

Please Select: ''',
    allowed: {0, 1, 2, 3},
  );
}

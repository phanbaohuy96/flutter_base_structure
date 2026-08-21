import 'dart:io';

import '../common/console.dart';
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

  await assertTargetWritable(
    usecaseFilePaths(
      inputModuleName: request.name,
      inputModuleDir: request.dir,
    ),
    force: request.force,
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
      overrideFile: request.force,
    ),
  ];

  await formatGeneratedFiles(emitted);
  printNextSteps(emitted);
  return true;
}

Future<int> _inputUsecaseType() async {
  stdout.writeln();
  stdout.writeln(
    Console.menu(
      title: 'Usecase shape',
      subtitle: 'Picks the methods and the repository calls to scaffold',
      sections: const [
        MenuSection(
          title: 'shape',
          entries: [
            MenuEntry(
              value: 1,
              label: 'common',
              description: 'One load() over a single entity',
            ),
            MenuEntry(
              value: 2,
              label: 'detail',
              description: 'Reads one entity by id',
            ),
            MenuEntry(
              value: 3,
              label: 'listing',
              description: 'Paged fetch, load-more and a filter type',
            ),
          ],
        ),
        MenuSection(
          title: 'other',
          entries: [
            MenuEntry(
              value: 0,
              label: 'back',
              description: 'Return to the menu',
            ),
          ],
        ),
      ],
    ),
  );
  return InputHelper.enterChoice(
    'Select [0-3]: ',
    allowed: {0, 1, 2, 3},
  );
}

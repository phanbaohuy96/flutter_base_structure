import 'dart:async';
import 'dart:io';

import 'common/definitions.dart';
import 'common/generator_options.dart';
import 'common/input_helper.dart';
import 'generator/base_module_generator.dart';
import 'generator/detail_module_generator.dart';
import 'generator/listing_module_generator.dart';
import 'generator/model_generator.dart';
import 'generator/repository_generator.dart';
import 'generator/usecase_generator.dart';

/// Runs the generator either straight from [options] or, when no `--type` was
/// given, through the interactive menu.
Future<void> runModuleGenerator(GeneratorOptions options) async {
  final type = options.type;
  if (type != null) {
    await _run(type, options);
    return;
  }
  if (options.nonInteractive) {
    throw GeneratorInputException(
      '--type is required in non-interactive mode.',
    );
  }
  await showModuleGeneratorMenu(options: options);
}

Future<void> _run(GeneratorType type, GeneratorOptions options) async {
  switch (type) {
    case GeneratorType.common:
      await generateCommonModule(options: options);
    case GeneratorType.listing:
      await generateListingModule(options: options);
    case GeneratorType.detail:
      await generateDetailModule(options: options);
    case GeneratorType.repository:
      await generateRepository(options: options);
    case GeneratorType.usecase:
      await generateUsecase(options: options);
    case GeneratorType.model:
      // The model generator is menu-driven (freezed vs json_serializable) and
      // has no flag for that choice yet, so it would block on stdin instead of
      // failing.
      if (options.nonInteractive) {
        throw GeneratorInputException(
          '--type model is not supported in non-interactive mode.',
        );
      }
      await generateModel();
  }
}

Future<void> showModuleGeneratorMenu({
  GeneratorOptions options = const GeneratorOptions(),
}) async {
  final menu = {
    MenuItem.commonModuleGenerator.index: 'Generate common module',
    MenuItem.listingModuleGenerator.index: 'Generate listing module',
    MenuItem.detailModuleGenerator.index: 'Generate detail module',
    MenuItem.repositoryGenerator.index: 'Generate repository',
    MenuItem.usecase.index: 'Generate Usecase',
    MenuItem.model.index: 'Generate model template',
    MenuItem.exit.index: 'Exit',
  };

  while (true) {
    for (final e in menu.entries) {
      print('${e.key}. ${e.value}');
    }
    final selection = await InputHelper.enterChoice(
      'Please Select: ',
      allowed: menu.keys.toSet(),
    );

    if (selection == MenuItem.exit.index) {
      return;
    }

    try {
      switch (MenuItem.values[selection]) {
        case MenuItem.commonModuleGenerator:
          await generateCommonModule(options: options);
          return;
        case MenuItem.listingModuleGenerator:
          await generateListingModule(options: options);
          return;
        case MenuItem.detailModuleGenerator:
          await generateDetailModule(options: options);
          return;
        case MenuItem.repositoryGenerator:
          await generateRepository(options: options);
          return;
        case MenuItem.usecase:
          if (await generateUsecase(options: options)) {
            return;
          }
        case MenuItem.model:
          if (await generateModel()) {
            return;
          }
        case MenuItem.exit:
          return;
      }
    } on GeneratorInputException catch (error) {
      // Keep the menu alive on a bad name or an existing target: the operator
      // is already at a prompt, so re-asking beats exiting the process.
      stderr.writeln('Error: ${error.message}\n');
    }
  }
}

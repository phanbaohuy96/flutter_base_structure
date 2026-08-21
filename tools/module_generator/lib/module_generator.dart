import 'dart:async';
import 'dart:io';

import 'common/console.dart';
import 'common/definitions.dart';
import 'common/generator_options.dart';
import 'common/input_helper.dart';
import 'generator/base_module_generator.dart';
import 'generator/detail_module_generator.dart';
import 'generator/listing_module_generator.dart';
import 'generator/model_generator.dart';
import 'generator/package_picker.dart';
import 'generator/repository_generator.dart';
import 'generator/usecase_generator.dart';

/// Runs the generator either straight from [options] or, when no `--type` was
/// given, through the interactive menu.
///
/// The target package is resolved first: everything after it — the default
/// output directory, whether a repository can be generated at all — is read
/// off the package the files will land in.
Future<void> runModuleGenerator(GeneratorOptions options) async {
  final package = await selectTargetPackage(options);
  if (package == null) {
    return;
  }

  // Scripted runs stay quiet: the caller chose the package, so echoing it back
  // is noise in a build log.
  if (!options.nonInteractive) {
    stdout.writeln();
    stdout.writeln(
      Console.step('Generating into ${Console.cyan(package.relativePath)}'),
    );
  }

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

/// Grouped menu shown when the generator runs without flags.
///
/// Sectioned by layer rather than listed flat: the first question an operator
/// actually has is "presentation or data?", and the descriptions answer
/// "which one?" without a trip to the README.
final _menuSections = <MenuSection>[
  const MenuSection(
    title: 'presentation',
    entries: [
      MenuEntry(
        value: 1,
        label: 'common module',
        description: 'Bloc + screen + route, no list or detail bias',
      ),
      MenuEntry(
        value: 2,
        label: 'listing module',
        description: 'Items, filtering, refresh and load-more',
      ),
      MenuEntry(
        value: 3,
        label: 'detail module',
        description: 'One entity, opened by object or by id',
      ),
    ],
  ),
  const MenuSection(
    title: 'data & domain',
    entries: [
      MenuEntry(
        value: 4,
        label: 'repository',
        description: 'Retrofit client over REST or GraphQL',
      ),
      MenuEntry(
        value: 5,
        label: 'usecase',
        description: 'Domain seam over one or more repositories',
      ),
      MenuEntry(
        value: 6,
        label: 'model',
        description: 'Freezed or json_serializable DTO',
      ),
    ],
  ),
  const MenuSection(
    title: 'other',
    entries: [
      MenuEntry(value: 0, label: 'exit', description: 'Leave without writing'),
    ],
  ),
];

Future<void> showModuleGeneratorMenu({
  GeneratorOptions options = const GeneratorOptions(),
}) async {
  // The menu is keyed by MenuItem.index so the numbers stay in step with the
  // enum the switch below reads.
  assert(
    _menuSections
        .expand((section) => section.entries)
        .every((entry) => entry.value < MenuItem.values.length),
    'a menu entry has no matching MenuItem',
  );

  while (true) {
    stdout.writeln();
    stdout.writeln(
      Console.menu(
        title: 'Flutter module generator',
        subtitle: 'Scaffolds code that compiles and passes `make check`',
        sections: _menuSections,
      ),
    );

    final selection = await InputHelper.enterChoice(
      'Select [0-${MenuItem.values.length - 1}]: ',
      allowed: _menuSections
          .expand((section) => section.entries)
          .map((entry) => entry.value)
          .toSet(),
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
      stderr.writeln('\n${Console.failure(error.message)}');
    }
  }
}

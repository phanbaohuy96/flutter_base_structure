import 'dart:async';
import 'dart:io';

import 'common/definitions.dart';
import 'common/input_helper.dart';
import 'common/utils.dart';
import 'generator/base_module_generator.dart';
import 'generator/listing_module_generator.dart';
import 'generator/repository_generator.dart';

Future<void> showModuleGeneratorMenu() async {
  final menu = {
    MenuItem.commonModuleGenerator.index: 'Generate common module',
    MenuItem.listingModuleGenerator.index: 'Generate listing module',
    MenuItem.repositoryGenerator.index: 'Generate repository',
    MenuItem.exit.index: 'Exit'
  };

  while (true) {
    for (final e in menu.entries) {
      printLog('${e.key}. ${e.value}');
    }
    var selection = int.tryParse(
      await InputHelper.enterText('Please Select: ') ?? '',
    );
    if (selection == MenuItem.commonModuleGenerator.index) {
      await generateCommonModule();
      exit(0);
    } else if (selection == MenuItem.listingModuleGenerator.index) {
      await generateListingModule();
      exit(0);
    } else if (selection == MenuItem.repositoryGenerator.index) {
      await generateRepository();
      exit(0);
    } else if (selection == MenuItem.exit.index) {
      exit(0);
    } else {
      printLog('Unknown Option Selected!');
    }
  }
}

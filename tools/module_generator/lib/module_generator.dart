import 'dart:async';
import 'dart:io';

import 'common/definations.dart';
import 'common/input_helper.dart';
import 'generator/base_module_generator.dart';
import 'generator/detail_module_generator.dart';
import 'generator/listing_module_generator.dart';
import 'generator/model_generator.dart';
import 'generator/repository_generator.dart';
import 'generator/usecase_generator.dart';

Future<void> showModuleGeneratorMenu() async {
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
    var selection = int.tryParse(
      await InputHelper.enterText('Please Select: ') ?? '',
    );
    if (selection == MenuItem.commonModuleGenerator.index) {
      await generateCommonModule();
      exit(0);
    } else if (selection == MenuItem.listingModuleGenerator.index) {
      await generateListingModule();
      exit(0);
    } else if (selection == MenuItem.detailModuleGenerator.index) {
      await generateDetailModule();
      exit(0);
    } else if (selection == MenuItem.repositoryGenerator.index) {
      await generateRepository();
      exit(0);
    } else if (selection == MenuItem.usecase.index) {
      final res = await generateUsecase();
      if (res) {
        exit(0);
      }
    } else if (selection == MenuItem.model.index) {
      final res = await generateModel();
      if (res) {
        exit(0);
      }
    } else if (selection == MenuItem.exit.index) {
      exit(0);
    } else {
      print('Unknown Option Selected!');
    }
  }
}

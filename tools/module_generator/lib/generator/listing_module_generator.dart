import '../common/input_helper.dart';
import '../res/templates/listing_module/source.dart';
import 'module_generator_ext.dart';

Future<void> generateListingModule() async {
  final inputModuleName = await InputHelper.enterModuleName();
  var inputModuleDir = await InputHelper.enterModuleDir();

  await generateModuleWithTemplateSource(
    source: listingModuleRes,
    inputModuleName: inputModuleName,
    inputModuleDir: inputModuleDir,
  );
}

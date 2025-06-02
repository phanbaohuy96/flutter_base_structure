import '../common/input_helper.dart';
import '../res/templates/listing_module/source.dart';
import '../res/templates/usecase/source.dart';
import 'module_generator_ext.dart';

Future<void> generateListingModule({bool usecaseIncluded = true}) async {
  final inputModuleName = await InputHelper.enterName();
  var inputModuleDir = await InputHelper.enterDir();

  await generateModuleWithTemplateSource(
    source: listingModuleRes,
    inputModuleName: inputModuleName,
    inputModuleDir: inputModuleDir,
  );

  if (usecaseIncluded) {
    await generateUsecaseWithTemplateSource(
      source: usecaseRes['listing']!,
      inputModuleName: inputModuleName,
      inputModuleDir: 'lib/domain/usecases',
    );
  }
}

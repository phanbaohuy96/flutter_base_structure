import '../common/input_helper.dart';
import '../res/templates/common_module/source.dart';
import '../res/templates/usecase/source.dart';
import 'module_generator_ext.dart';

Future<void> generateCommonModule({
  bool usecaseIncluded = true,
}) async {
  final inputModuleName = await InputHelper.enterName();
  var inputModuleDir = await InputHelper.enterDir();

  await generateModuleWithTemplateSource(
    source: commonModuleRes,
    inputModuleName: inputModuleName,
    inputModuleDir: inputModuleDir,
  );

  if (usecaseIncluded) {
    await generateUsecaseWithTemplateSource(
      source: usecaseRes['common']!,
      inputModuleName: inputModuleName,
      inputModuleDir: 'lib/domain/usecases',
    );
  }
}

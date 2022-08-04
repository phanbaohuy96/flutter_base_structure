import '../common/input_helper.dart';
import '../res/templates/common_module/source.dart';
import 'module_generator_ext.dart';

Future<void> generateCommonModule() async {
  final inputModuleName = await InputHelper.enterName();
  var inputModuleDir = await InputHelper.enterDir();

  await generateModuleWithTemplateSource(
    source: commonModuleRes,
    inputModuleName: inputModuleName,
    inputModuleDir: inputModuleDir,
  );
}

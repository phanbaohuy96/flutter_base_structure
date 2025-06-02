import '../common/input_helper.dart';
import '../res/templates/detail_module/source.dart';
import '../res/templates/usecase/source.dart';
import 'module_generator_ext.dart';

Future<void> generateDetailModule({bool usecaseIncluded = true}) async {
  final inputModuleName = await InputHelper.enterName();
  var inputModuleDir = await InputHelper.enterDir();

  await generateModuleWithTemplateSource(
    source: detailModuleRes,
    inputModuleName: '${inputModuleName}_detail',
    inputModuleDir: inputModuleDir,
  );
  if (usecaseIncluded) {
    await generateUsecaseWithTemplateSource(
      source: usecaseRes['detail']!,
      inputModuleName: inputModuleName,
      inputModuleDir: 'lib/domain/usecases',
    );
  }
}

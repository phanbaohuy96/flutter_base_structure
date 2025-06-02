import '../common/input_helper.dart';
import '../res/templates/usecase/source.dart';
import 'module_generator_ext.dart';

Future<bool> generateUsecase() async {
  final selection = await _inputUsecaseType();

  if (selection == 0) {
    return Future.value(false);
  }

  final inputModuleName = await InputHelper.enterName();
  var inputModuleDir = await InputHelper.enterDir(
    defaultDir: 'lib/domain/usecases',
    message: 'Usecase directory',
  );
  await generateUsecaseWithTemplateSource(
    source: usecaseRes[switch (selection) {
      1 => 'common',
      2 => 'detail',
      3 => 'listing',
      _ => throw UnsupportedError(
          'Usecase with $selection currently not supported',
        ),
    }]!,
    inputModuleName: inputModuleName,
    inputModuleDir: inputModuleDir,
  );

  return Future.value(true);
}

Future<int> _inputUsecaseType() async {
  var type = await InputHelper.enterName(
    message: '''Usecase type
1. Common
2. Detailing
3. Listing
0. Back

Please Select: ''',
  );

  final selection = int.parse(type);
  if ([0, 1, 2, 3].contains(selection)) {
    return selection;
  }
  print('Invalid options!');
  return _inputUsecaseType();
}

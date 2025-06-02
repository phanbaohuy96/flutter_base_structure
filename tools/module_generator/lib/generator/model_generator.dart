import '../common/common_function.dart';
import '../common/file_helper.dart';
import '../common/input_helper.dart';
import '../res/templates/model/freezed_model.dart';
import '../res/templates/model/json_serializable_model.dart';

Future<bool> generateModel() async {
  final selection = await _inputType();

  if (selection == 0) {
    return Future.value(false);
  }

  final name = await InputHelper.enterRequired(message: 'Name *: ');

  var defaultDir = 'lib/data/models';
  // Check if the project has a structure like data_source
  if (await FilesHelper.existsDir('lib/src/data/models')) {
    defaultDir = 'lib/src/data/models';
  }
  var dir = await InputHelper.enterDir(
    defaultDir: defaultDir,
    message: 'Enter directory',
  );
  final source = switch (selection) {
    1 => freezedModel,
    2 => jsonSerializableModel,
    _ =>
      throw UnsupportedError('Model with $selection currently not supported'),
  };

  final className = formatClassName(name);
  final moduleName = formatModuleName(name);
  final modelName = moduleName.split('_').first.capitalize();

  final fileName = '$moduleName.dart';
  await FilesHelper.createFolder(dir);
  await FilesHelper.writeFile(
    pathFile: '$dir/$fileName',
    content: source.replaceContent(
      className: className,
      moduleName: moduleName,
      modelName: modelName,
    ),
    overrideFile: false,
  );

  return Future.value(true);
}

Future<int> _inputType() async {
  var type = await InputHelper.enterName(
    message: '''Model type
1. Freezed
2. Json Serializable
0. Back

Please Select: ''',
  );

  final selection = int.parse(type);
  if ([0, 1, 2, 3].contains(selection)) {
    return selection;
  }
  print('Invalid options!');
  return _inputType();
}

import '../common/common_function.dart';
import '../common/file_helper.dart';
import '../common/generator_options.dart';
import '../common/input_helper.dart';
import '../res/templates/model/freezed_model.dart';
import '../res/templates/model/json_serializable_model.dart';

/// Package-relative directory holding data models.
///
/// `modules/data_source` keeps its sources under `lib/src/`, an app package
/// and `core` under `lib/`. Probing rather than hardcoding is what lets the
/// repository generator scaffold a model into whichever package it was
/// pointed at.
Future<String> defaultModelDir() async {
  if (await FilesHelper.existsDir('lib/src/data/models')) {
    return 'lib/src/data/models';
  }
  return 'lib/data/models';
}

/// Model class name derived from a repository name.
///
/// `news` becomes `NewsModel`, matching the one model this template ships
/// (`UserModel`). An operator override that already carries the suffix is left
/// alone rather than doubled into `NewsModelModel`.
String defaultModelClassName(String repoName) {
  final className = formatClassName(repoName);
  return className.endsWith('Model') ? className : '${className}Model';
}

/// File name (no directory) for a model class.
///
/// The suffix lives on the class, not the file: `UserModel` is declared in
/// `user.dart` here and `FarmCycle` in `farm_cycle.dart` in the projects built
/// from this template. Stripping it keeps a generated model's path matching
/// the repository it belongs to.
String modelFileNameFor(String className) {
  var base = className;
  if (base.endsWith('Model') && base.length > 'Model'.length) {
    base = base.substring(0, base.length - 'Model'.length);
  }
  return '${formatModuleName(base)}.dart';
}

/// Writes one model file and returns its package-relative path.
///
/// Written with `overrideFile: false`: pointing a second repository at a model
/// that already exists is a legitimate thing to do, and the run should leave
/// the hand-edited fields alone rather than reset them to the template's `id`.
Future<String> generateModelFile({
  required String className,
  required String dir,
  required ModelKind kind,
}) async {
  final source = switch (kind) {
    ModelKind.freezed => freezedModel,
    ModelKind.jsonSerializable => jsonSerializableModel,
    ModelKind.none => throw ArgumentError.value(
      kind,
      'kind',
      'ModelKind.none writes no file',
    ),
  };

  final fileName = modelFileNameFor(className);
  final targetDir = normalizeDir(dir);
  final pathFile = '$targetDir/$fileName';

  await FilesHelper.createFolder(targetDir);
  await FilesHelper.writeFile(
    pathFile: pathFile,
    content: source.replaceContent(
      className: className,
      // The part directives name the file, not the class.
      moduleName: fileName.replaceAll('.dart', ''),
    ),
    overrideFile: false,
  );
  return pathFile;
}

Future<bool> generateModel() async {
  final selection = await _inputType();

  if (selection == 0) {
    return Future.value(false);
  }

  final name = await InputHelper.enterRequired(message: 'Name *: ');
  final dir = await InputHelper.enterDir(
    defaultDir: await defaultModelDir(),
    message: 'Enter directory',
  );

  await generateModelFile(
    // The standalone flow takes the name as given — typing `UserModel` there
    // has always produced `UserModel`, and nothing about it implies a
    // repository whose name the suffix should be derived from.
    className: formatClassName(name),
    dir: dir,
    kind: switch (selection) {
      1 => ModelKind.freezed,
      2 => ModelKind.jsonSerializable,
      _ => throw UnsupportedError(
        'Model with $selection currently not supported',
      ),
    },
  );

  return Future.value(true);
}

Future<int> _inputType() async {
  return InputHelper.enterChoice(
    '''Model type
1. Freezed
2. Json Serializable
0. Back

Please Select: ''',
    allowed: {0, 1, 2},
  );
}

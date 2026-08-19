import '../common/common_function.dart';
import '../common/file_helper.dart';
import '../res/templates/entity/source.dart';

/// Package-relative directory holding domain entities.
const defaultEntitiesDir = 'lib/domain/entities';

/// Package-relative path to the entity file backing [modelName].
String entityPathFor(String modelName, {String dir = defaultEntitiesDir}) {
  final fileName = formatModuleName(modelName);
  return '${normalizeDir(dir)}/$fileName/$fileName.entity.dart';
}

/// Package-relative path to the listing filter for [modelName].
///
/// Deliberately beside the entity rather than in a shared `filter/` folder:
/// two imports under the same directory always sort the same way, which is
/// what keeps emitted files clean under `directives_ordering`.
String filterPathFor(String modelName, {String dir = defaultEntitiesDir}) {
  final fileName = formatModuleName(modelName);
  return '${normalizeDir(dir)}/$fileName/${fileName}_filter.entity.dart';
}

/// Scaffolds the domain entity (and optionally its listing filter) a generated
/// module is typed against.
///
/// Listing and detail modules declare `List<Model>` / `Model?` in their state,
/// so without this the emitted module referenced a type that did not exist and
/// never compiled. Written with `overrideFile: false` so pointing a second
/// module at an existing entity is a no-op rather than a silent overwrite.
Future<List<String>> generateEntity({
  required String modelName,
  String dir = defaultEntitiesDir,
  bool includeFilter = false,
}) async {
  if (modelName.isEmpty) {
    return const [];
  }

  final className = formatClassName(modelName);
  final moduleName = formatModuleName(modelName);
  final emitted = <String>[];

  final entityPath = entityPathFor(modelName, dir: dir);
  await FilesHelper.writeFile(
    pathFile: entityPath,
    content: entityRes['entity']!.replaceContent(
      className: className,
      moduleName: moduleName,
    ),
    overrideFile: false,
  );
  emitted.add(entityPath);

  if (includeFilter) {
    final filterPath = filterPathFor(modelName, dir: dir);
    await FilesHelper.writeFile(
      pathFile: filterPath,
      content: entityRes['filter']!.replaceContent(
        className: className,
        moduleName: '${moduleName}_filter',
      ),
      overrideFile: false,
    );
    emitted.add(filterPath);
  }

  return emitted;
}

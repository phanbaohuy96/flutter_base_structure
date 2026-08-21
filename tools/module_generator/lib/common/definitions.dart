const classNameKey = '%%CLASS_NAME%%';
const moduleNameKey = '%%MODULE_NAME%%';
const modelNameKey = '%%MODEL_NAME%%';

/// Lower-camel form of the class name (`Product` -> `product`).
///
/// Wire formats that are neither Dart identifiers nor file names need it —
/// GraphQL root fields, for instance, are camelCase by convention.
const camelNameKey = '%%CAMEL_NAME%%';
const contentKey = '%%CONTENT%%';
const nestedContentKey = '%%NESTED_CONTENT%%';
const artboardKey = '%%ARTBOARD_KEY%%';
const routeNameKey = '%%ROUTE_NAME_KEY%%';

/// Slot for the `part` directives of a generated asset library.
const partDirectivesKey = '%%PART_DIRECTIVES%%';

/// Relative path from the emitting file back to the package's `lib/`.
///
/// Replaces the old `%%IMPORT_PART%%` `'../' * n` counter, which assumed every
/// emitted file sat at the same depth. Route and coordinator files live one
/// level above `bloc/` and `views/`, so a single shared prefix could never be
/// right for all of them — see `resolveImportAnchors`.
const libImportKey = '%%IMPORT_LIB%%';

/// Relative path from the emitting file back to `lib/presentation/`.
const presentationImportKey = '%%IMPORT_PRESENTATION%%';

/// Relative import path from the emitting file to the module's domain entity.
const modelImportKey = '%%MODEL_IMPORT%%';

/// The model import line a repository template emits, or `''` when the run
/// was told not to scaffold one.
///
/// A whole line rather than just the path, because the line has to disappear
/// entirely when there is no model — an `import '';` left behind would not
/// even parse. The blank line that remains is collapsed by `dart format`.
const modelImportBlockKey = '%%MODEL_IMPORT_BLOCK%%';

/// Expression that turns a decoded JSON node into the model type.
///
/// GraphQL answers with untyped maps, so the repository has to decode the
/// node itself. With a model that is `<Model>.fromJson(node)`; without one
/// [modelNameKey] is `Map<String, dynamic>` and the node is already the answer.
const modelDecodeKey = '%%MODEL_DECODE%%';

/// Relative import path from the emitting file to the entity's listing filter.
///
/// The filter lives beside the entity (`<model>/<model>_filter.entity.dart`)
/// so the two imports always sort in the same order regardless of the entity
/// name, which `directives_ordering` requires.
const modelFilterImportKey = '%%MODEL_FILTER_IMPORT%%';

enum MenuItem {
  exit,
  commonModuleGenerator,
  listingModuleGenerator,
  detailModuleGenerator,
  repositoryGenerator,
  usecase,
  model,
}

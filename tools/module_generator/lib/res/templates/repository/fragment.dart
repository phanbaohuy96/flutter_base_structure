import '../../../common/definitions.dart';

/// GraphQL operations for one feature, emitted beside its repository.
///
/// Written with `"""` on the outside so the emitted documents can use `r'''`
/// without escaping: a raw string keeps GraphQL's `$variable` syntax literal,
/// which is exactly what a Dart string would otherwise interpolate away.
const graphqlFragment =
    """/// GraphQL documents for $classNameKey.
///
/// Operations live beside the repository that sends them, so a schema change
/// lands in one file. The field selection is declared once in [fields] and
/// appended to every document by [request] — a server resolves
/// `...${classNameKey}Fields` only when the fragment travels with the
/// operation that spreads it.
///
/// One operation, to match the one method on the repository. Add a `const
/// String` per operation you need and pass it to [request].
class ${classNameKey}Fragment {
  const ${classNameKey}Fragment._();

  /// Reusable field selection for the $classNameKey type.
  ///
  /// Named after the schema type rather than the feature, so any operation
  /// returning that type can spread it.
  // TODO(template): replace these with the fields your schema exposes.
  static const String fields = r'''
fragment ${classNameKey}Fields on $classNameKey {
  id
  name
}
''';

  /// Reads a single $classNameKey by id.
  // TODO(template): rename the root field to match your schema.
  static const String query = r'''
query Get$classNameKey(\$id: ID!) {
  $camelNameKey(id: \$id) {
    ...${classNameKey}Fields
  }
}
''';

  /// The request body for [operation]: the document with [fields] appended,
  /// plus the variables it declares.
  static Map<String, dynamic> request(
    String operation, {
    Map<String, dynamic> variables = const {},
  }) => <String, dynamic>{
    'query': '\$operation\\n\$fields',
    'variables': variables,
  };
}
""";

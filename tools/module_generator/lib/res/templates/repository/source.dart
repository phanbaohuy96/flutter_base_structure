import 'fragment.dart';
import 'repository.dart';

/// Files emitted for a REST-backed repository.
///
/// One file: the retrofit client is the repository. There is no `.impl.dart`
/// because there is no implementation to write — `retrofit_generator` produces
/// it into the `.g.dart` part — and no fragment, because the REST equivalent
/// of a field selection is the endpoint path, which lives on the annotation.
const restRepositoryRes = <String, String>{'repository': restRepository};

/// Files emitted for a GraphQL-backed repository.
///
/// The extra file is the documents: operations live beside the repository that
/// sends them, so a schema change lands in one place.
const graphqlRepositoryRes = <String, String>{
  'fragment': graphqlFragment,
  'repository': graphqlRepository,
};

/// File-name suffix for every template key the two maps above can hold.
const repositoryFileSuffixes = <String, String>{
  'fragment': '_fragment.dart',
  'repository': '_repository.dart',
};

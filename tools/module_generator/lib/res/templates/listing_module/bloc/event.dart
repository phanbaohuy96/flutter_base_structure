import '../../../../common/definitions.dart';

const listingModuleEvent = '''part of '${moduleNameKey}_bloc.dart';

@immutable
abstract class ${classNameKey}Event {}

class GetDataEvent extends ${classNameKey}Event {}

class LoadMoreDataEvent extends ${classNameKey}Event {}''';

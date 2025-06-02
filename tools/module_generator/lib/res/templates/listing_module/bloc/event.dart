import '../../../../common/definations.dart';

const listingModuleEvent = '''part of '${moduleNameKey}_bloc.dart';

abstract class ${classNameKey}Event {}

class Get${modelNameKey}sEvent extends ${classNameKey}Event {}

class LoadMore${modelNameKey}sEvent extends ${classNameKey}Event {}''';

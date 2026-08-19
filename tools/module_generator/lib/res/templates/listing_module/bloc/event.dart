import '../../../../common/definitions.dart';

const listingModuleEvent =
    '''part of '${moduleNameKey}_bloc.dart';

abstract class ${classNameKey}Event {}

class Get${modelNameKey}sEvent extends ${classNameKey}Event {
  Get${modelNameKey}sEvent({this.filter});

  /// The filter to switch to, or `null` to reuse the one already in state.
  final ${modelNameKey}Filter? filter;
}

class LoadMore${modelNameKey}sEvent extends ${classNameKey}Event {}
''';

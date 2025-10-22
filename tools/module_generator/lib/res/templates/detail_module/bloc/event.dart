import '../../../../common/definitions.dart';

const detailModuleEvent = '''part of '${moduleNameKey}_bloc.dart';

abstract class ${classNameKey}Event {}

class Get${classNameKey}Event extends ${classNameKey}Event {
  final String id;
  Get${classNameKey}Event(this.id);
}
''';

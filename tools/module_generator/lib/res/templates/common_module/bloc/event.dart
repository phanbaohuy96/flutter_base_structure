import '../../../../common/definitions.dart';

const commonModuleEvent =
    '''part of '${moduleNameKey}_bloc.dart';

abstract class ${classNameKey}Event {}

class Get${classNameKey}Event extends ${classNameKey}Event {}
''';

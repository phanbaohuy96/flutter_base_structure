import '../../../../common/definations.dart';

const commonModuleInteractor =
    '''import '../repository/${moduleNameKey}_repository.dart';

part '${moduleNameKey}_interactor.impl.dart';

abstract class ${classNameKey}Interactor {}''';

import '../../../../common/definitions.dart';

const commonModuleInteractorImpl =
    '''part of '${moduleNameKey}_interactor.dart';

class ${classNameKey}InteractorImpl extends ${classNameKey}Interactor {
  final ${classNameKey}Repository _repository;

  ${classNameKey}InteractorImpl(this._repository);
}''';

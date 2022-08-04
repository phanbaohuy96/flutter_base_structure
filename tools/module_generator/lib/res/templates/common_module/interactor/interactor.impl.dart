const commonModuleInteractorImpl = '''part of '%%MODULE_NAME%%_interactor.dart';

class %%CLASS_NAME%%InteractorImpl extends %%CLASS_NAME%%Interactor {
  final %%CLASS_NAME%%Repository _repository;

  %%CLASS_NAME%%InteractorImpl(this._repository);
}''';

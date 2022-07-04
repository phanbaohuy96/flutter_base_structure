
from common_function import *


def generateCommonModule():
    inputModuleName = input("Module name (eg. test_module): ") 
    inputModuleDir = input("Module directory: ").replace("'", "")
    className = formatClassName(inputModuleName)
    moduleName = formatModuleName(inputModuleName)

    #BLOC
    os.makedirs(inputModuleDir + '/bloc/')
    blocFileName = moduleName + '_bloc.dart'
    eventFileName = moduleName + '_event.dart'
    stateFileName = moduleName + '_state.dart'

    writeFile(inputModuleDir + '/bloc/' + blocFileName, openTemplateAndReplaceContent("common_module/bloc/bloc.txt", className, moduleName))
    writeFile(inputModuleDir + '/bloc/' + stateFileName, openTemplateAndReplaceContent("common_module/bloc/state.txt", className, moduleName))
    writeFile(inputModuleDir + '/bloc/' + eventFileName, openTemplateAndReplaceContent("common_module/bloc/event.txt", className, moduleName))


    #INTERACTOR
    os.makedirs(inputModuleDir + '/interactor/')
    interactorFileName = moduleName + '_interactor.dart'
    interactorImplFileName = moduleName + '_interactor.impl.dart'
    writeFile(inputModuleDir + '/interactor/' + interactorFileName, openTemplateAndReplaceContent("common_module/interactor/interactor.txt", className, moduleName))
    writeFile(inputModuleDir + '/interactor/' + interactorImplFileName, openTemplateAndReplaceContent("common_module/interactor/interactor.impl.txt", className, moduleName))

    #REPOSITORY
    repositoryFileName = moduleName + '_repository.dart'
    repositoryImplFileName = moduleName + '_repository.impl.dart'
    os.makedirs(inputModuleDir + '/repository/')
    writeFile(inputModuleDir + '/repository/' + repositoryFileName, openTemplateAndReplaceContent("common_module/repository/repository.txt", className, moduleName))
    writeFile(inputModuleDir + '/repository/' + repositoryImplFileName, openTemplateAndReplaceContent("common_module/repository/repository.impl.txt", className, moduleName))

    #VIEWS
    screenFileName = moduleName + '_screen.dart'
    actionImplFileName = moduleName + '.action.dart'
    os.makedirs(inputModuleDir + '/views/')
    writeFile(inputModuleDir + '/views/' + screenFileName, openTemplateAndReplaceContent("common_module/views/screen.txt", className, moduleName))
    writeFile(inputModuleDir + '/views/' + actionImplFileName, openTemplateAndReplaceContent("common_module/views/action.txt", className, moduleName))

    #ROUTE
    routeFileName = moduleName + '_route.dart'
    writeFile(inputModuleDir + '/' + routeFileName, openTemplateAndReplaceContent("common_module/route.txt", className, moduleName))

    #EXPORT
    exportFileName = moduleName + '.dart'
    writeFile(inputModuleDir + '/' + exportFileName, openTemplateAndReplaceContent("common_module/module.txt", className, moduleName))
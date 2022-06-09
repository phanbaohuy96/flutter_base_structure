import os
import subprocess
import sys
import re

classNameKey = "%%CLASS_NAME%%"
moduleNameKey = "%%MODULE_NAME%%"

def subprocess_cmd(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    proc_stdout = process.communicate()[0].strip()
    print(proc_stdout)


def formatClassName(inputName):
    output = re.findall('[A-Z]?[a-z]+',inputName)
    step1 = [word.lower() for word in output]
    step2 = []
    for w in step1:
        step2.append(w.capitalize())
    return ''.join(step2)

def formatModuleName(inputName):
    output = re.findall('[A-Z]?[a-z]+',inputName)
    step1 = [str(word).lower() for word in output]
    step2 = []
    for w in step1:
        step2.append(w)
    return '_'.join(step2)


#BLOC
def blocContent(className, moduleName):
    f = open("template/bloc/bloc.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

def stateImplContent(className, moduleName):
    f = open("template/bloc/state.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

def eventImplContent(className, moduleName):
    f = open("template/bloc/event.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

#INTERACTOR
def interactorContent(className, moduleName):
    f = open("template/interactor/interactor.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

def interactorImplContent(className, moduleName):
    f = open("template/interactor/interactor.impl.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

#REPOSITOY
def repositoryContent(className, moduleName):
    f = open("template/repository/repository.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

def repositoryImplContent(className, moduleName):
    f = open("template/repository/repository.impl.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

#VIEWS
def screenContent(className, moduleName):
    f = open("template/views/screen.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

def actionContent(className, moduleName):
    f = open("template/views/action.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

#ROUTE
def routeContent(className, moduleName):
    f = open("template/route.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

#EXPORT
def exportContent(className, moduleName):
    f = open("template/module.txt", "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

#UTILS
def writeFile(filePath, content):
    f = open(filePath, "w+")
    f.write(content)
    f.close()

if __name__ == "__main__":
    if  len(sys.argv) > 2:
        p =  sys.argv[1]
        n = sys.argv[2]
        className = formatClassName(n)
        moduleName = formatModuleName(n)

        #BLOC
        os.makedirs(p + '/bloc/')
        blocFileName = moduleName + '_bloc.dart'
        eventFileName = moduleName + '_event.dart'
        stateFileName = moduleName + '_state.dart'
        writeFile(p + '/bloc/' + blocFileName, blocContent(className, moduleName))
        writeFile(p + '/bloc/' + stateFileName, stateImplContent(className, moduleName))
        writeFile(p + '/bloc/' + eventFileName, eventImplContent(className, moduleName))


        #INTERACTOR
        os.makedirs(p + '/interactor/')
        interactorFileName = moduleName + '_interactor.dart'
        interactorImplFileName = moduleName + '_interactor.impl.dart'
        writeFile(p + '/interactor/' + interactorFileName, interactorContent(className, moduleName))
        writeFile(p + '/interactor/' + interactorImplFileName, interactorImplContent(className, moduleName))

        #REPOSITORY
        repositoryFileName = moduleName + '_repository.dart'
        repositoryImplFileName = moduleName + '_repository.impl.dart'
        os.makedirs(p + '/repository/')
        writeFile(p + '/repository/' + repositoryFileName, repositoryContent(className, moduleName))
        writeFile(p + '/repository/' + repositoryImplFileName, repositoryImplContent(className, moduleName))

        #VIEWS
        screenFileName = moduleName + '_screen.dart'
        actionImplFileName = moduleName + '.action.dart'
        os.makedirs(p + '/views/')
        writeFile(p + '/views/' + screenFileName, screenContent(className, moduleName))
        writeFile(p + '/views/' + actionImplFileName, actionContent(className, moduleName))

        #ROUTE
        routeFileName = moduleName + '_route.dart'
        writeFile(p  + '/' + routeFileName, routeContent(className, moduleName))

        #EXPORT
        exportFileName = moduleName + '.dart'
        writeFile(p  + '/' + exportFileName, exportContent(className, moduleName))


import re
import os

from definations import classNameKey, moduleNameKey

# input: test_module
# output: TestModule
# input: testModule
# output: TestModule
def formatClassName(inputName):
    output = re.findall('[A-Z]?[a-z]+',inputName)
    step1 = [word.lower() for word in output]
    step2 = []
    for w in step1:
        step2.append(w.capitalize())
    return ''.join(step2)

# input: test_module
# output: test_module
# input: testModule
# output: test_module
def formatModuleName(inputName):
    output = re.findall('[A-Z]?[a-z]+',inputName)
    step1 = [str(word).lower() for word in output]
    step2 = []
    for w in step1:
        step2.append(w)
    return '_'.join(step2)

#eg: openTemplateAndReplaceContent("common_module/module.txt", "className", "moduleName")
def openTemplateAndReplaceContent(relativeFilePathFromTemplate, className, moduleName):
    full_path = os.path.realpath(__file__)
    path, filename = os.path.split(full_path)
    f = open(path + "/templates/" + relativeFilePathFromTemplate, "r")
    return f.read().replace(classNameKey, className).replace(moduleNameKey, moduleName)

def writeFile(filePath, content):
    f = open(filePath, "w+")
    f.write(content)
    f.close()
#!/bin/bash
. ./echo_color.sh

echo """
### **Commands**
Here are the key commands to build, clean, and manage the project:
"""

echoColor $LIGHT_CYAN "To clean the project:"
echoColor $GREEN "run: sh clean.sh"

echo ""

echoColor $LIGHT_CYAN "To build the app for development:"
echoColor $GREEN "run: sh distribution.sh -e dev -p all -a main"

echo ""

echoColor $LIGHT_CYAN "To run generator in main project"
echoColor $GREEN "run: sh run_module_generator.sh apps/main"

echo ""

echoColor $LIGHT_CYAN "To build AAB"
echoColor $GREEN "run: sh build_android_aab.sh -e dev -a main"

echo ""

echoColor $LIGHT_CYAN "To create a keystore for android"
echoColor $GREEN "run: sh create_keystore.sh"

echo ""

echoColor $LIGHT_CYAN "To setup FVM
    - Check your version in fvm_pubspec.yaml"
echoColor $YELLOW "Content: $(cat fvm_pubspec.yaml)"
echoColor $GREEN "run: sh fvm_setup.sh"
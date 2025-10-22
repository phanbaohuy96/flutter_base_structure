#!/bin/bash
. ./flutter_command.sh

setup_flutter_command

cd $1; dart run module_generator:generate_app_localizations; run_flutter_command gen-l10n --format
################################################################################
# Core Mobile Client Makefile
################################################################################

# Main targets
.PHONY: setup build run test clean asset lang format help coverage_main gen gen_all gen_core gen_data_source gen_main \
	pub_get pub_get_plugins pub_get_core pub_get_main pub_get_fl_ui pub_get_fl_utils pub_get_fl_theme pub_get_fl_media pub_get_fl_navigation \
	app_identifier reset run_web_dev run_web_staging build_web clean_force run_module_generator gen_env gen_keystore

# Default target
all: setup build

################################################################################
# Help Command
################################################################################

# Help command
help:
	@echo "Available commands:"
	@echo ""
	@echo "Project Setup:"
	@echo "  make setup              - Complete project setup (clean, pub get, language files, assets, code generation)"
	@echo "  make reset              - Reset project (clean and regenerate everything)"
	@echo ""
	@echo "Package Management:"
	@echo "  make pub_get            - Run flutter pub get for all modules"
	@echo "  make pub_get_plugins    - Run flutter pub get for all plugins" 
	@echo "  make pub_get_core       - Run flutter pub get for core"
	@echo "  make pub_get_main       - Run flutter pub get for main app"
	@echo ""
	@echo "Code Generation:"
	@echo "  make gen                - Interactive code generation menu"
	@echo "  make gen_all            - Generate code for all modules"
	@echo "  make gen_core           - Generate code for core module"
	@echo "  make gen_data_source    - Generate code for data_source module"
	@echo "  make gen_main           - Generate code for main app"
	@echo ""
	@echo "Asset and Localization:"
	@echo "  make asset              - Generate assets"
	@echo "  make lang               - Generate all language files"
	@echo "  make app_identifier     - Generate app identifier"
	@echo "  make gen_env            - Generate environment configuration file"
	@echo "  make gen_keystore       - Generate keystore configuration file"
	@echo ""
	@echo "Build and Run:"
	@echo "  make build              - Interactive build menu (choose environment and platform)"
	@echo "  make run_web_dev        - Run the web app in development mode"
	@echo "  make run_web_staging    - Run the web app in staging mode"
	@echo "  make build_web          - Build web app"
	@echo ""
	@echo "Testing and Coverage:"
	@echo "  make coverage_main      - Generate test coverage report for main app"
	@echo ""
	@echo "Maintenance:"
	@echo "  make format             - Format all Dart code"
	@echo "  make clean              - Clean the project"
	@echo "  make clean_force        - Clean with force option"
	@echo "  make run_module_generator - Run module generator (interactive)"

################################################################################
# Project Setup
################################################################################

# Setup the project
setup: clean pub_get lang asset gen_all gen_env

# Clean the project 
clean:
	sh clean.sh

# Clean with force option
clean_force:
	sh clean.sh --force

################################################################################
# Package Management
################################################################################

# Run flutter pub get for all modules
pub_get:
	@echo "Running flutter pub get for all modules..."
	$(MAKE) pub_get_plugins
	$(MAKE) pub_get_core
	$(MAKE) pub_get_main

# Run flutter pub get for plugins
pub_get_plugins:
	$(MAKE) pub_get_fl_ui
	$(MAKE) pub_get_fl_utils
	$(MAKE) pub_get_fl_theme
	$(MAKE) pub_get_fl_media
	$(MAKE) pub_get_fl_navigation

# Run flutter pub get for each plugin
pub_get_fl_ui:
	cd plugins/fl_ui/; flutter pub get

pub_get_fl_utils:
	cd plugins/fl_utils/; flutter pub get

pub_get_fl_theme:
	cd plugins/fl_theme/; flutter pub get

pub_get_fl_media:
	cd plugins/fl_media/; flutter pub get

pub_get_fl_navigation:
	cd plugins/fl_navigation/; flutter pub get

# Run flutter pub get for core
pub_get_core:
	cd core/; flutter pub get

# Run flutter pub get for main app
pub_get_main:
	cd apps/main/; flutter pub get

################################################################################
# Asset and Localization
################################################################################

# Asset generation
asset:
	cd apps/main/; \
	dart run module_generator:generate_asset apps/main

# Generate all language files
lang:
	sh gen_localization.sh apps/main
	sh gen_localization.sh core
	sh gen_localization.sh plugins/fl_media

################################################################################
# Code Generation
################################################################################

# Generate app identifier
app_identifier:
	@echo "Select App:"; \
	echo "1. Main"; \
	echo "0. Exit"; \
	read -p "Enter app (1-0): " app_choice; \
	if [ $$app_choice = "0" ]; then \
		echo "Exit"; \
		exit 0; \
	fi; \
	if [ $$app_choice = "1" ]; then \
		app="main"; \
	else \
		echo "Invalid choice"; \
		exit 1; \
	fi; \
	sh gen_app_identifier.sh apps/$$app

# Reset project (clean and regenerate everything)
reset:
	sh clean.sh
	$(MAKE) lang
	$(MAKE) asset
	$(MAKE) gen_all
	$(MAKE) gen_env

# Code generation for all modules
gen_all: gen_core gen_data_source gen_main

# Code generation for core
gen_core:
	cd core/; \
	dart run build_runner build --delete-conflicting-outputs; \
	dart run module_generator:generate_export

# Code generation for data_source
gen_data_source:
	cd modules/data_source/; \
	dart run build_runner build --delete-conflicting-outputs; \
	dart run module_generator:generate_export

# Code generation for main app
gen_main:
	cd apps/main/; \
	dart run module_generator:generate_build_runner_config; \
	dart run build_runner build --delete-conflicting-outputs

# Interactive code generation selector
gen:
	@echo "Select module to generate:"
	@echo "1. Apps/main"
	@echo "2. Core"
	@echo "3. Data source"
	@echo "4. All modules"
	@echo "5. Exit"
	@read -p "Enter your choice (1-5): " input; \
	if [ $$input = "1" ]; then \
		$(MAKE) gen_main; \
	elif [ $$input = "2" ]; then \
		$(MAKE) gen_core; \
	elif [ $$input = "3" ]; then \
		$(MAKE) gen_data_source; \
	elif [ $$input = "4" ]; then \
		$(MAKE) gen_all; \
	else \
		echo "Exit"; \
	fi

################################################################################
# Maintenance
################################################################################

# Format all Dart code
format:
	dart format .

# Run module generator
run_module_generator:
	@echo "Which module? ex: apps/main"
	@read name; \
	sh run_module_generator.sh $$name

################################################################################
# Build Process
################################################################################

# Build the app with distribution.sh
build:
	@echo "Select environment:"
	@echo "1. Dev"
	@echo "2. Staging"
	@echo "3. Sandbox"
	@echo "4. Production"
	@echo "5. Exit"
	@read -p "Enter environment (1-5): " env_choice; \
	if [ $$env_choice = "5" ]; then \
		echo "Exit"; \
		exit 0; \
	fi; \
	env="dev"; \
	if [ $$env_choice = "2" ]; then \
		env="staging"; \
	elif [ $$env_choice = "3" ]; then \
		env="sandbox"; \
	elif [ $$env_choice = "4" ]; then \
		env="prod"; \
	fi; \
	echo "Select platform:"; \
	echo "1. Android"; \
	echo "2. iOS"; \
	echo "3. Web"; \
	echo "4. All platforms"; \
	echo "5. Exit"; \
	read -p "Enter platform (1-5): " plat_choice; \
	if [ $$plat_choice = "5" ]; then \
		echo "Exit"; \
		exit 0; \
	fi; \
	platform="android"; \
	if [ $$plat_choice = "2" ]; then \
		platform="ios"; \
	elif [ $$plat_choice = "3" ]; then \
		platform="web"; \
	elif [ $$plat_choice = "4" ]; then \
		platform="all"; \
	fi; \
	sh distribution.sh -e $$env -p $$platform -a main

################################################################################
# Running the Application
################################################################################

# Run the app in development mode
run_web_dev:
	cd apps/main/ && \
	flutter run -d web-server --web-port 3000 -t lib/main_dev.dart --dart-define-from-file="./.env"

# Run the app in staging mode
run_web_staging:
	cd apps/main/ && \
	flutter run -d web-server --web-port 3000 -t lib/main_staging.dart --dart-define-from-file="./.env"

# Build web app
build_web:
	@echo "Select environment:"
	@echo "1. Dev"
	@echo "2. Staging"
	@echo "3. Sandbox"
	@echo "4. Production"
	@echo "5. Exit"
	@read -p "Enter environment (1-5): " env_choice; \
	if [ $$env_choice = "5" ]; then \
		echo "Exit"; \
		exit 0; \
	fi; \
	env="dev"; \
	if [ $$env_choice = "2" ]; then \
		env="staging"; \
	elif [ $$env_choice = "3" ]; then \
		env="sandbox"; \
	elif [ $$env_choice = "4" ]; then \
		env="prod"; \
	fi; \
	echo "Select App:"; \
	echo "1. Main"; \
	echo "0. Exit"; \
	read -p "Enter app (1-0): " app_choice; \
	if [ $$app_choice = "0" ]; then \
		echo "Exit"; \
		exit 0; \
	fi; \
	if [ $$app_choice = "1" ]; then \
		MAIN="main"; \
	else \
		echo "Invalid choice"; \
		exit 1; \
	fi; \
	sh build_web.sh -e $$env -a $$MAIN

################################################################################
# Testing and Coverage
################################################################################

# Generate test coverage report for main app
coverage_main:
	sh coverage.sh apps/main

# Generate app environment files
gen_env:
	@echo "Select path:"; \
	echo "1. Main"; \
	echo "0. Exit"; \
	read -p "Enter (1-0): " choice; \
	if [ $$choice = "0" ]; then \
		echo "Exit"; \
		exit 0; \
	fi; \
	if [ $$choice = "1" ]; then \
		APP="apps/main"; \
	else \
		echo "Invalid choice"; \
		exit 1; \
	fi; \
	if [ -f "$$APP/.env" ]; then \
		echo "Warning: .env file already exists in $$APP/"; \
		read -p "Do you want to overwrite it? (y/N): " confirm; \
		if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
			echo "Operation cancelled."; \
			exit 0; \
		fi; \
	fi; \
	echo "Creating .env file in $$APP/..."; \
	echo "# Environment Configuration\n\
DART_ENV_NAME=''\n\
DART_BASE_API_LAYER=''\n\
DART_STORAGE_API_LAYER=''\n\
DART_STORAGE_ASSET_LAYER=''\n\
\n\
## POSTHOG\n\
DART_POSTHOG_API_KEY=''\n\
DART_POSTHOG_API_HOST=''\n\
\n\
## FIREBASE\n\
# ANDROID\n\
DART_ANDROID_FIREBASE_API_KEY=''\n\
DART_ANDROID_FIREBASE_APP_ID=''\n\
DART_ANDROID_FIREBASE_MESSAGING_SENDER_ID=''\n\
DART_ANDROID_FIREBASE_PROJECT_ID=''\n\
DART_ANDROID_FIREBASE_STORAGE_BUCKET=''\n\
DART_ANDROID_FIREBASE_MEASUREMENT_ID=''\n\
DART_ANDROID_FIREBASE_AUTH_DOMAIN=''\n\
DART_ANDROID_FIREBASE_DATABASE_URL=''\n\
\n\
# IOS\n\
DART_IOS_FIREBASE_API_KEY=''\n\
DART_IOS_FIREBASE_APP_ID=''\n\
DART_IOS_FIREBASE_MESSAGING_SENDER_ID=''\n\
DART_IOS_FIREBASE_PROJECT_ID=''\n\
DART_IOS_FIREBASE_STORAGE_BUCKET=''\n\
DART_IOS_FIREBASE_MEASUREMENT_ID=''\n\
DART_IOS_FIREBASE_AUTH_DOMAIN=''\n\
DART_IOS_FIREBASE_DATABASE_URL=''\n\
\n\
# WEB\n\
DART_WEB_FIREBASE_API_KEY=''\n\
DART_WEB_FIREBASE_APP_ID=''\n\
DART_WEB_FIREBASE_MESSAGING_SENDER_ID=''\n\
DART_WEB_FIREBASE_PROJECT_ID=''\n\
DART_WEB_FIREBASE_STORAGE_BUCKET=''\n\
DART_WEB_FIREBASE_MEASUREMENT_ID=''\n\
DART_WEB_FIREBASE_AUTH_DOMAIN=''\n\
DART_WEB_FIREBASE_DATABASE_URL=''" > $$APP/.env; \
	echo ".env file created successfully in $$APP/"

# Generate keystore configuration files
gen_keystore:
	@echo "Select path:"; \
	echo "1. Main"; \
	echo "0. Exit"; \
	read -p "Enter (1-0): " choice; \
	if [ $$choice = "0" ]; then \
		echo "Exit"; \
		exit 0; \
	fi; \
	if [ $$choice = "1" ]; then \
		APP="apps/main"; \
	else \
		echo "Invalid choice"; \
		exit 1; \
	fi; \
	if [ -f "$$APP/android/keystores/keystore.properties" ]; then \
		echo "Warning: keystore.properties file already exists in $$APP/android/keystores/"; \
		read -p "Do you want to overwrite it? (y/N): " confirm; \
		if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
			echo "Operation cancelled."; \
			exit 0; \
		fi; \
	fi; \
	echo "Creating keystore.properties file in $$APP/android/keystores/..."; \
	echo "# =========================================================================\n\
# Android Keystore Configuration\n\
# =========================================================================\n\
# This file contains keystore configuration for different build variants\n\
# Certificate validity: 8760 days (24 years)\n\
# =========================================================================\n\
\n\
# -------------------------------------------------------------------------\n\
# DEVELOPMENT Environment\n\
# -------------------------------------------------------------------------\n\
# Certificate DN: CN=VietNam Silicon, OU=VNS, O=VNS, L=VietNam, ST=HCM, C=84\n\
DEV_STORE_FILE=../keystores/dev_keystore.jks\n\
DEV_KEY_ALIAS=placeholder-value\n\
DEV_STORE_PASSWORD=placeholder-value\n\
DEV_KEY_PASSWORD=placeholder-value\n\
\n\
# -------------------------------------------------------------------------\n\
# STAGING Environment\n\
# -------------------------------------------------------------------------\n\
# Certificate DN: CN=VietNam Silicon, OU=VNS, O=VNS, L=VietNam, ST=HCM, C=84\n\
STAGING_STORE_FILE=../keystores/staging_keystore.jks\n\
STAGING_KEY_ALIAS=placeholder-value\n\
STAGING_STORE_PASSWORD=placeholder-value\n\
STAGING_KEY_PASSWORD=placeholder-value\n\
\n\
# -------------------------------------------------------------------------\n\
# SANDBOX Environment\n\
# -------------------------------------------------------------------------\n\
# Certificate DN: CN=Bangkok Silicon, OU=BKS, O=BKS, L=Thailand, ST=Bangkok, C=66\n\
SANDBOX_STORE_FILE=../keystores/sandbox_keystore.jks\n\
SANDBOX_KEY_ALIAS=placeholder-value\n\
SANDBOX_STORE_PASSWORD=placeholder-value\n\
SANDBOX_KEY_PASSWORD=placeholder-value\n\
\n\
# -------------------------------------------------------------------------\n\
# PRODUCTION Environment\n\
# -------------------------------------------------------------------------\n\
# Certificate DN: CN=Bangkok Silicon, OU=BKS, O=BKS, L=Thailand, ST=Bangkok, C=66\n\
PROD_STORE_FILE=../keystores/keystore.jks\n\
PROD_KEY_ALIAS=placeholder-value\n\
PROD_STORE_PASSWORD=placeholder-value\n\
PROD_KEY_PASSWORD=placeholder-value" > $$APP/android/keystores/keystore.properties; \
	echo "keystore.properties file created successfully in $$APP/android/keystores/"
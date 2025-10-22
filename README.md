## Core Project Template
### **Mobile Flutter Core**

The **Mobile Flutter Core** project template provides a robust foundation for building scalable and maintainable Flutter applications. It incorporates best practices and a modular architecture to streamline development and ensure code quality.

---

### **Architecture**
The project follows **Clean Code Architecture**, which ensures:
- **Separation of Concerns**: Divides the project into layers (e.g., data, domain, presentation) to maintain modularity and scalability.
- **Testability**: Each layer is independent, making it easier to write unit tests.
- **Maintainability**: Clear structure and modular design make the codebase easier to maintain and extend.

### **Project Structure**
The project is organized as follows:

```
├── apps (Contains all application projects)
│   └── main (Mobile application project)
│
├── core (Core functionalities shared across the project)
│
├── modules (Feature-specific modules)
│   └── data_source (Handles data and repository logic)
│
├── plugins (Custom plugins for extended functionality)
│   ├── fl_media (Media handling: view, picker, crop)
│   ├── fl_theme (Custom themes: AppTextTheme, ScreenTheme, etc.)
│   ├── fl_ui (Common widgets for UI consistency)
│   └── fl_utils (Utility functions: extensions, DateUtils, etc.)
│
├── tools (Support tools for project automation)
│
├── clean.sh (Script to clean the project: `sh clean.sh -h`)
│
├── distribution.sh (Script for building and distributing the app: `sh distribution.sh -h`)
│
├── gen_app_identifier.sh (Generate app identifiers: `sh gen_app_identifier.sh <PATH-TO-APP>`)
│
├── gen_localization.sh (Generate localization files: `sh gen_localization.sh <PATH-TO-MODULE>`)
│
├── makefile (Project automation with make commands: `make help`)
│
├── pub_gen.sh (Re-generate files: `sh pub_gen.sh -h`)
│
├── run_module_generator.sh (Run module generator: `sh run_module_generator.sh <PATH-TO-MODULE>`)
│
└── README.md (Project documentation)
```

---

## Requirements

### **Version Configuration**
- **Flutter**: Version `>=3.32.8`
- **Dart**: Ensure compatibility with the Flutter version.
- **Android SDK**: Compile SDK version `34` or higher.
- **Java**: Version `17` for both Kotlin and Java compatibility.

---

## Utilities

### **Commands**
Here are the key commands to build, clean, and manage the project:

#### **Debug Web Dev**
To debug main web-app, you can use:
```bash
# Using makefile command
make run_web_dev

# Or using the direct Flutter command
cd ./apps/main/
flutter run -d web-server --web-port 3000 -t lib/main_dev.dart --dart-define-from-file="./.env"
```

#### **Build**
To build the app:
```bash
cd apps/main
flutter build apk --release --flavor dev --target="lib/main_dev.dart"
```

#### **Setup**
To clean the project:
```bash
sh clean.sh
```

#### **Build Commands**
To build the app for development:
```bash
sh distribution.sh -e dev -p all -a main
```

### **Makefile Commands**
The project includes a comprehensive makefile for streamlined development workflows. All commands follow the snake_case naming convention. Here are the most useful commands:

#### **Getting Help**
```bash
# Display all available makefile commands with descriptions
make help
```

#### **Project Setup**
```bash
# Complete project setup (clean, pub get, language files, assets, code generation)
make setup

# Reset project (clean and regenerate everything)
make reset

# Generate environment configuration file
make gen_env

# Generate keystore configuration file
make gen_keystore
```

#### **Package Management**
```bash
# Run flutter pub get for all modules
make pub_get

# Run flutter pub get for specific modules
make pub_get_plugins
make pub_get_core
make pub_get_main

# Run flutter pub get for individual plugins
make pub_get_fl_ui
make pub_get_fl_utils
make pub_get_fl_theme
make pub_get_fl_media
```

#### **Code Generation**
```bash
# Generate code for all modules
make gen_all

# Generate code for specific modules
make gen_core
make gen_data_source
make gen_main

# Interactive code generation menu
make gen
```

#### **Asset and Localization**
```bash
# Generate assets
make asset

# Generate all language files
make lang

# Generate app identifier
make app_identifier
```

#### **Build and Run**
```bash
# Interactive build menu (choose environment and platform)
make build

# Run the web app in development mode
make run_web_dev

# Run the web app in staging mode
make run_web_staging

# Build web app
make build_web
```

#### **Testing and Coverage**
```bash
# Generate test coverage report for main app
make coverage_main
```

#### **Maintenance**
```bash
# Format all Dart code
make format

# Clean the project
make clean

# Clean with force option
make clean_force

# Run module generator (interactive)
make run_module_generator
```

---

### **Tools**
The project includes several tools to automate and simplify development tasks:

1. **Module Generator**:
   - Command: `dart run module_generator`
   - Module Name: Use under-score naming convention (e.g., `test_module`).

2. **Asset Generator**:
   - Command: `dart run module_generator:generate_asset <path-to-root-preview-image>`

3. **App Localizations Generator**:
   - Commands:
     - Generate localizations: `dart run module_generator:generate_app_localizations`
     - Generate CSV from localizations: `dart run module_generator:generate_csv_from_localizations`

4. **Export Generator**:
   - Command: `dart run module_generator:generate_export`

---

### **Summary**

The **Mobile Flutter Core** template is a modular, scalable, and maintainable solution for Flutter applications. It leverages clean code architecture, custom tools, and Flutter's capabilities to streamline development and ensure high-quality software delivery.

---

### **Documentation**
- [Base Project Structure](https://vns-site.atlassian.net/wiki/x/kQBiAw)
   - [Core](https://vns-site.atlassian.net/wiki/x/UQBiAw)
- [Clean Code Architecture](https://vns-site.atlassian.net/wiki/x/lwBiAw)
- [Generator Tool Documentation](https://vns-site.atlassian.net/wiki/x/PABiAw)
- [App Distribution Script Documentation](https://vns-site.atlassian.net/wiki/x/OgBiAw)

## Core Project Template
The **Mobile Flutter Core** project template is designed to provide a robust foundation for building scalable and maintainable Flutter applications. It incorporates best practices and a modular architecture to streamline development and ensure code quality.

### **Key Features**
- **Clean Code Architecture**: Promotes separation of concerns by dividing the project into distinct layers (data, domain, presentation).
- **Custom Plugins**: Includes reusable plugins for media handling, theming, UI components, and utility functions.
- **Automation Tools**: Provides scripts and tools for project setup, module generation, localization, and distribution.
- **Scalability**: Modular structure allows easy addition of new features and components.
- **Cross-Platform Support**: Leverages Flutter's capabilities to deliver consistent experiences across Android and iOS.

This template serves as a starting point for developers to build high-quality applications efficiently while adhering to industry standards.

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
├── pub_gen.sh (Re-generate files: `sh pub_gen.sh -h`)
│
├── run_module_generator.sh (Run module generator: `sh run_module_generator.sh <PATH-TO-MODULE>`)
│
└── README.md (Project documentation)
```

---

## Requirements

### **Version Configuration**
- **Flutter**: Version `>=3.27.0`
- **Dart**: Ensure compatibility with the Flutter version.
- **Android SDK**: Compile SDK version `34` or higher.
- **Java**: Version `17` for both Kotlin and Java compatibility.

---

## Utilities

### **Commands**
Here are the key commands to build, clean, and manage the project:

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

## Summary
This project is a modular, scalable, and maintainable solution for Flutter applications. It leverages Flutter's capabilities, clean code architecture, and custom tools to streamline development and ensure high-quality software delivery.
## Core Project Template
### **Mobile Flutter Core**

The **Mobile Flutter Core** project template provides a robust foundation for building scalable and maintainable Flutter applications. It incorporates best practices and a modular architecture to streamline development and ensure code quality.

---

### **Key Features**
- **Clean Code Architecture**: Separation of concerns with distinct layers (data, domain, presentation).
- **Custom Plugins**: Reusable plugins for media handling, theming, UI components, and utilities.
- **Automation Tools**: Scripts for project setup, module generation, localization, and distribution.
- **Scalability**: Modular structure for easy feature and component addition.
- **Cross-Platform Support**: Consistent experiences across Android and iOS.

---

### **Project Structure**

```plaintext
├── apps/
│   └── main/                # Mobile application project
├── core/                    # Core functionalities shared across the project
├── modules/                 # Feature-specific modules
│   └── data_source/         # Handles data and repository logic
├── plugins/                 # Custom plugins for extended functionality
│   ├── fl_media/            # Media handling: view, picker, crop
│   ├── fl_theme/            # Custom themes: AppTextTheme, ScreenTheme, etc.
│   ├── fl_ui/               # Common widgets for UI consistency
│   └── fl_utils/            # Utility functions: extensions, DateUtils, etc.
├── tools/                   # Support tools for project automation
├── clean.sh                 # Clean the project: `sh clean.sh -h`
├── distribution.sh          # Build and distribute the app: `sh distribution.sh -h`
├── gen_app_identifier.sh    # Generate app identifiers: `sh gen_app_identifier.sh <PATH-TO-APP>`
├── gen_localization.sh      # Generate localization files: `sh gen_localization.sh <PATH-TO-MODULE>`
├── pub_gen.sh               # Re-generate files: `sh pub_gen.sh -h`
├── run_module_generator.sh  # Run module generator: `sh run_module_generator.sh <PATH-TO-MODULE>`
└── README.md                # Project documentation
```

---

### **Requirements**

#### **Version Configuration**
- **Flutter**: `>=3.27.0`
- **Dart**: Compatible with the Flutter version.
- **Android SDK**: Compile SDK version `34` or higher.
- **Java**: Version `17` for Kotlin and Java compatibility.

---

### **Utilities**

#### **Commands**
- **Build the App**:
   ```bash
   cd apps/main
   flutter build apk --release --flavor dev --target="lib/main_dev.dart"
   ```
- **Clean the Project**:
   ```bash
   sh clean.sh
   ```
- **Build for Development**:
   ```bash
   sh distribution.sh -e dev -p all -a main
   ```

#### **Tools**
1. **Module Generator**:
    - Command: `dart run module_generator`
    - Naming: Use under_score convention (e.g., `test_module`).

2. **Asset Generator**:
    - Command: `dart run module_generator:generate_asset <path-to-root-preview-image>`

3. **Localization Generator**:
    - Generate localizations: `dart run module_generator:generate_app_localizations`
    - Generate CSV: `dart run module_generator:generate_csv_from_localizations`

4. **Export Generator**:
    - Command: `dart run module_generator:generate_export`

---

### **Summary**

The **Mobile Flutter Core** template is a modular, scalable, and maintainable solution for Flutter applications. It leverages clean code architecture, custom tools, and Flutter's capabilities to streamline development and ensure high-quality software delivery.

---

### **Documentation**
- [Base Project Structure](https://bks-team.atlassian.net/wiki/x/rADoAw)
   - [Core](https://bks-team.atlassian.net/wiki/x/moH2Aw)
- [Clean Code Architecture](https://bks-team.atlassian.net/wiki/x/VoH2Aw)
- [Generator Tool Documentation](https://bks-team.atlassian.net/wiki/x/rADpAw)
- [Best Practices and Performance Optimization](https://bks-team.atlassian.net/wiki/x/tgDoAw)
- [App Distribution Script Documentation](https://bks-team.atlassian.net/wiki/x/wADoAw)

import 'dart:async';

import '../common/file_helper.dart';

class ProjectConfigDocument {
  final List<PlatformConfigDocument> documents;

  ProjectConfigDocument(this.documents);
}

class AppConfig {
  final String? package;
  final String? name;

  AppConfig(this.package, this.name);

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      map['package'] != null ? map['package'] as String : null,
      map['name'] != null ? map['name'] as String : null,
    );
  }
}

class PlatformConfigDocument<T extends ConfigDocument> {
  final T document;
  final String configFilePath;

  PlatformConfigDocument({
    required this.configFilePath,
    required this.document,
  });

  static PlatformConfigDocument create(
    MapEntry<String, dynamic> entry,
  ) {
    switch (entry.key.toLowerCase()) {
      case 'android':
        return PlatformConfigDocument<AndroidConfigDocument>(
          configFilePath: 'android/app_specific.properties',
          document: AndroidConfigDocument(
            ConfigDocument.documentFromMap(entry.value),
          ),
        );
      case 'ios':
        return PlatformConfigDocument<IOSConfigDocument>(
          configFilePath: 'ios/Flutter/AppSpecific.xcconfig',
          document: IOSConfigDocument(
            ConfigDocument.documentFromMap(entry.value),
          ),
        );
      default:
        return UnknowPlatformConfigDocument();
    }
  }
}

class UnknowPlatformConfigDocument extends PlatformConfigDocument {
  UnknowPlatformConfigDocument()
      : super(
          configFilePath: '',
          document: UnknowConfigDocument(),
        );
}

abstract class ConfigDocument {
  String get contentFile;

  static Map<String, AppConfig> documentFromMap(Map<String, dynamic> raw) {
    return {
      ...raw.entries.fold({}, (previousValue, element) {
        return {
          ...previousValue,
          element.key: AppConfig.fromMap(element.value),
        };
      }),
    };
  }
}

class UnknowConfigDocument extends ConfigDocument {
  @override
  String get contentFile => '';
}

class AndroidConfigDocument extends ConfigDocument {
  final Map<String, AppConfig> document;

  AndroidConfigDocument(this.document);

  @override
  String get contentFile {
    return [
      ...document.entries.map(
        (e) => '''# ${e.key}
app.${e.key.toLowerCase()}.name=${e.value.name}
app.${e.key.toLowerCase()}.package=${e.value.package}
''',
      )
    ].join('\n');
  }
}

class IOSConfigDocument extends ConfigDocument {
  final Map<String, AppConfig> document;

  IOSConfigDocument(this.document);

  @override
  String get contentFile {
    return [
      ...document.entries.map(
        (e) => '''// ${e.key}
${e.key.toUpperCase()}_APP_DISPLAY_NAME=${e.value.name}
${e.key.toUpperCase()}_PRODUCT_BUNDLE_IDENTIFIER=${e.value.package}
''',
      )
    ].join('\n');
  }
}

Future<void> generateAppIdentifier({
  required ProjectConfigDocument project,
}) async {
  await Future.wait([
    ...project.documents.map((e) {
      if (e.configFilePath.isNotEmpty) {
        return FilesHelper.writeFile(
          pathFile: e.configFilePath,
          content: e.document.contentFile,
        );
      }
      return Future.value();
    }),
  ]);
}

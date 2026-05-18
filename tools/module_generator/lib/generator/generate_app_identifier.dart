import 'dart:async';

import '../common/file_helper.dart';

class ProjectConfigDocument {
  final List<PlatformConfigDocument> documents;

  ProjectConfigDocument(this.documents);
}

class AppConfig {
  final String? package;
  final String? name;
  final String? provisioningProfileSpecifier;
  final String? teamId;

  AppConfig({
    this.package,
    this.name,
    this.provisioningProfileSpecifier,
    this.teamId,
  });

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      package: map['package'] as String?,
      name: map['name'] as String?,
      provisioningProfileSpecifier:
          map['provisioning_profile_specifier'] as String?,
      teamId: map['team_id'] as String?,
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

  static PlatformConfigDocument create(MapEntry<String, dynamic> entry) {
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
        return UnknownPlatformConfigDocument();
    }
  }
}

class UnknownPlatformConfigDocument extends PlatformConfigDocument {
  UnknownPlatformConfigDocument()
    : super(configFilePath: '', document: UnknownConfigDocument());
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

class UnknownConfigDocument extends ConfigDocument {
  @override
  String get contentFile => '';
}

class AndroidConfigDocument extends ConfigDocument {
  final Map<String, AppConfig> document;

  AndroidConfigDocument(this.document);

  @override
  String get contentFile {
    return document.entries.map((e) {
      final key = e.key.toLowerCase();
      return '''# ${e.key}
app.$key.name=${e.value.name}
app.$key.package=${e.value.package}
''';
    }).join('\n');
  }
}

class IOSConfigDocument extends ConfigDocument {
  final Map<String, AppConfig> document;

  IOSConfigDocument(this.document);

  @override
  String get contentFile {
    return document.entries.map((e) {
      final prefix = e.key.toUpperCase();
      return '''// ${e.key}
${prefix}_APP_DISPLAY_NAME=${e.value.name}
${prefix}_PRODUCT_BUNDLE_IDENTIFIER=${e.value.package}
${prefix}_PROVISIONING_PROFILE_SPECIFIER=${e.value.provisioningProfileSpecifier ?? ''}
${prefix}_DEVELOPMENT_TEAM=${e.value.teamId ?? ''}
''';
    }).join('\n');
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

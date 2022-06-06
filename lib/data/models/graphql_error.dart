class GraphQLException {
  Extensions? extensions;
  String? message;

  GraphQLException({this.extensions, this.message});

  GraphQLException.fromJson(Map<String, dynamic> json) {
    extensions = json['extensions'] is Map<String, dynamic>
        ? Extensions.fromJson(json['extensions'])
        : null;
    message = json['message'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (extensions != null) {
      data['extensions'] = extensions?.toJson();
    }
    data['message'] = message;
    return data;
  }

  bool get isUnexpected => extensions?.code == GraphQLErrorCode.unexpected;
  bool get isAccessDenied => extensions?.code == GraphQLErrorCode.accessDenied;
  bool get isUnknowError => extensions?.code?.isNotEmpty != true;
}

class Extensions {
  String? path;
  String? code;

  Extensions({this.path, this.code});

  Extensions.fromJson(Map<String, dynamic> json) {
    path = json['path'] is String ? json['path'] : null;
    code = json['code'] is String ? json['code'] : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['path'] = path;
    data['code'] = code;
    return data;
  }
}

class GraphQLErrorCode {
  static String unexpected = 'unexpected';
  static String accessDenied = 'access-denied';
}

import 'dart:convert';

import 'package:flutter/material.dart';

/// Decodes a JSON theme string into a map.
Map<String, dynamic> decodeThemeJson(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Theme JSON must be an object');
  }
  return decoded;
}

/// Encodes a JSON theme map with stable indentation.
String encodeThemeJson(Map<String, dynamic> json) {
  return const JsonEncoder.withIndent('  ').convert(json);
}

/// Reads an object value from [json] or returns [fallback] when absent.
Map<String, dynamic> readObject(
  Map<String, dynamic> json,
  String key, {
  Map<String, dynamic> fallback = const {},
}) {
  final value = json[key];
  if (value == null) {
    return fallback;
  }
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  throw FormatException('$key must be an object');
}

/// Reads a nullable string value from [json].
String? readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  throw FormatException('$key must be a string');
}

/// Reads a boolean value from [json] or returns [fallback] when absent.
bool readBool(Map<String, dynamic> json, String key, bool fallback) {
  final value = json[key];
  if (value == null) {
    return fallback;
  }
  if (value is bool) {
    return value;
  }
  throw FormatException('$key must be a boolean');
}

/// Reads an integer value from [json] or returns [fallback] when absent.
int readInt(Map<String, dynamic> json, String key, int fallback) {
  final value = json[key];
  if (value == null) {
    return fallback;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  throw FormatException('$key must be a number');
}

/// Reads a double value from [json] or returns [fallback] when absent.
double readDouble(Map<String, dynamic> json, String key, double fallback) {
  final value = json[key];
  if (value == null) {
    return fallback;
  }
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('$key must be a number');
}

/// Reads a hex color string from [json] or returns [fallback] when absent.
Color readColor(
  Map<String, dynamic> json,
  String key,
  Color fallback, {
  String? path,
}) {
  final value = json[key];
  final errorPath = path ?? key;
  if (value == null) {
    return fallback;
  }
  if (value is! String) {
    throw FormatException('$errorPath must be a hex color string');
  }
  return themeColorFromHex(value, path: errorPath);
}

/// Parses a `#RRGGBB` or `#AARRGGBB` string into a Flutter [Color].
Color themeColorFromHex(String value, {String path = 'color'}) {
  final normalized = value.trim().replaceFirst('#', '');
  final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  if (hex.length != 8 || !RegExp(r'^[0-9A-Fa-f]{8}$').hasMatch(hex)) {
    throw FormatException('$path must be #RRGGBB or #AARRGGBB');
  }
  return Color(int.parse(hex, radix: 16));
}

/// Encodes a Flutter [Color] as an uppercase `#AARRGGBB` string.
String themeColorToHex(Color color) {
  final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${value.toUpperCase()}';
}

/// Parses a JSON theme mode string into a Flutter [Brightness].
Brightness brightnessFromJson(String? value) {
  switch (value) {
    case null:
    case 'light':
      return Brightness.light;
    case 'dark':
      return Brightness.dark;
  }
  throw const FormatException('mode must be light or dark');
}

/// Encodes a Flutter [Brightness] as a JSON theme mode string.
String brightnessToJson(Brightness brightness) {
  return brightness.name;
}

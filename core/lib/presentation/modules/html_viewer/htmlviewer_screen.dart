// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common_widget/html_widget_wrapper.dart';

class HtmlviewerScreenArgs {
  final String? title;
  final String html;

  HtmlviewerScreenArgs({required this.title, required this.html});

  HtmlviewerScreenArgs copyWith({String? title, String? html}) {
    return HtmlviewerScreenArgs(
      title: title ?? this.title,
      html: html ?? this.html,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'html': html};
  }

  factory HtmlviewerScreenArgs.fromMap(Map<String, dynamic> map) {
    return HtmlviewerScreenArgs(
      title: map['title'] as String,
      html: map['html'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory HtmlviewerScreenArgs.fromJson(String source) =>
      HtmlviewerScreenArgs.fromMap(json.decode(source));
}

class HtmlViewerScreen extends StatelessWidget {
  static const String routeName = '/html';

  final HtmlviewerScreenArgs params;

  const HtmlViewerScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(params.title ?? '')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: HtmlWidgetWrapper(
          htmlContent: params.html,
          textStyle: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}

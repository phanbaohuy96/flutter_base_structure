import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

class CoreCommonFunction extends CommonFunction {
  String wrapStyleHtmlContent(String htmlContent, {bool isCenter = false}) {
    return '''<!DOCTYPE html>
    <html>
      <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
      <style>* {
        font-family: 'SF-Pro';
        line-height: 1.5;
        margin: 0;
        padding: 0;
      }
      h2 {
        font-size: 24px;
        margin-bottom: 12px;
      }
      h3 {
        font-size: 18px;
        margin-bottom: 12px;
      }
      h4 {
        font-size: 16px;
        margin-bottom: 10px;
      }
      hr {
        height: 1px;
        color: #123455;
        background-color: #123455;
        border: none;
      }
      p {
        font-size: 14px;
        margin-bottom: 10px;
      }
      a {
        text-decoration: underline;
      }
      img {
        display: block;
        margin: 0 auto;
        max-width: 100%;
        min-width: 50px;
      }
      .table {
        width: 100% !important;
        table {
          border: 1px double #B3B3B3;
          th, td {
            border: 1px double #D9D9D9;
          }
        }
      }
      figcaption {
        text-align: center;
      }
      div {
        padding-top: 8px;
        padding-right: 8px;
        padding-bottom: 8px;
        padding-left: 8px;
      }
      figure.image {
        display: inline-block;
        border: 1px solid gray;
        margin: 0 2px 0 1px;
        background: #f5f2f0;
      }
      figure.align-left {
        float: left;
      }
      figure.align-right {
        float: right;
      }
      figure.image img {
        margin: 8px 8px 0 8px;
      }
      figure.image figcaption {
        margin: 6px 8px 6px 8px;
        text-align: center;
      }
      img.align-left {
        float: left;
      }
      img.align-right {
        float: right;
      }
      .mce-toc {
        border: 1px solid gray;
      }
      .mce-toc h2 {
        margin: 4px;
      }
      .mce-toc li {
        list-style-type: none;
      }
      </style>
      <body>
        ${isCenter ? '<center>' : ''}
        <div>
          $htmlContent
        </div>
        ${isCenter ? '</center>' : ''}
      </body>
    </html>''';
  }

  Map<String, String> customStylesBuilder(dom.Element element) {
    final style = {
      'line-height': '1.5',
      'margin': '0',
      'padding': '0',
    };
    switch (element.localName) {
      case 'h2':
        return {
          'font-family': 'SF-Pro',
          'font-size': '24px',
          'margin-bottom': '12px',
          ...style,
        };
      case 'h3':
        return {
          'font-family': 'SF-Pro',
          'font-size': '18px',
          'margin-bottom': '12px',
          ...style,
        };
      case 'h4':
        return {
          'font-family': 'SF-Pro',
          'font-size': '16px',
          'margin-bottom': '10px',
          ...style,
        };
      case 'p':
        return {
          'font-family': 'SF-Pro',
          'font-size': '14px',
          'margin-bottom': '10px',
          ...style,
        };
      case 'a':
        return {
          'font-family': 'SF-Pro',
          'text-decoration': 'underline',
          ...style,
        };
      case 'img':
        return {
          'display': 'block',
          'max-width': '100%',
          'min-width': '50px',
          ...style,
        };
      case 'figcaption':
        return {'font-family': 'SF-Pro', 'text-align': 'center'};
      case 'style':
        return {
          'font-family': 'SF-Pro',
          'line-height': '1.5',
          'margin': '0',
          'padding': '0',
        };
      case '.table':
        return {'width': '100% !important', ...style};
      case 'table':
        return {'border': '1px double #B3B3B3', ...style};
      case 'th':
      case 'td':
        return {'border': '1px double #D9D9D9', ...style};
      case 'ol':
      case 'ul':
        return {'padding-left': '24px', 'font-size': '14px'};
      case '::marker':
        return {
          'unicode-bidi': 'isolate',
          'font-variant-numeric': 'tabular-nums',
          'text-transform': 'none',
          'text-indent': '0px !important',
          'text-align': 'start !important',
          'text-align-last': 'start !important',
          ...style,
        };
      default:
        return {
          'font-family': 'SF-Pro',
          'line-height': '1.5',
          'margin': '0',
          'padding': '0',
        };
    }
  }

  @override
  bool shouldUpdateApp(String currentVersion, String newVersion) {
    if (newVersion.isEmpty) {
      return false;
    }
    return compareVersionNames(currentVersion, newVersion) < 0;
  }

  @override
  bool compare(String currentVersion, String newVersion) {
    if (newVersion.isEmpty) {
      return false;
    }
    return compareVersionNames(currentVersion, newVersion) == 0;
  }

  Future<bool> tryLunchUri(String uri) {
    final _url = Uri.parse(uri);
    return canLaunchUrl(_url).then((value) {
      if (value) {
        return launchUrl(_url, mode: LaunchMode.externalApplication);
      }
      return Future.value(false);
    });
  }

  Future<bool> tryTel(String phone) {
    final _url = Uri.parse('tel:$phone');

    return launchUrl(_url);
  }

  Map<String, dynamic> castMap(Map originalMap) {
    return originalMap.map((key, value) {
      final newKey = key.toString();

      if (value is Map) {
        return MapEntry(newKey, castMap(value));
      }

      if (value is List) {
        return MapEntry(newKey, [
          ...value.map(
            (e) {
              if (e is Map) {
                return castMap(e);
              }
              return e;
            },
          ),
        ]);
      }

      return MapEntry(newKey, value);
    });
  }
}

part of '../utils.dart';

class CommonFunction {
  static void hideKeyBoard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static String prettyJsonStr(Map<dynamic, dynamic> json) {
    final encoder = JsonEncoder.withIndent('  ', (data) => data.toString());
    return encoder.convert(json);
  }

  static String wrapStyleHtmlContent(String htmlContent) {
    return '''<!DOCTYPE html>
    <html>
      <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
      <style>* {
        font-family: 'Inter-regular';
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
      }</style>
      <body>
        <div>
          $htmlContent
        </div>
      </body>
    </html>''';
  }
}

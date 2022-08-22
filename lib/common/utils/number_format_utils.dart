import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';

class NumberFormatUtils {
  NumberFormatUtils._();

  static const _locale = 'vi_vn';

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: _locale,
    symbol: 'đ',
  );
  static final NumberFormat _numberFormat =
      NumberFormat.decimalPattern(_locale);

  static String? displayMoney(double? amount) {
    if (amount == null) {
      return null;
    }
    return amount.toCurrencyString(
      mantissaLength: 0,
      trailingSymbol: 'đ',
      useSymbolPadding: true,
      thousandSeparator: ThousandSeparator.Period,
    );
  }

  static String? decimalFormat(double? number) {
    return _numberFormat.format(number);
  }

  static double? parseDouble(String? string) {
    if (string == null || string.isEmpty == true) {
      return null;
    }
    return _numberFormat.parse(string).toDouble();
  }

  static String get currencySymbol {
    return _currencyFormat.currencySymbol;
  }
}

import 'package:flutter_multi_formatter/flutter_multi_formatter.dart'
    as formater;
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

class NumberFormatUtils {
  static const _locale = 'vi_vn';

  final NumberFormat vnFormat = NumberFormat.currency(
    locale: _locale,
    symbol: 'đ',
  );
  final NumberFormat _numberFormat = NumberFormat.decimalPattern(_locale);

  String? displayMoney(num? amount) {
    if (amount == null) {
      return null;
    }
    return amount.toCurrencyString(
      mantissaLength: 0,
      trailingSymbol: 'đ',
      useSymbolPadding: true,
      thousandSeparator: formater.ThousandSeparator.Period,
    );
  }

  String? decimalFormat(num? number) {
    return _numberFormat.format(number);
  }

  double? parseDouble(String? string) {
    if (string == null || string.isEmpty == true) {
      return null;
    }
    return _numberFormat.parse(string).toDouble();
  }

  String get currencySymbol {
    return vnFormat.currencySymbol;
  }
}

class CurrencyInputFormatter extends formater.CurrencyInputFormatter {
  CurrencyInputFormatter({
    super.thousandSeparator = formater.ThousandSeparator.Comma,
    super.mantissaLength = 0,
  });
}

class DecimalInputFormatter extends NumberTextInputFormatter {
  DecimalInputFormatter({
    super.integerDigits = 10,
    super.decimalDigits = 2,
    super.maxValue = '999999999.99',
    super.decimalSeparator = '.',
    super.groupDigits = 3,
    super.groupSeparator = ',',
    super.allowNegative = false,
    super.overrideDecimalPoint = true,
    super.insertDecimalPoint = false,
    super.insertDecimalDigits = false,
    super.fixNumber = false,
  });
}

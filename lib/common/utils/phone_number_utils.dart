import 'package:phone_numbers_parser/phone_numbers_parser.dart' as lib;

class PhoneNumberUtils {
  PhoneNumberUtils._();

  static PhoneNumber? parse(String phoneNumber) {
    try {
      final parsedPhone = lib.PhoneNumber.fromIsoCode('VN', phoneNumber);
      if (parsedPhone.validate()) {
        return PhoneNumber(parsedPhone);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

class PhoneNumber {
  final lib.PhoneNumber _phoneNumber;

  PhoneNumber(this._phoneNumber);

  /// 84
  String get countryCode => _phoneNumber.countryCode;

  /// 0942003360
  String get national => '0$nationalNumber';

  /// +84942003360
  String get international => _phoneNumber.international;

  /// 942003360
  String get nationalNumber => _phoneNumber.nsn;
}

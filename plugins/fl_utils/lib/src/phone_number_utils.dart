import 'package:phone_numbers_parser/phone_numbers_parser.dart' as lib;

export 'package:phone_numbers_parser/phone_numbers_parser.dart';

// Ref: https://www.itu.int/oth/T02020000E4/en
class PhoneNumberUtils {
  PhoneNumberUtils._();

  static PhoneNumber? parse(
    String phoneNumber, [
    lib.IsoCode code = lib.IsoCode.VN,
  ]) {
    final validCharacter = RegExp(r'^[+0-9]+$');
    if (!validCharacter.hasMatch(phoneNumber)) {
      return null;
    }
    try {
      final parsedPhone = lib.PhoneNumber.parse(
        phoneNumber,
        callerCountry: code,
        destinationCountry: code,
      );
      if (parsedPhone.isValid()) {
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

  /// xxxxxxx360
  String get hiddenNational =>
      'xxxxxxx${national.substring(national.length - 3)}';
}

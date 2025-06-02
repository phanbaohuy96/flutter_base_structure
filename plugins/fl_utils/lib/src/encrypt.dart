import 'package:encrypt/encrypt.dart';

String encrypt(String data, String passPhase) {
  try {
    final key = Key.fromUtf8(create32LengthPassPhase(passPhase));
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);

    return encrypted.base64;
  } catch (error) {
    return '';
  }
}

String decrypt(String data, String passPhase) {
  try {
    final key = Key.fromUtf8(create32LengthPassPhase(passPhase));
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final decrypted = encrypter.decrypt(Encrypted.fromBase64(data), iv: iv);
    return decrypted;
  } catch (error) {
    return '';
  }
}

String create32LengthPassPhase(String passPhase) {
  var _pass = '';
  final _length = passPhase.length;
  if (_length > 32) {
    _pass = passPhase.substring(0, 33);
  } else if (_length < 32) {
    final buffer = StringBuffer(passPhase);
    for (var i = 0; i < 32 - _length; i++) {
      buffer.write(String.fromCharCode(i));
    }
    _pass = buffer.toString();
  }
  return _pass;
}

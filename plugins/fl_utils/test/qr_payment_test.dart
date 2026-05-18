import 'package:fl_utils/src/qr_payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test QR Payment parser', () {
    expect(
      QRPaymentUtil.generateQrCode(
        bankBin: '970423', // TP Bank
        bankAcount: '123456789',
        amount: 50000,
        note: 'test note',
      ),
      '''00020101021238530010A0000007270123000697042301091234567890208QRIBFTTA53037045405500005802VN62130809test note630412A3''',
    );

    expect(
      QRPaymentUtil.generateQrCode(
        bankBin: '970415', // VietinBank
        bankAcount: '123456789',
        amount: 50000,
        note: 'test longgggg note',
      ),
      '''00020101021238530010A0000007270123000697041501091234567890208QRIBFTTA53037045405500005802VN62220818test longgggg note63049688''',
    );
  });
}

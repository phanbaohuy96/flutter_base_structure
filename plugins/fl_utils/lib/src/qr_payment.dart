class QRPaymentUtil {
  static String generateQrCode({
    String payloadFormatIndicator = '01',
    String pointOfInitiationMethod = '12',
    String guid = 'A000000727',
    String currencyCode = '704', // VN
    String countryCode = 'VN', // VN
    PaymentServiceCode serviceCode = PaymentServiceCode.toAccount,
    required String bankBin,
    required String bankAcount,
    required int amount,
    String? note,
  }) {
    final consumerAccountInformation = [
      '${guid.formatTLV('00')}',
      [
        bankBin.formatTLV('00'),
        bankAcount.formatTLV('01'),
      ].join().formatTLV('01'),
      serviceCode.code.formatTLV('02'),
    ].join();
    final qrData = [
      payloadFormatIndicator.formatTLV('00'),
      pointOfInitiationMethod.formatTLV('01'),
      consumerAccountInformation.formatTLV('38'),
      currencyCode.formatTLV('53'),
      amount.toString().formatTLV('54'),
      countryCode.formatTLV('58'),
      if (note != null && note.isNotEmpty) note.formatTLV('08').formatTLV('62'),
    ].join();
    return [
      qrData,
      // Append CRC16 checksum
      CRC.getCrc16('${qrData}6304').formatTLV('63'),
    ].join();
  }
}

extension QrPaymentUtilOnStringExt on String {
  String formatTLV(String id) => '$id${length.toString().padLeft(2, '0')}$this';
}

enum PaymentServiceCode {
  payment('QRPUSH'),
  toCard('QRIBFTTC'),
  toAccount('QRIBFTTA'),
  ;

  const PaymentServiceCode(this.code);
  final String code;
}

class CRC {
  static String getCrc16(String input) {
    const polynomial = 0x1021; // CRC-CCITT polynomial
    var crc = 0xFFFF; // Initial CRC value

    for (final codeUnit in input.codeUnits) {
      crc ^= codeUnit << 8; // XOR the top byte
      for (var i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? (crc << 1) ^ polynomial : (crc << 1);
      }
    }

    return (crc & 0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}

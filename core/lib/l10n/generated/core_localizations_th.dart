// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class CoreLocalizationsTh extends CoreLocalizations {
  CoreLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get inform => 'แจ้งเตือน';

  @override
  String get ok => 'ตกลง';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get noInternet =>
      'เกิดข้อผิดพลาดในการเชื่อมต่อ โปรดตรวจสอบการเชื่อมต่อเครือข่ายของคุณและลองใหม่อีกครั้ง';

  @override
  String get technicalIssues =>
      'ขออภัย เกิดปัญหาทางเทคนิค โปรดตรวจสอบการเชื่อมต่อของคุณหรือลองใหม่ภายหลัง';

  @override
  String get requestRestricted =>
      'มีการส่งคำขอมากเกินไป โปรดรอสักครู่แล้วลองใหม่อีกครั้ง';

  @override
  String get serverMaintenance =>
      'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ในขณะนี้ โปรดลองใหม่ภายหลัง';

  @override
  String get connectionTimeout => 'หมดเวลาการเชื่อมต่อ';

  @override
  String get unknownError => 'เกิดข้อผิดพลาด โปรดลองใหม่ภายหลัง';

  @override
  String get dataParsingError =>
      'เกิดข้อผิดพลาดในการประมวลผลข้อมูล โปรดลองใหม่ภายหลัง';

  @override
  String get sessionExpired =>
      'เซสชันของคุณหมดอายุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง';

  @override
  String get loading => 'กำลังโหลด';

  @override
  String get male => 'ชาย';

  @override
  String get female => 'หญิง';

  @override
  String get skip => 'ข้าม';

  @override
  String get close => 'ปิด';

  @override
  String get loginRequired => 'กรุณาเข้าสู่ระบบเพื่อดำเนินการต่อ';

  @override
  String get login => 'เข้าสู่ระบบ';

  @override
  String get error => 'ข้อผิดพลาด';

  @override
  String get search => 'ค้นหา';

  @override
  String get warning => 'คำเตือน';

  @override
  String get haveNoPermission =>
      'ไม่สามารถเข้าถึงได้ โปรดไปที่การตั้งค่าและให้สิทธิ์การเข้าถึงแอปเพื่อดำเนินการต่อ';

  @override
  String get openSetting => 'เปิดการตั้งค่า';

  @override
  String get openInExternalBrowser => 'เบราว์เซอร์ภายนอก';

  @override
  String get copyLink => 'คัดลอกลิงก์';

  @override
  String get copied => 'คัดลอกแล้ว';

  @override
  String get featureUnderDevelopment => 'ฟีเจอร์อยู่ระหว่างการพัฒนา';

  @override
  String get requestPermission => 'ขอสิทธิ์การเข้าถึง';

  @override
  String get firebaseAuthExceptionTypeAccountExistsWithDifferentCredential =>
      'เกิดข้อผิดพลาดขณะลงชื่อเข้าใช้';

  @override
  String get firebaseAuthExceptionTypeInvalidCredential =>
      'เกิดข้อผิดพลาดขณะลงชื่อเข้าใช้';

  @override
  String get firebaseAuthExceptionTypeOperationNotAllowed =>
      'เกิดข้อผิดพลาดขณะลงชื่อเข้าใช้';

  @override
  String get firebaseAuthExceptionTypeUserDisabled =>
      'บัญชีผู้ใช้ที่เกี่ยวข้องกับข้อมูลรับรองนี้ถูกปิดใช้งาน';

  @override
  String get firebaseAuthExceptionTypeUserNotFound =>
      'ไม่พบบัญชีผู้ใช้ โปรดตรวจสอบข้อมูลรับรองและลองใหม่อีกครั้ง';

  @override
  String get firebaseAuthExceptionTypeInvalidVerificationCode =>
      'รหัสยืนยันไม่ถูกต้อง';

  @override
  String get firebaseAuthExceptionTypeInvalidVerificationId =>
      'รหัสยืนยันตัวตนไม่ถูกต้อง';

  @override
  String get firebaseAuthExceptionTypeWrongPassword =>
      'รหัสผ่านไม่ถูกต้อง โปรดตรวจสอบข้อมูลรับรองและลองใหม่อีกครั้ง';

  @override
  String get firebaseAuthExceptionTypeUnknown =>
      'เกิดข้อผิดพลาดขณะลงชื่อเข้าใช้';

  @override
  String get firebaseAuthExceptionSessionExpired =>
      'รหัส OTP หมดอายุแล้ว โปรดส่งรหัสใหม่อีกครั้งเพื่อดำเนินการ';

  @override
  String get today => 'วันนี้';

  @override
  String get yesterday => 'เมื่อวานนี้';

  @override
  String get thisWeek => 'สัปดาห์นี้';

  @override
  String get weekAgo => 'เมื่อสัปดาห์ที่แล้ว';

  @override
  String get thisMonth => 'เดือนนี้';

  @override
  String get monthAgo => 'เมื่อเดือนที่แล้ว';

  @override
  String get selectDate => 'เลือกวันที่';

  @override
  String get fromDate => 'จากวันที่';

  @override
  String get toDate => 'ถึงวันที่';

  @override
  String get month => 'เดือน';

  @override
  String get threeDaysAgo => 'เมื่อ 3 วันที่แล้ว';

  @override
  String get sevenDaysAgo => 'เมื่อ 7 วันที่แล้ว';

  @override
  String get thirtyDaysAgo => 'เมื่อ 30 วันที่แล้ว';

  @override
  String get thisQuarter => 'ไตรมาสนี้';

  @override
  String get quarterAgo => 'เมื่อไตรมาสที่แล้ว';

  @override
  String get thisYear => 'ปีนี้';

  @override
  String get yearAgo => 'เมื่อปีที่แล้ว';

  @override
  String get selectTimePeriod => 'เลือกช่วงเวลา';

  @override
  String get reset => 'รีเซ็ต';

  @override
  String get apply => 'นำไปใช้';

  @override
  String get manual => 'กำหนดเอง';

  @override
  String get day => 'วัน';

  @override
  String get viewMore => 'ดูเพิ่มเติม';

  @override
  String get seeLess => 'ดูน้อยลง';

  @override
  String get fullTime => 'เต็มเวลา';

  @override
  String get camera => 'กล้องถ่ายรูป';

  @override
  String get gallery => 'แกลเลอรี';

  @override
  String get choosePhoto => 'เลือกรูปภาพ';

  @override
  String get choosePhotoOrVideo => 'เลือกสื่อ';

  @override
  String get chooseVideo => 'เลือกวิดีโอ';

  @override
  String get pleaseEnableGPS => 'กรุณาเปิดใช้งานตำแหน่งของคุณเพื่อดำเนินการต่อ';

  @override
  String get required => 'โปรดระบุ';

  @override
  String get optional => 'ถ้ามี';

  @override
  String fileSizeOverXMB(Object x) {
    return 'ไฟล์มีขนาดใหญ่เกินไป ขนาดสูงสุดที่อนุญาตคือ ${x}MB';
  }

  @override
  String get errorWhenUploading => 'เกิดข้อผิดพลาดขณะอัปโหลด';

  @override
  String get onlyImageAllowed => 'อนุญาตเฉพาะไฟล์รูปภาพ';

  @override
  String get onlyVideoAllowed => 'อนุญาตเฉพาะไฟล์วิดีโอ';

  @override
  String get onlyImageOrVideoAllowed => 'อนุญาตเฉพาะไฟล์รูปภาพหรือวิดีโอ';

  @override
  String get loggingOut => 'กำลังออกจากระบบ...';

  @override
  String get failedToLoadContent => 'ไม่สามารถโหลดเนื้อหาได้';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get downloadStarted => 'เริ่มดาวน์โหลด';

  @override
  String get failedToOpenExternalLink => 'ไม่สามารถเปิดลิงก์ภายนอกได้';

  @override
  String get downloadFailed => 'ดาวน์โหลดล้มเหลว';

  @override
  String get noContentToDisplay => 'ไม่มีเนื้อหาที่จะแสดง';
}

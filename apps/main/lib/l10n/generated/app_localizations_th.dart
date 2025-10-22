// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get inform => 'แจ้งเตือน';

  @override
  String get ok => 'ตกลง';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get skip => 'ข้าม';

  @override
  String get close => 'ปิด';

  @override
  String get loginRequired => 'กรุณาเข้าสู่ระบบเพื่อดำเนินการต่อ';

  @override
  String get login => 'เข้าสู่ระบบ';

  @override
  String get userRole => 'บทบาทผู้ใช้';

  @override
  String get poweredByVNS => 'Powered by VNS';

  @override
  String get pleaseSelectARoleBeforeLoginMsg =>
      'กรุณาเลือกบทบาทก่อนเข้าสู่ระบบ';

  @override
  String get backToHomepage => 'กลับสู่หน้าแรก';

  @override
  String get pageNotFound => '404 - ไม่พบหน้าที่ต้องการ';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get loginFailed => 'ไม่สามารถดึงข้อมูลผู้ใช้ได้';

  @override
  String get thisRoleIsNotSupportedYet => 'บทบาทนี้ยังไม่รองรับ';
}

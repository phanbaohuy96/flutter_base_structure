// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get inform => 'Thông báo';

  @override
  String get ok => 'Đồng ý';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get close => 'Đóng';

  @override
  String get loginRequired => 'Vui lòng đăng nhập để tiếp tục';

  @override
  String get login => 'Đăng nhập';

  @override
  String get poweredByApp => 'Được cung cấp bởi My Flutter Base';

  @override
  String get backToHomepage => 'Quay lại trang chủ';

  @override
  String get pageNotFound => '404 - Không tìm thấy trang';

  @override
  String get back => 'Quay lại';

  @override
  String get phoneNumber => 'Số điện thoại';

  @override
  String get password => 'Mật khẩu';

  @override
  String get phoneNumberHint => 'Nhập số điện thoại của bạn';

  @override
  String get passwordHint => 'Nhập mật khẩu của bạn';

  @override
  String get phoneRequired => 'Số điện thoại là bắt buộc';

  @override
  String get passwordRequired => 'Mật khẩu là bắt buộc';

  @override
  String get loginFailed => 'Số điện thoại hoặc mật khẩu không đúng';
}

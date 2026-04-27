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
  String get userRole => 'Vai trò người dùng';

  @override
  String get poweredByApp => 'Được cung cấp bởi My Flutter Base';

  @override
  String get pleaseSelectARoleBeforeLoginMsg =>
      'Vui lòng chọn vai trò trước khi đăng nhập.';

  @override
  String get backToHomepage => 'Quay lại trang chủ';

  @override
  String get pageNotFound => '404 - Không tìm thấy trang';

  @override
  String get back => 'Quay lại';

  @override
  String get loginFailed => 'Không thể lấy thông tin người dùng';

  @override
  String get thisRoleIsNotSupportedYet => 'Vai trò này chưa được hỗ trợ';
}

import 'package:data_source/data_source.dart';

enum LoginResultType { success, failed, unsupportedRole }

class AuthResponse {
  final LoginResultType result;

  AuthResponse({required this.result});
}

class AuthSuccessResponse extends AuthResponse {
  final UserModel user;

  AuthSuccessResponse({required this.user})
    : super(result: LoginResultType.success);
}

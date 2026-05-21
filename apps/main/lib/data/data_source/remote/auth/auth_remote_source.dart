import 'package:data_source/data_source.dart';

abstract class AuthRemoteSource {
  Future<UserModel?> signIn({
    required String phoneNumber,
    required String password,
  });
}

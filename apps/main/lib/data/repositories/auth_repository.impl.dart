import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import '../data_source/remote/auth/auth_remote_source.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteSource _remote;

  @override
  Future<UserModel?> authenticate({
    required String phoneNumber,
    required String password,
  }) {
    return _remote.signIn(phoneNumber: phoneNumber, password: password);
  }
}

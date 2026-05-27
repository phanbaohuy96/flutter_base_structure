import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_base/domain/entities/auth_session.dart';
import 'package:my_flutter_base/domain/repositories/auth_credential_source.dart';
import 'package:my_flutter_base/domain/repositories/auth_session_store.dart';
import 'package:my_flutter_base/domain/usecases/auth/auth_usecase.dart';

/// Records calls so tests can assert ordering and arguments without a mocking
/// framework — the ports are tiny enough that hand-rolled fakes are clearer.
class _FakeCredentialSource implements AuthCredentialSource {
  _FakeCredentialSource(this._result);

  final AuthSession? _result;
  int signInCalls = 0;
  String? lastPhoneNumber;
  String? lastPassword;

  @override
  Future<AuthSession?> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    signInCalls++;
    lastPhoneNumber = phoneNumber;
    lastPassword = password;
    return _result;
  }
}

class _RecordingSessionStore implements AuthSessionStore {
  final List<String> calls = <String>[];
  AuthSession? savedSession;

  @override
  Future<void> clearAuthSession() async {
    calls.add('clear');
  }

  @override
  Future<void> saveAuthSession(AuthSession session) async {
    calls.add('save');
    savedSession = session;
  }
}

void main() {
  const session = AuthSession(
    token: AuthToken(accessToken: 'token', type: AuthTokenType.bearer),
    user: AuthUser(id: '1', phoneNumber: '0123456789'),
  );

  group('AuthInteractorImpl.loginWithPhoneNumberPassword', () {
    test(
      'persists the session and returns true on valid credentials',
      () async {
        final credentialSource = _FakeCredentialSource(session);
        final sessionStore = _RecordingSessionStore();
        final usecase = AuthInteractorImpl(credentialSource, sessionStore);

        final result = await usecase.loginWithPhoneNumberPassword(
          phoneNumber: '0123456789',
          password: 'secret',
        );

        expect(result, isTrue);
        expect(sessionStore.savedSession, same(session));
        // Existing session is cleared before the new one is persisted.
        expect(sessionStore.calls, <String>['clear', 'save']);
        expect(credentialSource.lastPhoneNumber, '0123456789');
        expect(credentialSource.lastPassword, 'secret');
      },
    );

    test(
      'returns false and persists nothing when credentials are rejected',
      () async {
        final credentialSource = _FakeCredentialSource(null);
        final sessionStore = _RecordingSessionStore();
        final usecase = AuthInteractorImpl(credentialSource, sessionStore);

        final result = await usecase.loginWithPhoneNumberPassword(
          phoneNumber: '0000000000',
          password: 'wrong',
        );

        expect(result, isFalse);
        expect(credentialSource.signInCalls, 1);
        // The stale session is still cleared, but nothing new is saved.
        expect(sessionStore.calls, <String>['clear']);
        expect(sessionStore.savedSession, isNull);
      },
    );
  });
}

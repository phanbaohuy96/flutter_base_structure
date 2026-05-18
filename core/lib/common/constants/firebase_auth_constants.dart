import 'package:flutter/material.dart';

import '../../core.dart';

enum FirebaseAuthExceptionType {
  accountExistsWithDifferentCredential(
    'account-exists-with-different-credential',
  ),
  invalidCredential('invalid-credential'),
  operationNotAllowed('operation-not-allowed'),
  userDisabled('user-disabled'),
  userNotFound('user-not-found'),
  invalidVerificationCode('invalid-verification-code'),
  invalidVerificationId('invalid-verification-id'),
  wrongPassword('wrong-password'),
  sessionExpired('session-expired'),
  other('other');

  const FirebaseAuthExceptionType(this.code);

  final String code;
}

extension FirebaseAuthExceptionTypeExt on FirebaseAuthExceptionType {
  static FirebaseAuthExceptionType? fromString(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return FirebaseAuthExceptionType.accountExistsWithDifferentCredential;
      case 'invalid-credential':
        return FirebaseAuthExceptionType.invalidCredential;
      case 'operation-not-allowed':
        return FirebaseAuthExceptionType.operationNotAllowed;
      case 'user-disabled':
        return FirebaseAuthExceptionType.userDisabled;
      case 'user-not-found':
        return FirebaseAuthExceptionType.userNotFound;
      case 'invalid-verification-code':
        return FirebaseAuthExceptionType.invalidVerificationCode;
      case 'invalid-verification-id':
        return FirebaseAuthExceptionType.invalidVerificationId;
      case 'wrong-password':
        return FirebaseAuthExceptionType.wrongPassword;
      case 'session-expired':
        return FirebaseAuthExceptionType.sessionExpired;
    }

    return FirebaseAuthExceptionType.other;
  }

  String? localizedErrorMessage(BuildContext? context) {
    if (context == null) {
      return null;
    }

    final trans = CoreLocalizations.of(context);

    if (trans == null) {
      return null;
    }

    switch (this) {
      case FirebaseAuthExceptionType.accountExistsWithDifferentCredential:
        return trans
            .firebaseAuthExceptionTypeAccountExistsWithDifferentCredential;
      case FirebaseAuthExceptionType.invalidCredential:
        return trans.firebaseAuthExceptionTypeInvalidCredential;
      case FirebaseAuthExceptionType.operationNotAllowed:
        return trans.firebaseAuthExceptionTypeOperationNotAllowed;
      case FirebaseAuthExceptionType.userDisabled:
        return trans.firebaseAuthExceptionTypeUserDisabled;
      case FirebaseAuthExceptionType.userNotFound:
        return trans.firebaseAuthExceptionTypeUserNotFound;
      case FirebaseAuthExceptionType.invalidVerificationCode:
        return trans.firebaseAuthExceptionTypeInvalidVerificationCode;
      case FirebaseAuthExceptionType.invalidVerificationId:
        return trans.firebaseAuthExceptionTypeInvalidVerificationId;
      case FirebaseAuthExceptionType.wrongPassword:
        return trans.firebaseAuthExceptionTypeWrongPassword;
      case FirebaseAuthExceptionType.sessionExpired:
        return trans.firebaseAuthExceptionSessionExpired;
      case FirebaseAuthExceptionType.other:
        return null;
    }
  }
}

part of '../utils.dart';

class JwtUtils {
  static bool isAboutToExpire(
    String token, {
    Duration limit = const Duration(seconds: 5),
  }) {
    // TODO: implement check JWT token
    // final expiryDate = Jwt.getExpiryDate(token);
    // final currentTime = DateTime.now().toUtc();
    // return expiryDate?.subtract(limit).isBefore(currentTime) == true;
    return false;
  }
}
